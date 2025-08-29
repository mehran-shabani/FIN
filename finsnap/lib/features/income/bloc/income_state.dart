import 'package:equatable/equatable.dart';
import '../../../data/database/database.dart';

abstract class IncomeState extends Equatable {
  const IncomeState();

  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {
  const IncomeInitial();
}

class IncomeLoading extends IncomeState {
  const IncomeLoading();
}

class IncomeLoaded extends IncomeState {
  final List<Income> incomes;
  final double totalAmount;

  const IncomeLoaded({
    required this.incomes,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [incomes, totalAmount];
}

class IncomeError extends IncomeState {
  final String message;

  const IncomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class IncomeSyncing extends IncomeState {
  final List<Income> incomes;
  final double totalAmount;

  const IncomeSyncing({
    required this.incomes,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [incomes, totalAmount];
}