import 'package:equatable/equatable.dart';
import '../../../data/database/database.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalAmount;
  final Map<String, double> categoryTotals;
  final String? appliedCategory;
  final DateTime? appliedFromDate;
  final DateTime? appliedToDate;
  final String? appliedSearchQuery;

  const ExpenseLoaded({
    required this.expenses,
    required this.totalAmount,
    required this.categoryTotals,
    this.appliedCategory,
    this.appliedFromDate,
    this.appliedToDate,
    this.appliedSearchQuery,
  });

  @override
  List<Object?> get props => [
        expenses,
        totalAmount,
        categoryTotals,
        appliedCategory,
        appliedFromDate,
        appliedToDate,
        appliedSearchQuery,
      ];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExpenseSyncing extends ExpenseState {
  final List<Expense> expenses;
  final double totalAmount;
  final Map<String, double> categoryTotals;

  const ExpenseSyncing({
    required this.expenses,
    required this.totalAmount,
    required this.categoryTotals,
  });

  @override
  List<Object?> get props => [expenses, totalAmount, categoryTotals];
}