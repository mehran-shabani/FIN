import 'package:equatable/equatable.dart';
import '../../../data/database/database.dart';
import '../../../data/models/expense_dto.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

class AddExpense extends ExpenseEvent {
  final double amount;
  final String currency;
  final DateTime date;
  final String? merchant;
  final String category;
  final double tax;
  final double tip;
  final String? note;
  final String source;
  final String? imagePath;
  final List<ExpenseItemDto>? items;

  const AddExpense({
    required this.amount,
    required this.currency,
    required this.date,
    this.merchant,
    required this.category,
    this.tax = 0,
    this.tip = 0,
    this.note,
    this.source = 'manual',
    this.imagePath,
    this.items,
  });

  @override
  List<Object?> get props => [
    amount,
    currency,
    date,
    merchant,
    category,
    tax,
    tip,
    note,
    source,
    imagePath,
    items,
  ];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;
  final List<ExpenseItemDto>? items;

  const UpdateExpense(this.expense, {this.items});

  @override
  List<Object?> get props => [expense, items];
}

class DeleteExpense extends ExpenseEvent {
  final String id;

  const DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterExpenses extends ExpenseEvent {
  final String? category;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? searchQuery;

  const FilterExpenses({
    this.category,
    this.fromDate,
    this.toDate,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, fromDate, toDate, searchQuery];
}

class SyncExpenses extends ExpenseEvent {
  const SyncExpenses();
}
