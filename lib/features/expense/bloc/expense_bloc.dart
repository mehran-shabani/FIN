import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import '../../../data/database/database.dart';
import '../../../services/api_service.dart';
import '../../../services/settings_service.dart';
import '../../../data/models/expense_dto.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AppDatabase _database;
  final ApiService _apiService;
  final SettingsService _settingsService;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  ExpenseBloc({
    required AppDatabase database,
    required ApiService apiService,
    required SettingsService settingsService,
  })  : _database = database,
        _apiService = apiService,
        _settingsService = settingsService,
        super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<FilterExpenses>(_onFilterExpenses);
    on<SyncExpenses>(_onSyncExpenses);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    try {
      emit(const ExpenseLoading());
      await _loadAndEmitExpenses(emit);
    } catch (e) {
      emit(ExpenseError('خطا در بارگذاری هزینه‌ها: ${e.toString()}'));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      if (state is ExpenseLoaded) {
        emit(const ExpenseLoading());

        final id = const Uuid().v4();
        final expense = ExpensesCompanion(
          id: Value(id),
          amount: Value(event.amount),
          currency: Value(event.currency),
          date: Value(event.date),
          merchant: Value(event.merchant),
          category: Value(event.category),
          tax: Value(event.tax),
          tip: Value(event.tip),
          note: Value(event.note),
          source: Value(event.source),
          imagePath: Value(event.imagePath),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        await _database.insertExpense(expense);

        // Add expense items if provided
        if (event.items != null && event.items!.isNotEmpty) {
          for (final item in event.items!) {
            final expenseItem = ExpenseItemsCompanion(
              expenseId: Value(id),
              name: Value(item.name),
              qty: Value(item.qty),
              unitPrice: Value(item.unitPrice),
            );
            await _database.insertExpenseItem(expenseItem);
          }
        }

        // Sync with backend if enabled
        if (_settingsService.isSyncEnabled()) {
          try {
            final dto = ExpenseDto(
              clientId: id,
              amount: event.amount,
              currency: event.currency,
              date: _dateFormat.format(event.date),
              merchant: event.merchant,
              category: event.category,
              tax: event.tax,
              tip: event.tip,
              note: event.note,
              source: event.source,
            );

            final response = await _apiService.syncExpense(dto);

            // Get the inserted expense and update with server ID
            final insertedExpense = await _database.getExpense(id);
            final updatedExpense = insertedExpense.copyWith(
              serverId: response.serverId ?? insertedExpense.serverId,
              synced: true,
              updatedAt: DateTime.now(),
            );

            await _database.updateExpense(updatedExpense);
          } catch (e) {
            debugPrint('Sync failed: $e');
          }
        }

        await _loadAndEmitExpenses(emit);
      }
    } catch (e) {
      emit(ExpenseError('خطا در افزودن هزینه: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    try {
      if (state is ExpenseLoaded) {
        emit(const ExpenseLoading());

        final updatedExpense = event.expense.copyWith(
          updatedAt: DateTime.now(),
          synced: false,
        );

        await _database.updateExpense(updatedExpense);

        // Update expense items if provided
        if (event.items != null) {
          // Delete existing items
          await _database.deleteExpenseItems(event.expense.id);
          
          // Add new items
          for (final item in event.items!) {
            final expenseItem = ExpenseItemsCompanion(
              expenseId: Value(event.expense.id),
              name: Value(item.name),
              qty: Value(item.qty),
              unitPrice: Value(item.unitPrice),
            );
            await _database.insertExpenseItem(expenseItem);
          }
        }

        await _loadAndEmitExpenses(emit);
      }
    } catch (e) {
      emit(ExpenseError('خطا در ویرایش هزینه: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      if (state is ExpenseLoaded) {
        emit(const ExpenseLoading());

        final expense = await _database.getExpense(event.id);

        // Delete from backend if synced
        if (_settingsService.isSyncEnabled() && expense.serverId != null) {
          try {
            await _apiService.deleteExpense(expense.serverId!);
          } catch (e) {
            debugPrint('Failed to delete from backend: $e');
          }
        }

        // Delete expense items
        await _database.deleteExpenseItems(event.id);
        
        // Delete expense
        await _database.deleteExpense(event.id);

        await _loadAndEmitExpenses(emit);
      }
    } catch (e) {
      emit(ExpenseError('خطا در حذف هزینه: ${e.toString()}'));
    }
  }

  Future<void> _onFilterExpenses(FilterExpenses event, Emitter<ExpenseState> emit) async {
    try {
      emit(const ExpenseLoading());
      await _loadAndEmitExpenses(
        emit,
        category: event.category,
        fromDate: event.fromDate,
        toDate: event.toDate,
        searchQuery: event.searchQuery,
      );
    } catch (e) {
      emit(ExpenseError('خطا در فیلتر کردن هزینه‌ها: ${e.toString()}'));
    }
  }

  Future<void> _onSyncExpenses(SyncExpenses event, Emitter<ExpenseState> emit) async {
    try {
      if (state is ExpenseLoaded && _settingsService.isSyncEnabled()) {
        final currentState = state as ExpenseLoaded;
        emit(ExpenseSyncing(
          expenses: currentState.expenses,
          totalAmount: currentState.totalAmount,
          categoryTotals: currentState.categoryTotals,
        ));

        final unsyncedExpenses = currentState.expenses.where((expense) => !expense.synced).toList();

        for (final expense in unsyncedExpenses) {
          try {
            final dto = ExpenseDto(
              clientId: expense.id,
              amount: expense.amount,
              currency: expense.currency,
              date: _dateFormat.format(expense.date),
              merchant: expense.merchant,
              category: expense.category,
              tax: expense.tax,
              tip: expense.tip,
              note: expense.note,
              source: expense.source,
            );

            final response = await _apiService.syncExpense(dto);

            final updatedExpense = expense.copyWith(
              serverId: Value.absentIfNull(response.serverId),
              synced: true,
              updatedAt: DateTime.now(),
            );

            await _database.updateExpense(updatedExpense);
          } catch (e) {
            debugPrint('Failed to sync expense ${expense.id}: $e');
          }
        }

        await _loadAndEmitExpenses(emit);
      }
    } catch (e) {
      emit(ExpenseError('خطا در همگام‌سازی: ${e.toString()}'));
    }
  }

  Future<void> _loadAndEmitExpenses(
    Emitter<ExpenseState> emit, {
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    var query = _database.select(_database.expenses);

    // Apply filters
    if (category != null && category.isNotEmpty) {
      query = query..where((e) => e.category.equals(category));
    }

    if (fromDate != null) {
      query = query..where((e) => e.date.isBiggerOrEqualValue(fromDate));
    }

    if (toDate != null) {
      query = query..where((e) => e.date.isSmallerOrEqualValue(toDate));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
        ..where((e) =>
            e.merchant.contains(searchQuery) |
            e.note.contains(searchQuery));
    }

    // Order by date descending
    query = query..orderBy([(e) => OrderingTerm.desc(e.date)]);

    final expenses = await query.get();
    final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

    // Calculate category totals
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    emit(ExpenseLoaded(
      expenses: expenses,
      totalAmount: totalAmount,
      categoryTotals: categoryTotals,
      appliedCategory: category,
      appliedFromDate: fromDate,
      appliedToDate: toDate,
      appliedSearchQuery: searchQuery,
    ));
  }
}