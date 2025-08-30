import 'package:flutter/material.dart';
import '../../../data/database/database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../services/rule_engine.dart';

class RecentTransactions extends StatelessWidget {
  final List<Expense> expenses;

  const RecentTransactions({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('هیچ تراکنشی وجود ندارد')),
        ),
      );
    }

    return Card(
      child: Column(
        children: expenses
            .map((expense) => _TransactionTile(expense: expense))
            .toList(),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Expense expense;

  const _TransactionTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final categoryName = RuleEngine.getCategoryDisplayName(expense.category);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          _getCategoryIcon(expense.category),
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      title: Text(
        expense.merchant ?? categoryName,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        AppDateUtils.getRelativeTime(expense.date),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        CurrencyFormatter.formatWithSymbol(expense.amount, expense.currency),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        // Navigate to expense details
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'dining':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'utilities':
        return Icons.electrical_services;
      case 'healthcare':
        return Icons.local_hospital;
      case 'personal':
        return Icons.person;
      case 'entertainment':
        return Icons.movie;
      case 'education':
        return Icons.school;
      case 'rent':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}
