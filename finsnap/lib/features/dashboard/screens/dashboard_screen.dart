import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/date_utils.dart';
import '../../income/bloc/income_bloc.dart';
import '../../income/bloc/income_event.dart';
import '../../income/bloc/income_state.dart';
import '../../expense/bloc/expense_bloc.dart';
import '../../expense/bloc/expense_event.dart';
import '../../expense/bloc/expense_state.dart';
import '../../expense/screens/add_expense_screen.dart';
import '../../income/screens/add_income_screen.dart';
import '../../expense/screens/transactions_screen.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/category_chart.dart';
import '../widgets/recent_transactions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<IncomeBloc>().add(const LoadIncomes());
    context.read<ExpenseBloc>().add(const LoadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinSnap'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const TransactionsScreen(),
          Container(), // Reports placeholder
          Container(), // AI Chat placeholder
          Container(), // Settings placeholder
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'داشبورد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'تراکنش‌ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'گزارش‌ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'چت AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () => _showAddOptionsDialog(),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'سلام، امروز ${AppDateUtils.formatPersianDate(DateTime.now())}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Summary cards
            BlocBuilder<IncomeBloc, IncomeState>(
              builder: (context, incomeState) {
                return BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, expenseState) {
                    double totalIncome = 0;
                    double totalExpense = 0;
                    String currency = 'IRR';

                    if (incomeState is IncomeLoaded) {
                      totalIncome = incomeState.totalAmount;
                    }

                    if (expenseState is ExpenseLoaded) {
                      totalExpense = expenseState.totalAmount;
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'درآمد ماه',
                            amount: totalIncome,
                            currency: currency,
                            color: AppTheme.primaryBlack,
                            icon: Icons.trending_up,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SummaryCard(
                            title: 'هزینه ماه',
                            amount: totalExpense,
                            currency: currency,
                            color: AppTheme.mediumGray,
                            icon: Icons.trending_down,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Balance card
            BlocBuilder<IncomeBloc, IncomeState>(
              builder: (context, incomeState) {
                return BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, expenseState) {
                    double totalIncome = 0;
                    double totalExpense = 0;
                    String currency = 'IRR';

                    if (incomeState is IncomeLoaded) {
                      totalIncome = incomeState.totalAmount;
                    }

                    if (expenseState is ExpenseLoaded) {
                      totalExpense = expenseState.totalAmount;
                    }

                    final balance = totalIncome - totalExpense;
                    final isPositive = balance >= 0;

                    return SummaryCard(
                      title: 'موجودی',
                      amount: balance.abs(),
                      currency: currency,
                      color: isPositive ? AppTheme.primaryBlack : AppTheme.mediumGray,
                      icon: isPositive ? Icons.account_balance_wallet : Icons.warning,
                      subtitle: isPositive ? 'مثبت' : 'منفی',
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick actions
            Text(
              'عملیات سریع',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const QuickActions(),

            const SizedBox(height: 24),

            // Category chart
            Text(
              'هزینه‌ها بر اساس دسته',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoaded && state.categoryTotals.isNotEmpty) {
                  return CategoryChart(categoryTotals: state.categoryTotals);
                }
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('هیچ هزینه‌ای ثبت نشده')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent transactions
            Text(
              'آخرین تراکنش‌ها',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoaded) {
                  final recentExpenses = state.expenses.take(5).toList();
                  return RecentTransactions(expenses: recentExpenses);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن تراکنش'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: AppTheme.primaryBlack),
              title: const Text('درآمد'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddIncomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle, color: AppTheme.mediumGray),
              title: const Text('هزینه دستی'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryBlack),
              title: const Text('اسکن رسید'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(scanReceipt: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}