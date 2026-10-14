import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';

/// Card showing spending trend graph and weekly day columns.
class SpendingGraphCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const SpendingGraphCard({
    super.key,
    required this.transactions,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final secondaryText = isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText;

    final dailyTotals = List<double>.filled(7, 0.0);
    final now = DateTime.now();

    for (final exp in transactions) {
      if (exp.type == 'expense') {
        final diff = now.difference(exp.time).inDays;
        if (diff >= 0 && diff < 7) {
          final weekdayIndex = exp.time.weekday - 1;
          dailyTotals[weekdayIndex] += exp.amount;
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.spendingAnalysis,
                style: TextStyle(
                  fontSize: AppSizes.fontSubheading,
                  fontWeight: FontWeight.bold,
                  color: theme.secondaryHeaderColor,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: scheme.secondary,
                    size: AppSizes.fontTitleSm,
                  ),
                  dropdownColor: isLight ? scheme.surface : AppColors.surface,
                  style: TextStyle(
                    fontSize: AppSizes.fontCaption,
                    color: scheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (val) {
                    if (val != null) onPeriodChanged(val);
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'This Week',
                      child: Text(AppStrings.thisWeek),
                    ),
                    DropdownMenuItem(
                      value: 'This Month',
                      child: Text(AppStrings.thisMonth),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _DynamicSpendingGraphPainter(
                dailyAmounts: dailyTotals,
                gridColor: scheme.onSurface.withValues(alpha: 0.04),
                lineColor: scheme.secondary,
                fillColor: AppColors.primaryPurpleLight,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayLabel(AppStrings.daysMon, secondaryText),
              _buildDayLabel(AppStrings.daysTue, secondaryText),
              _buildDayLabel(AppStrings.daysWed, secondaryText),
              _buildDayLabel(AppStrings.daysThu, secondaryText),
              _buildDayLabel(AppStrings.daysFri, secondaryText),
              _buildDayLabel(AppStrings.daysSat, secondaryText),
              _buildDayLabel(AppStrings.daysSun, secondaryText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: AppSizes.fontSm,
      ),
    );
  }
}

class _DynamicSpendingGraphPainter extends CustomPainter {
  final List<double> dailyAmounts;
  final Color gridColor;
  final Color lineColor;
  final Color fillColor;

  _DynamicSpendingGraphPainter({
    required this.dailyAmounts,
    required this.gridColor,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const int lines = 4;
    for (int i = 0; i <= lines; i++) {
      final y = (size.height / lines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxVal = dailyAmounts.fold<double>(
      0.0,
      (m, val) => val > m ? val : m,
    );
    final effectiveMax = maxVal == 0 ? 100.0 : maxVal * 1.2;

    final points = <Offset>[];
    for (int i = 0; i < 7; i++) {
      final x = (size.width / 6) * i;
      final normalizedY = (dailyAmounts[i] / effectiveMax).clamp(0.0, 1.0);
      final y =
          size.height - (normalizedY * (size.height * 0.8) + size.height * 0.1);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor.withValues(alpha: 0.35),
          fillColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _DynamicSpendingGraphPainter oldDelegate) {
    return oldDelegate.dailyAmounts != dailyAmounts ||
        oldDelegate.lineColor != lineColor;
  }
}
