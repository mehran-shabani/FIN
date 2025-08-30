import 'package:drift/drift.dart';

// Conditional imports
import 'database_native.dart' if (dart.library.html) 'database_web.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Incomes, Expenses, ExpenseItems, KvStore])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
      },
    );
  }

  // Income methods
  Future<List<Income>> getAllIncomes() => select(incomes).get();
  
  Future<Income> getIncome(String id) => 
      (select(incomes)..where((i) => i.id.equals(id))).getSingle();
      
  Future<int> insertIncome(IncomesCompanion income) => 
      into(incomes).insert(income);
      
  Future<bool> updateIncome(Income income) => 
      update(incomes).replace(income);
      
  Future<int> deleteIncome(String id) => 
      (delete(incomes)..where((i) => i.id.equals(id))).go();

  // Expense methods
  Future<List<Expense>> getAllExpenses() => select(expenses).get();
  
  Future<Expense> getExpense(String id) => 
      (select(expenses)..where((e) => e.id.equals(id))).getSingle();
      
  Future<int> insertExpense(ExpensesCompanion expense) => 
      into(expenses).insert(expense);
      
  Future<bool> updateExpense(Expense expense) => 
      update(expenses).replace(expense);
      
  Future<int> deleteExpense(String id) => 
      (delete(expenses)..where((e) => e.id.equals(id))).go();

  // Expense items methods
  Future<List<ExpenseItem>> getExpenseItems(String expenseId) =>
      (select(expenseItems)..where((ei) => ei.expenseId.equals(expenseId))).get();
      
  Future<int> insertExpenseItem(ExpenseItemsCompanion item) => 
      into(expenseItems).insert(item);
      
  Future<int> deleteExpenseItems(String expenseId) => 
      (delete(expenseItems)..where((ei) => ei.expenseId.equals(expenseId))).go();

  // KV Store methods
  Future<String?> getKvValue(String key) async {
    final result = await (select(kvStore)..where((kv) => kv.key.equals(key))).getSingleOrNull();
    return result?.valueJson;
  }
  
  Future<void> setKvValue(String key, String value) async {
    await into(kvStore).insertOnConflictUpdate(
      KvStoreCompanion(
        key: Value(key),
        valueJson: Value(value),
      ),
    );
  }
  
  Future<int> deleteKvValue(String key) => 
      (delete(kvStore)..where((kv) => kv.key.equals(key))).go();

  // Summary methods
  Future<double> getTotalIncomeForPeriod(DateTime from, DateTime to) async {
    final query = selectOnly(incomes)
      ..addColumns([incomes.amount.sum()])
      ..where(incomes.date.isBetweenValues(from, to));
    
    final result = await query.getSingle();
    return result.read(incomes.amount.sum()) ?? 0.0;
  }
  
  Future<double> getTotalExpenseForPeriod(DateTime from, DateTime to) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(from, to));
    
    final result = await query.getSingle();
    return result.read(expenses.amount.sum()) ?? 0.0;
  }
  
  Future<Map<String, double>> getExpensesByCategory(DateTime from, DateTime to) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.category, expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(from, to))
      ..groupBy([expenses.category]);
    
    final results = await query.get();
    return Map.fromEntries(
      results.map((row) => MapEntry(
        row.read(expenses.category) ?? 'other',
        row.read(expenses.amount.sum()) ?? 0.0,
      )),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return createDatabaseConnection();
  });
}