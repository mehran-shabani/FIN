import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _persianDateFormat = DateFormat('yyyy/MM/dd', 'fa_IR');
  static final DateFormat _persianDateTimeFormat = DateFormat('yyyy/MM/dd - HH:mm', 'fa_IR');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthFormat = DateFormat('yyyy-MM');
  static final DateFormat _persianMonthFormat = DateFormat('MMMM yyyy', 'fa_IR');

  // Format date for display
  static String formatPersianDate(DateTime date) {
    return _persianDateFormat.format(date);
  }

  static String formatPersianDateTime(DateTime date) {
    return _persianDateTimeFormat.format(date);
  }

  // Format date for API
  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }

  // Format month for API
  static String formatApiMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  // Format month for display
  static String formatPersianMonth(DateTime date) {
    return _persianMonthFormat.format(date);
  }

  // Parse API date
  static DateTime? parseApiDate(String dateString) {
    try {
      return _apiDateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get relative time
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'اکنون';
        } else {
          return '${difference.inMinutes} دقیقه پیش';
        }
      } else {
        return '${difference.inHours} ساعت پیش';
      }
    } else if (difference.inDays == 1) {
      return 'دیروز';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} روز پیش';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks هفته پیش';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ماه پیش';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years سال پیش';
    }
  }

  // Get day name in Persian
  static String getPersianDayName(DateTime date) {
    const dayNames = [
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
      'شنبه',
      'یکشنبه',
    ];
    return dayNames[date.weekday - 1];
  }

  // Get month name in Persian
  static String getPersianMonthName(int month) {
    const monthNames = [
      'ژانویه', 'فوریه', 'مارس', 'آوریل', 'مه', 'ژوئن',
      'ژوئیه', 'اوت', 'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر'
    ];
    return monthNames[month - 1];
  }

  // Get start and end of month
  static ({DateTime start, DateTime end}) getMonthRange(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    return (start: start, end: end);
  }

  // Get start and end of week
  static ({DateTime start, DateTime end}) getWeekRange(DateTime date) {
    final weekday = date.weekday;
    final start = date.subtract(Duration(days: weekday - 1));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return (start: start, end: end);
  }

  // Get start and end of year
  static ({DateTime start, DateTime end}) getYearRange(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final end = DateTime(date.year, 12, 31, 23, 59, 59);
    return (start: start, end: end);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekRange = getWeekRange(now);
    return date.isAfter(weekRange.start.subtract(const Duration(seconds: 1))) &&
           date.isBefore(weekRange.end.add(const Duration(seconds: 1)));
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get list of recent months
  static List<DateTime> getRecentMonths(int count) {
    final now = DateTime.now();
    final months = <DateTime>[];
    
    for (int i = 0; i < count; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      months.add(month);
    }
    
    return months;
  }

  // Convert Persian numerals in date strings
  static String convertPersianNumerals(String input) {
    const persianNumerals = '۰۱۲۳۴۵۶۷۸۹';
    const englishNumerals = '0123456789';
    
    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(persianNumerals[i], englishNumerals[i]);
    }
    return result;
  }
}