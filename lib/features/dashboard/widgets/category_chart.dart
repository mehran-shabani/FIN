import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../services/rule_engine.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('هیچ داده‌ای برای نمایش وجود ندارد')),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _generateSections(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          startDegreeOffset: -90,
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    final total = categoryTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final colors = _getColorPalette();

    return categoryTotals.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final colorIndex =
          categoryTotals.keys.toList().indexOf(entry.key) % colors.length;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        color: colors[colorIndex],
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryWhite,
        ),
      );
    }).toList();
  }

  List<Color> _getColorPalette() {
    // Monochrome color palette with different shades of gray and black
    return [
      AppTheme.primaryBlack,
      AppTheme.mediumGray,
      const Color(0xFF999999),
      const Color(0xFF777777),
      const Color(0xFF555555),
      const Color(0xFF333333),
      const Color(0xFF111111),
      const Color(0xFFBBBBBB),
      const Color(0xFF888888),
      const Color(0xFF444444),
    ];
  }
}

class CategoryLegend extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryLegend({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final colors = _getColorPalette();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryTotals.entries.map((entry) {
        final colorIndex =
            categoryTotals.keys.toList().indexOf(entry.key) % colors.length;
        final categoryName = RuleEngine.getCategoryDisplayName(entry.key);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[colorIndex],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(categoryName, style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      }).toList(),
    );
  }

  List<Color> _getColorPalette() {
    return [
      AppTheme.primaryBlack,
      AppTheme.mediumGray,
      const Color(0xFF999999),
      const Color(0xFF777777),
      const Color(0xFF555555),
      const Color(0xFF333333),
      const Color(0xFF111111),
      const Color(0xFFBBBBBB),
      const Color(0xFF888888),
      const Color(0xFF444444),
    ];
  }
}
