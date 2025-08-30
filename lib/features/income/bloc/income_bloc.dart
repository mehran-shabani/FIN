import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import '../../../data/database/database.dart';
import '../../../services/api_service.dart';
import '../../../services/settings_service.dart';
import '../../../data/models/income_dto.dart';
import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final AppDatabase _database;
  final ApiService _apiService;
  final SettingsService _settingsService;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  IncomeBloc({
    required AppDatabase database,
    required ApiService apiService,
    required SettingsService settingsService,
  }) : _database = database,
       _apiService = apiService,
       _settingsService = settingsService,
       super(const IncomeInitial()) {
    on<LoadIncomes>(_onLoadIncomes);
    on<AddIncome>(_onAddIncome);
    on<UpdateIncome>(_onUpdateIncome);
    on<DeleteIncome>(_onDeleteIncome);
    on<SyncIncomes>(_onSyncIncomes);
  }

  Future<void> _onLoadIncomes(
    LoadIncomes event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      emit(const IncomeLoading());

      final incomes = await _database.getAllIncomes();
      final totalAmount = incomes.fold<double>(
        0,
        (sum, income) => sum + income.amount,
      );

      emit(IncomeLoaded(incomes: incomes, totalAmount: totalAmount));
    } catch (e) {
      emit(IncomeError('خطا در بارگذاری درآمدها: ${e.toString()}'));
    }
  }

  Future<void> _onAddIncome(AddIncome event, Emitter<IncomeState> emit) async {
    try {
      if (state is IncomeLoaded) {
        emit(const IncomeLoading());

        final id = const Uuid().v4();
        final income = IncomesCompanion(
          id: Value(id),
          amount: Value(event.amount),
          currency: Value(event.currency),
          date: Value(event.date),
          source: Value(event.source),
          note: Value(event.note),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        await _database.insertIncome(income);

        // Sync with backend if enabled
        if (_settingsService.isSyncEnabled()) {
          try {
            final dto = IncomeDto(
              clientId: id,
              amount: event.amount,
              currency: event.currency,
              date: _dateFormat.format(event.date),
              source: event.source,
              note: event.note,
            );

            final response = await _apiService.syncIncome(dto);

            // Get the inserted income and update with server ID
            final insertedIncome = await _database.getIncome(id);
            final updatedIncome = insertedIncome.copyWith(
              serverId: Value.absentIfNull(response.serverId),
              synced: true,
              updatedAt: DateTime.now(),
            );

            await _database.updateIncome(updatedIncome);
          } catch (e) {
            // Sync failed, but local save succeeded
            debugPrint('Sync failed: $e');
          }
        }

        // Reload data
        add(const LoadIncomes());
      }
    } catch (e) {
      emit(IncomeError('خطا در افزودن درآمد: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateIncome(
    UpdateIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      if (state is IncomeLoaded) {
        emit(const IncomeLoading());

        final updatedIncome = event.income.copyWith(
          updatedAt: DateTime.now(),
          synced: false, // Mark as unsynced for next sync
        );

        await _database.updateIncome(updatedIncome);

        // Reload data
        add(const LoadIncomes());
      }
    } catch (e) {
      emit(IncomeError('خطا در ویرایش درآمد: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteIncome(
    DeleteIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      if (state is IncomeLoaded) {
        emit(const IncomeLoading());

        final income = await _database.getIncome(event.id);

        // Delete from backend if synced
        if (_settingsService.isSyncEnabled() && income.serverId != null) {
          try {
            await _apiService.deleteExpense(income.serverId!);
          } catch (e) {
            debugPrint('Failed to delete from backend: $e');
          }
        }

        await _database.deleteIncome(event.id);

        // Reload data
        add(const LoadIncomes());
      }
    } catch (e) {
      emit(IncomeError('خطا در حذف درآمد: ${e.toString()}'));
    }
  }

  Future<void> _onSyncIncomes(
    SyncIncomes event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      if (state is IncomeLoaded && _settingsService.isSyncEnabled()) {
        final currentState = state as IncomeLoaded;
        emit(
          IncomeSyncing(
            incomes: currentState.incomes,
            totalAmount: currentState.totalAmount,
          ),
        );

        final unsyncedIncomes = currentState.incomes
            .where((income) => !income.synced)
            .toList();

        for (final income in unsyncedIncomes) {
          try {
            final dto = IncomeDto(
              clientId: income.id,
              amount: income.amount,
              currency: income.currency,
              date: _dateFormat.format(income.date),
              source: income.source,
              note: income.note,
            );

            final response = await _apiService.syncIncome(dto);

            // Update with server ID
            final updatedIncome = income.copyWith(
              serverId: Value.absentIfNull(response.serverId),
              synced: true,
              updatedAt: DateTime.now(),
            );

            await _database.updateIncome(updatedIncome);
          } catch (e) {
            debugPrint('Failed to sync income ${income.id}: $e');
          }
        }

        // Reload data
        add(const LoadIncomes());
      }
    } catch (e) {
      emit(IncomeError('خطا در همگام‌سازی: ${e.toString()}'));
    }
  }
}
