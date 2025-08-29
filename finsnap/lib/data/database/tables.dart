import 'package:drift/drift.dart';

// Incomes table
class Incomes extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  RealColumn get amount => real()();
  TextColumn get currency => text().withLength(min: 1, max: 10).withDefault(const Constant('IRR'))();
  DateTimeColumn get date => dateTime()();
  TextColumn get source => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get serverId => text().nullable()(); // For sync purposes
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Expenses table
class Expenses extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  RealColumn get amount => real()();
  TextColumn get currency => text().withLength(min: 1, max: 10).withDefault(const Constant('IRR'))();
  DateTimeColumn get date => dateTime()();
  TextColumn get merchant => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get tip => real().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))(); // 'receipt' or 'manual'
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get serverId => text().nullable()(); // For sync purposes
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Expense items table (for detailed receipt breakdown)
class ExpenseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get expenseId => text().references(Expenses, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  RealColumn get unitPrice => real()();
}

// Key-Value store for settings, flags, tokens
class KvStore extends Table {
  TextColumn get key => text().withLength(min: 1, max: 100)();
  TextColumn get valueJson => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// Available categories (constant list)
const List<String> expenseCategories = [
  'groceries',
  'dining', 
  'transport',
  'utilities',
  'healthcare',
  'personal',
  'entertainment',
  'education',
  'rent',
  'other',
];