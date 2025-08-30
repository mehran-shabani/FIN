import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../services/rule_engine.dart';
import '../../../data/database/database.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedCategory;
  DateTime? _fromDate;
  DateTime? _toDate;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    context.read<ExpenseBloc>().add(const LoadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تراکنش‌ها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_hasActiveFilters()) _buildFilterChips(),

          // Transactions list
          Expanded(
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExpenseError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadExpenses,
                          child: const Text('تلاش مجدد'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ExpenseLoaded) {
                  if (state.expenses.isEmpty) {
                    return const Center(child: Text('هیچ تراکنشی یافت نشد'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadExpenses(),
                    child: ListView.builder(
                      itemCount: state.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = state.expenses[index];
                        return _ExpenseListTile(expense: expense);
                      },
                    ),
                  );
                }

                return const Center(child: Text('شروع کنید'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add expense
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
        _fromDate != null ||
        _toDate != null ||
        _searchController.text.isNotEmpty;
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedCategory != null)
            Chip(
              label: Text(
                RuleEngine.getCategoryDisplayName(_selectedCategory!),
              ),
              onDeleted: () {
                setState(() {
                  _selectedCategory = null;
                });
                _applyFilters();
              },
            ),
          if (_fromDate != null)
            Chip(
              label: Text('از: ${AppDateUtils.formatPersianDate(_fromDate!)}'),
              onDeleted: () {
                setState(() {
                  _fromDate = null;
                });
                _applyFilters();
              },
            ),
          if (_toDate != null)
            Chip(
              label: Text('تا: ${AppDateUtils.formatPersianDate(_toDate!)}'),
              onDeleted: () {
                setState(() {
                  _toDate = null;
                });
                _applyFilters();
              },
            ),
          if (_searchController.text.isNotEmpty)
            Chip(
              label: Text('جستجو: ${_searchController.text}'),
              onDeleted: () {
                setState(() {
                  _searchController.clear();
                });
                _applyFilters();
              },
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فیلتر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'دسته‌بندی'),
              items: [
                const DropdownMenuItem(value: null, child: Text('همه')),
                ...RuleEngine.getAvailableCategories().map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(RuleEngine.getCategoryDisplayName(category)),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: const Text('اعمال'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('جستجو'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'نام فروشنده یا یادداشت...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: const Text('جستجو'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    context.read<ExpenseBloc>().add(
      FilterExpenses(
        category: _selectedCategory,
        fromDate: _fromDate,
        toDate: _toDate,
        searchQuery: _searchController.text.isEmpty
            ? null
            : _searchController.text,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ExpenseListTile extends StatelessWidget {
  final Expense expense;

  const _ExpenseListTile({required this.expense});

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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(categoryName),
          Text(AppDateUtils.formatPersianDate(expense.date)),
        ],
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
