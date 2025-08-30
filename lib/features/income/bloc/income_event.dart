import 'package:equatable/equatable.dart';
import '../../../data/database/database.dart';

abstract class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncomes extends IncomeEvent {
  const LoadIncomes();
}

class AddIncome extends IncomeEvent {
  final double amount;
  final String currency;
  final DateTime date;
  final String? source;
  final String? note;

  const AddIncome({
    required this.amount,
    required this.currency,
    required this.date,
    this.source,
    this.note,
  });

  @override
  List<Object?> get props => [amount, currency, date, source, note];
}

class UpdateIncome extends IncomeEvent {
  final Income income;

  const UpdateIncome(this.income);

  @override
  List<Object?> get props => [income];
}

class DeleteIncome extends IncomeEvent {
  final String id;

  const DeleteIncome(this.id);

  @override
  List<Object?> get props => [id];
}

class SyncIncomes extends IncomeEvent {
  const SyncIncomes();
}
