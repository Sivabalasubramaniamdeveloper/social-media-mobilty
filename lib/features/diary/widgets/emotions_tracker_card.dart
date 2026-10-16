import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_strings.dart';
import '../services/diary_database_service.dart';

class EmotionsTrackerCard extends StatefulWidget {
  final String userId;

  const EmotionsTrackerCard({super.key, required this.userId});

  @override
  State<EmotionsTrackerCard> createState() => _EmotionsTrackerCardState();
}

class _EmotionsTrackerCardState extends State<EmotionsTrackerCard> {
  bool _isLoading = true;
  Map<String, double> _emotionData = {
    'happy': 0.48,
    'sad': 0.33,
    'calm': 0.27,
    'anxious': 0.40,
  };

  @override
  void initState() {
    super.initState();
    _loadLocalEmotionData();
  }

  Future<void> _loadLocalEmotionData() async {
    try {
      final data = await DiaryDatabaseService.instance
          .getCoreEmotionsDistribution(widget.userId);
      if (mounted) {
        setState(() {
          _emotionData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Background track color
    final trackBackground = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : scheme.surfaceContainerHighest;

    final List<_PillData> items = [
      _PillData(
        label: AppStrings.moodHappy,
        percentage: _emotionData['happy'] ?? 0.0,
        fillColor: scheme.tertiary,
      ),
      _PillData(
        label: AppStrings.moodSad,
        percentage: _emotionData['sad'] ?? 0.0,
        fillColor: scheme.error,
      ),
      _PillData(
        label: AppStrings.moodCalm,
        percentage: _emotionData['calm'] ?? 0.0,
        fillColor: scheme.secondary,
      ),
      _PillData(
        label: AppStrings.moodAnxious,
        percentage: _emotionData['anxious'] ?? 0.0,
        fillColor: scheme.primary,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: isDark ? scheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.emotions,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.coreEmotionsDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // The 4 capsule pillars
          SizedBox(
            height: 230,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: scheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: items.map((item) {
                      return _buildCapsulePill(
                        context: context,
                        item: item,
                        trackBackground: trackBackground,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsulePill({
    required BuildContext context,
    required _PillData item,
    required Color trackBackground,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final int percentValue = (item.percentage * 100).round();

    return Column(
      children: [
        Expanded(
          child: Container(
            width: 58,
            decoration: BoxDecoration(
              color: trackBackground,
              borderRadius: BorderRadius.circular(32),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxHeight = constraints.maxHeight;
                // Keep minimal visible height so percentage text fits
                final double fillHeight = (maxHeight * item.percentage).clamp(
                  56.0,
                  maxHeight,
                );

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      height: fillHeight,
                      width: 58,
                      decoration: BoxDecoration(
                        color: item.fillColor,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '$percentValue%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          item.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PillData {
  final String label;
  final double percentage;
  final Color fillColor;

  const _PillData({
    required this.label,
    required this.percentage,
    required this.fillColor,
  });
}
