import '../data/database/tables.dart';

class CategoryRule {
  final String pattern;
  final String category;
  final bool isMerchantRule;

  const CategoryRule({
    required this.pattern,
    required this.category,
    this.isMerchantRule = true,
  });
}

class RuleEngine {
  static const List<CategoryRule> _rules = [
    // Groceries
    CategoryRule(pattern: 'supermarket', category: 'groceries'),
    CategoryRule(pattern: 'grocery', category: 'groceries'),
    CategoryRule(pattern: 'hypermarket', category: 'groceries'),
    CategoryRule(pattern: 'مارکت', category: 'groceries'),
    CategoryRule(pattern: 'فروشگاه', category: 'groceries'),
    CategoryRule(pattern: 'سوپر', category: 'groceries'),
    
    // Dining
    CategoryRule(pattern: 'restaurant', category: 'dining'),
    CategoryRule(pattern: 'cafe', category: 'dining'),
    CategoryRule(pattern: 'coffee', category: 'dining'),
    CategoryRule(pattern: 'pizza', category: 'dining'),
    CategoryRule(pattern: 'food', category: 'dining'),
    CategoryRule(pattern: 'رستوران', category: 'dining'),
    CategoryRule(pattern: 'کافه', category: 'dining'),
    CategoryRule(pattern: 'غذا', category: 'dining'),
    CategoryRule(pattern: 'پیتزا', category: 'dining'),
    
    // Transport
    CategoryRule(pattern: 'taxi', category: 'transport'),
    CategoryRule(pattern: 'uber', category: 'transport'),
    CategoryRule(pattern: 'bus', category: 'transport'),
    CategoryRule(pattern: 'metro', category: 'transport'),
    CategoryRule(pattern: 'gas station', category: 'transport'),
    CategoryRule(pattern: 'fuel', category: 'transport'),
    CategoryRule(pattern: 'تاکسی', category: 'transport'),
    CategoryRule(pattern: 'اتوبوس', category: 'transport'),
    CategoryRule(pattern: 'مترو', category: 'transport'),
    CategoryRule(pattern: 'بنزین', category: 'transport'),
    CategoryRule(pattern: 'سوخت', category: 'transport'),
    
    // Utilities
    CategoryRule(pattern: 'electric', category: 'utilities'),
    CategoryRule(pattern: 'water', category: 'utilities'),
    CategoryRule(pattern: 'gas', category: 'utilities'),
    CategoryRule(pattern: 'internet', category: 'utilities'),
    CategoryRule(pattern: 'phone', category: 'utilities'),
    CategoryRule(pattern: 'برق', category: 'utilities'),
    CategoryRule(pattern: 'آب', category: 'utilities'),
    CategoryRule(pattern: 'گاز', category: 'utilities'),
    CategoryRule(pattern: 'اینترنت', category: 'utilities'),
    CategoryRule(pattern: 'تلفن', category: 'utilities'),
    
    // Healthcare
    CategoryRule(pattern: 'pharmacy', category: 'healthcare'),
    CategoryRule(pattern: 'doctor', category: 'healthcare'),
    CategoryRule(pattern: 'hospital', category: 'healthcare'),
    CategoryRule(pattern: 'clinic', category: 'healthcare'),
    CategoryRule(pattern: 'medical', category: 'healthcare'),
    CategoryRule(pattern: 'داروخانه', category: 'healthcare'),
    CategoryRule(pattern: 'دکتر', category: 'healthcare'),
    CategoryRule(pattern: 'بیمارستان', category: 'healthcare'),
    CategoryRule(pattern: 'کلینیک', category: 'healthcare'),
    CategoryRule(pattern: 'پزشکی', category: 'healthcare'),
    
    // Personal
    CategoryRule(pattern: 'barber', category: 'personal'),
    CategoryRule(pattern: 'salon', category: 'personal'),
    CategoryRule(pattern: 'clothing', category: 'personal'),
    CategoryRule(pattern: 'shoes', category: 'personal'),
    CategoryRule(pattern: 'آرایشگاه', category: 'personal'),
    CategoryRule(pattern: 'لباس', category: 'personal'),
    CategoryRule(pattern: 'کفش', category: 'personal'),
    
    // Entertainment
    CategoryRule(pattern: 'cinema', category: 'entertainment'),
    CategoryRule(pattern: 'movie', category: 'entertainment'),
    CategoryRule(pattern: 'game', category: 'entertainment'),
    CategoryRule(pattern: 'park', category: 'entertainment'),
    CategoryRule(pattern: 'سینما', category: 'entertainment'),
    CategoryRule(pattern: 'فیلم', category: 'entertainment'),
    CategoryRule(pattern: 'بازی', category: 'entertainment'),
    CategoryRule(pattern: 'پارک', category: 'entertainment'),
    
    // Education
    CategoryRule(pattern: 'school', category: 'education'),
    CategoryRule(pattern: 'university', category: 'education'),
    CategoryRule(pattern: 'course', category: 'education'),
    CategoryRule(pattern: 'book', category: 'education'),
    CategoryRule(pattern: 'مدرسه', category: 'education'),
    CategoryRule(pattern: 'دانشگاه', category: 'education'),
    CategoryRule(pattern: 'دوره', category: 'education'),
    CategoryRule(pattern: 'کتاب', category: 'education'),
    
    // Rent
    CategoryRule(pattern: 'rent', category: 'rent'),
    CategoryRule(pattern: 'housing', category: 'rent'),
    CategoryRule(pattern: 'apartment', category: 'rent'),
    CategoryRule(pattern: 'اجاره', category: 'rent'),
    CategoryRule(pattern: 'مسکن', category: 'rent'),
    CategoryRule(pattern: 'آپارتمان', category: 'rent'),
    
    // Note-based rules (lower priority)
    CategoryRule(pattern: 'lunch', category: 'dining', isMerchantRule: false),
    CategoryRule(pattern: 'dinner', category: 'dining', isMerchantRule: false),
    CategoryRule(pattern: 'breakfast', category: 'dining', isMerchantRule: false),
    CategoryRule(pattern: 'صبحانه', category: 'dining', isMerchantRule: false),
    CategoryRule(pattern: 'ناهار', category: 'dining', isMerchantRule: false),
    CategoryRule(pattern: 'شام', category: 'dining', isMerchantRule: false),
  ];

  static String categorizeExpense({
    String? merchant,
    String? note,
    List<String>? itemNames,
  }) {
    final searchTexts = <String>[];
    
    // Add merchant name (highest priority)
    if (merchant != null && merchant.isNotEmpty) {
      searchTexts.add(merchant.toLowerCase());
    }
    
    // Add item names
    if (itemNames != null) {
      searchTexts.addAll(itemNames.map((name) => name.toLowerCase()));
    }
    
    // Add note (lower priority)
    if (note != null && note.isNotEmpty) {
      searchTexts.add(note.toLowerCase());
    }

    // First pass: Check merchant rules
    for (final rule in _rules.where((r) => r.isMerchantRule)) {
      for (final text in searchTexts) {
        if (text.contains(rule.pattern.toLowerCase())) {
          return rule.category;
        }
      }
    }

    // Second pass: Check note rules
    for (final rule in _rules.where((r) => !r.isMerchantRule)) {
      for (final text in searchTexts) {
        if (text.contains(rule.pattern.toLowerCase())) {
          return rule.category;
        }
      }
    }

    // Default category
    return 'other';
  }

  static bool isValidCategory(String category) {
    return expenseCategories.contains(category);
  }

  static List<String> getAvailableCategories() {
    return List.from(expenseCategories);
  }

  static String getCategoryDisplayName(String category) {
    const categoryNames = {
      'groceries': 'خواربار',
      'dining': 'رستوران',
      'transport': 'حمل‌ونقل',
      'utilities': 'آب/برق/گاز',
      'healthcare': 'بهداشت',
      'personal': 'شخصی',
      'entertainment': 'سرگرمی',
      'education': 'آموزش',
      'rent': 'اجاره',
      'other': 'سایر',
    };
    
    return categoryNames[category] ?? category;
  }
}