import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../services/settings_service.dart';
import '../../../services/rule_engine.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';

class AddExpenseScreen extends StatefulWidget {
  final bool scanReceipt;

  const AddExpenseScreen({super.key, this.scanReceipt = false});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'IRR';
  String _selectedCategory = 'other';

  @override
  void initState() {
    super.initState();
    final settingsService = context.read<SettingsService>();
    _selectedCurrency = settingsService.getCurrency();

    if (widget.scanReceipt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanReceipt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scanReceipt ? 'اسکن رسید' : 'افزودن هزینه'),
        actions: [
          TextButton(onPressed: _submitForm, child: const Text('ذخیره')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.scanReceipt) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('عکس رسید را انتخاب کنید')),
                        ElevatedButton(
                          onPressed: _scanReceipt,
                          child: const Text('انتخاب عکس'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'مبلغ *',
                  suffixText: CurrencyFormatter.getCurrencySymbol(
                    _selectedCurrency,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً مبلغ را وارد کنید';
                  }
                  final amount = CurrencyFormatter.parseAmount(
                    value,
                    _selectedCurrency,
                  );
                  if (amount == null || amount <= 0) {
                    return 'مبلغ باید بیشتر از صفر باشد';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاریخ',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Merchant field
              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'فروشنده/مکان',
                  hintText: 'نام فروشگاه، رستوران، ...',
                ),
                onChanged: _onMerchantChanged,
              ),
              const SizedBox(height: 16),

              // Category field
              Text('دسته‌بندی', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: RuleEngine.getAvailableCategories().map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(RuleEngine.getCategoryDisplayName(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Note field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'یادداشت',
                  hintText: 'توضیحات اضافی...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Currency selector
              Text('ارز', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: CurrencyFormatter.getSupportedCurrencies().map((
                  currency,
                ) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(CurrencyFormatter.getCurrencyName(currency)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMerchantChanged(String merchant) {
    // Auto-categorize based on merchant name
    final suggestedCategory = RuleEngine.categorizeExpense(merchant: merchant);
    if (suggestedCategory != _selectedCategory) {
      setState(() {
        _selectedCategory = suggestedCategory;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _scanReceipt() {
    // This would open camera/gallery picker
    // For now, just show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اسکن رسید'),
        content: const Text('این قابلیت به‌زودی اضافه خواهد شد.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = CurrencyFormatter.parseAmount(
        _amountController.text,
        _selectedCurrency,
      )!;

      context.read<ExpenseBloc>().add(
        AddExpense(
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          merchant: _merchantController.text.isEmpty
              ? null
              : _merchantController.text,
          category: _selectedCategory,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          source: widget.scanReceipt ? 'receipt' : 'manual',
        ),
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('هزینه با موفقیت اضافه شد')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
