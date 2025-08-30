import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final Map<String, NumberFormat> _formatters = {};

  static String format(double amount, String currency) {
    final formatter = _getFormatter(currency);
    return formatter.format(amount);
  }

  static String formatWithSymbol(double amount, String currency) {
    final symbol = getCurrencySymbol(currency);
    final formatted = format(amount, currency);
    return '$formatted $symbol';
  }

  static NumberFormat _getFormatter(String currency) {
    if (!_formatters.containsKey(currency)) {
      switch (currency.toUpperCase()) {
        case 'IRR':
          _formatters[currency] = NumberFormat('#,##0', 'fa_IR');
          break;
        case 'USD':
          _formatters[currency] = NumberFormat.currency(
            locale: 'en_US',
            symbol: '',
          );
          break;
        case 'EUR':
          _formatters[currency] = NumberFormat.currency(
            locale: 'en_EU',
            symbol: '',
          );
          break;
        default:
          _formatters[currency] = NumberFormat('#,##0.00');
      }
    }
    return _formatters[currency]!;
  }

  static String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'IRR':
        return 'ریال';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  static String getCurrencyName(String currency) {
    switch (currency.toUpperCase()) {
      case 'IRR':
        return 'ریال ایران';
      case 'USD':
        return 'دلار آمریکا';
      case 'EUR':
        return 'یورو';
      case 'GBP':
        return 'پوند انگلیس';
      default:
        return currency;
    }
  }

  static List<String> getSupportedCurrencies() {
    return ['IRR', 'USD', 'EUR', 'GBP'];
  }

  static double? parseAmount(String text, String currency) {
    // Remove currency symbols and whitespace
    String cleaned = text.replaceAll(RegExp(r'[^\d.,]'), '');

    // Handle Persian/Arabic numerals
    cleaned = _convertPersianNumerals(cleaned);

    // Handle different decimal separators
    if (currency.toUpperCase() == 'IRR') {
      // Persian format: use comma as thousands separator
      cleaned = cleaned.replaceAll(',', '');
    } else {
      // Western format: handle both comma and dot
      if (cleaned.contains(',') && cleaned.contains('.')) {
        // Assume comma is thousands separator
        cleaned = cleaned.replaceAll(',', '');
      } else if (cleaned.contains(',')) {
        // Could be decimal separator
        int commaIndex = cleaned.lastIndexOf(',');
        if (cleaned.length - commaIndex <= 3) {
          cleaned = cleaned.replaceAll(',', '.');
        } else {
          cleaned = cleaned.replaceAll(',', '');
        }
      }
    }

    return double.tryParse(cleaned);
  }

  static String _convertPersianNumerals(String input) {
    const persianNumerals = '۰۱۲۳۴۵۶۷۸۹';
    const arabicNumerals = '٠١٢٣٤٥٦٧٨٩';
    const englishNumerals = '0123456789';

    String result = input;

    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(persianNumerals[i], englishNumerals[i]);
      result = result.replaceAll(arabicNumerals[i], englishNumerals[i]);
    }

    return result;
  }

  static String formatLargeNumber(double amount, String currency) {
    const suffixes = ['', 'هزار', 'میلیون', 'میلیارد'];

    if (amount < 1000) {
      return formatWithSymbol(amount, currency);
    }

    int suffixIndex = 0;
    double displayAmount = amount;

    while (displayAmount >= 1000 && suffixIndex < suffixes.length - 1) {
      displayAmount /= 1000;
      suffixIndex++;
    }

    final formatter = NumberFormat('#,##0.#', 'fa_IR');
    final formattedAmount = formatter.format(displayAmount);
    final symbol = getCurrencySymbol(currency);

    return '$formattedAmount ${suffixes[suffixIndex]} $symbol';
  }
}
