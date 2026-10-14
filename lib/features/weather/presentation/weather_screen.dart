import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/services/location_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _currentLocation = 'Fetching location...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAndFetchLocation();
    });
  }

  Future<void> _requestAndFetchLocation() async {
    setState(() => _isLoadingLocation = true);
    final locationName = await LocationService.getCurrentCityLocation();
    if (mounted) {
      setState(() {
        _currentLocation = locationName;
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _WeatherView(
      currentLocation: _currentLocation,
      isLoadingLocation: _isLoadingLocation,
      onRefreshLocation: _requestAndFetchLocation,
    );
  }
}

class _WeatherView extends BaseScreen {
  final String currentLocation;
  final bool isLoadingLocation;
  final VoidCallback onRefreshLocation;

  const _WeatherView({
    required this.currentLocation,
    required this.isLoadingLocation,
    required this.onRefreshLocation,
  });

  @override
  String get title => AppStrings.weatherInsights;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Color? get backgroundColor {
    // Resolved in buildBody; returning null here lets BaseScreen use default.
    // The actual override is applied inside buildBody via theme awareness.
    return null;
  }

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return SafeArea(
      child: Column(
        children: [
          // App Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.dashboard);
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: scheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_outlined,
                      color: scheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              currentLocation,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            if (isLoadingLocation) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Updated just now',
                          style: TextStyle(
                            fontSize: 11,
                            color: isLight
                                ? AppColors.lightSecondaryOnSurface
                                : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isLight
                        ? scheme.surfaceContainerHighest
                        : const Color(0xFF1B192E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLight
                          ? scheme.primary.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: scheme.onSurface,
                      size: 20,
                    ),
                    onPressed: onRefreshLocation,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.15 : 20,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Weather Card
                  _buildHeroCard(context),
                  const SizedBox(height: 18),

                  // AI Daily Recommendation Card
                  _buildAiRecommendationCard(context),
                  const SizedBox(height: 18),

                  // 2x2 Metric Cards Grid
                  _buildMetricsGrid(context),
                  const SizedBox(height: 24),

                  // Hourly Forecast
                  Text(
                    AppStrings.hourlyForecast,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHourlyList(context),
                  const SizedBox(height: 24),

                  // Weekly Forecast
                  Text(
                    AppStrings.weeklyForecast,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyForecast(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  scheme.primary.withValues(alpha: 0.1),
                  scheme.surface,
                ]
              : [
                  const Color(0xFF7C3AED).withValues(alpha: 0.35),
                  const Color(0xFF1E1B38).withValues(alpha: 0.85),
                ],
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '72°',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.partlyCloudy,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: scheme.secondary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLight
                      ? scheme.surfaceContainerHighest.withValues(alpha: 0.7)
                      : const Color(0xFF2E2752).withValues(alpha: 0.7),
                  border: Border.all(
                    color: scheme.secondary.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.wb_cloudy_rounded,
                  size: 42,
                  color: Color(0xFFFBBF24), // Semantic amber — weather sun/cloud icon
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _pillTag(context, 'H: 76°  L: 58°'),
              const SizedBox(width: 10),
              _pillTag(context, 'Air Quality: 32 (Good)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillTag(BuildContext context, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.primary.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? scheme.primary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildAiRecommendationCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [scheme.surfaceContainerHighest, scheme.surface]
              : [const Color(0xFF2E1A47), const Color(0xFF1B1832)],
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: scheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.aiDailyRecommendation,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: scheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.weatherRecommendationBody,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _metricTile(
                context: context,
                icon: Icons.water_drop_outlined,
                title: AppStrings.precipitation,
                value: '0%',
              ),
              const SizedBox(height: 12),
              _metricTile(
                context: context,
                icon: Icons.air_rounded,
                title: AppStrings.windSpeed,
                value: '8 mph',
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _metricTile(
                context: context,
                icon: Icons.waves_rounded,
                title: AppStrings.humidity,
                value: '48%',
              ),
              const SizedBox(height: 12),
              _metricTile(
                context: context,
                icon: Icons.wb_sunny_outlined,
                title: AppStrings.uvIndex,
                value: '6 High',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLight
              ? scheme.primary.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: scheme.secondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyList(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final hours = [
      {'time': AppStrings.now, 'temp': '72°', 'icon': Icons.wb_cloudy_rounded},
      {'time': '2 PM', 'temp': '74°', 'icon': Icons.wb_sunny_rounded},
      {'time': '3 PM', 'temp': '73°', 'icon': Icons.wb_sunny_rounded},
      {'time': '4 PM', 'temp': '70°', 'icon': Icons.wb_cloudy_rounded},
      {'time': '5 PM', 'temp': '68°', 'icon': Icons.cloud_queue_rounded},
      {'time': '6 PM', 'temp': '64°', 'icon': Icons.nights_stay_rounded},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = hours[index];
          final isFirst = index == 0;

          return Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isFirst
                  ? isLight
                      ? scheme.primary.withValues(alpha: 0.1)
                      : const Color(0xFF7C3AED).withValues(alpha: 0.35)
                  : isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF1E1B38).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isFirst
                    ? scheme.primary.withValues(alpha: 0.5)
                    : isLight
                        ? scheme.primary.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight
                        ? AppColors.lightSecondaryOnSurface
                        : AppColors.secondaryText,
                  ),
                ),
                Icon(
                  item['icon'] as IconData,
                  size: 24,
                  color: const Color(0xFFFBBF24), // Semantic amber — weather icon
                ),
                Text(
                  item['temp'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyForecast(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final days = [
      {
        'day': 'Today',
        'status': AppStrings.partlyCloudy,
        'min': '58°',
        'max': '76°',
      },
      {
        'day': 'Saturday',
        'status': AppStrings.sunny,
        'min': '60°',
        'max': '78°',
      },
      {'day': 'Sunday', 'status': AppStrings.sunny, 'min': '62°', 'max': '80°'},
      {
        'day': 'Monday',
        'status': AppStrings.partlyCloudy,
        'min': '57°',
        'max': '71°',
      },
      {
        'day': 'Tuesday',
        'status': AppStrings.rainy,
        'min': '53°',
        'max': '65°',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight
              ? scheme.primary.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: days.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    item['day']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item['status']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.secondary,
                    ),
                  ),
                ),
                Text(
                  '${item['min']} / ${item['max']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
