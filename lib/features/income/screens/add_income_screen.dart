import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../services/settings_service.dart';
import '../bloc/income_bloc.dart';
import '../bloc/income_event.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'IRR';

  @override
  void initState() {
    super.initState();
    final settingsService = context.read<SettingsService>();
    _selectedCurrency = settingsService.getCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('افزودن درآمد'),
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

              // Source field
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'منبع درآمد',
                  hintText: 'حقوق، فروش، سود، ...',
                ),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = CurrencyFormatter.parseAmount(
        _amountController.text,
        _selectedCurrency,
      )!;

      context.read<IncomeBloc>().add(
        AddIncome(
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          source: _sourceController.text.isEmpty
              ? null
              : _sourceController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('درآمد با موفقیت اضافه شد')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
