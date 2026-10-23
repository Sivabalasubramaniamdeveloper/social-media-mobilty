import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/services/location_service.dart';

import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _currentLocationName = 'Fetching location...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherForCurrentLocation();
    });
  }

  Future<void> _loadWeatherForCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final locDetails = await LocationService.getCurrentStateAndCity();

    if (mounted) {
      setState(() {
        _currentLocationName = locDetails.displayName;
        _isLoadingLocation = false;
      });

      context.read<WeatherCubit>().fetchWeather(
        state: locDetails.state == "ca" ? "tamil-nadu" : locDetails.state,
        city: locDetails.city == 'san-francisco' ? "tenkasi" : locDetails.city,
        day: 'today',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        return _WeatherView(
          currentLocation: _currentLocationName,
          isLoadingLocation: _isLoadingLocation,
          weatherState: state,
          onRefreshLocation: _loadWeatherForCurrentLocation,
        );
      },
    );
  }
}

class _WeatherView extends BaseScreen {
  final String currentLocation;
  final bool isLoadingLocation;
  final WeatherState weatherState;
  final VoidCallback onRefreshLocation;

  const _WeatherView({
    required this.currentLocation,
    required this.isLoadingLocation,
    required this.weatherState,
    required this.onRefreshLocation,
  });

  @override
  String get title => AppStrings.weatherInsights;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Color? get backgroundColor => null;

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return SafeArea(
      child: Column(
        children: [
          // Header Bar
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
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 220),
                              child: Text(
                                currentLocation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
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
                          AppStrings.updatedJustNow,
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

          // Scrollable Content / Shimmer Loader
          Expanded(
            child:
                weatherState is WeatherLoading || weatherState is WeatherInitial
                ? _buildShimmerLoading(context)
                : weatherState is WeatherError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.redColor,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (weatherState as WeatherError).message,
                          style: TextStyle(color: scheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: onRefreshLocation,
                          child: Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => onRefreshLocation(),
                    color: scheme.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCard(
                            context,
                            (weatherState as WeatherLoaded).weather.current,
                          ),
                          const SizedBox(height: 18),
                          _buildAiRecommendationCard(
                            context,
                            (weatherState as WeatherLoaded)
                                .weather
                                .mindAiSuggests,
                          ),
                          const SizedBox(height: 18),
                          _buildMetricsGrid(
                            context,
                            (weatherState as WeatherLoaded).weather.metrics,
                            (weatherState as WeatherLoaded).weather.current,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppStrings.weeklyForecast,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildWeeklyForecast(
                            context,
                            (weatherState as WeatherLoaded).weather.forecast,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHIMMER SKELETON LOADER
  // ---------------------------------------------------------------------------
  Widget _buildShimmerLoading(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight
        ? scheme.surfaceContainerHighest
        : scheme.surfaceContainer;
    final highlightColor = isLight
        ? scheme.surface
        : scheme.surfaceContainerHigh;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card Skeleton
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 18),

            // AI Suggestion Skeleton
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),

            // Metrics 2x2 Grid Skeleton
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Forecast Skeleton Title
            Container(
              height: 20,
              width: 140,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),

            // Forecast List Skeleton
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildHeroCard(BuildContext context, CurrentWeather current) {
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
              ? [scheme.primary.withValues(alpha: 0.12), scheme.surfaceContainerHighest]
              : [
                  scheme.primary.withValues(alpha: 0.35),
                  scheme.surfaceContainer.withValues(alpha: 0.85),
                ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
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
                    current.temp,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    current.condition,
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
                      : scheme.surfaceContainerHigh.withValues(alpha: 0.7),
                  border: Border.all(
                    color: scheme.secondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  _getWeatherIcon(current.condition),
                  size: 42,
                  color: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _pillTag(context, 'H: ${current.high}  L: ${current.low}'),
              const SizedBox(width: 10),
              _pillTag(context, 'Feels Like: ${current.feelsLike}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillTag(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLight
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildAiRecommendationCard(BuildContext context, String suggestion) {
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
              : [scheme.surfaceContainerHigh, scheme.surfaceContainer],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
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
                AppStrings.mindAiSuggests,
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
            '"$suggestion"',
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

  Widget _buildMetricsGrid(
    BuildContext context,
    WeatherMetrics metrics,
    CurrentWeather current,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _metricTile(
                context: context,
                icon: Icons.water_drop_outlined,
                title: AppStrings.precipitation,
                value: current.chanceOfRain,
              ),
              const SizedBox(height: 12),
              _metricTile(
                context: context,
                icon: Icons.air_rounded,
                title: AppStrings.windSpeed,
                value: '${metrics.wind.value} ${metrics.wind.unit}',
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
                value: '${metrics.humidity.value}%',
              ),
              const SizedBox(height: 12),
              _metricTile(
                context: context,
                icon: Icons.wb_sunny_outlined,
                title: AppStrings.uvIndex,
                value: metrics.uvIndex.display,
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
            : scheme.surfaceContainer.withValues(alpha: 0.65),
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

  Widget _buildWeeklyForecast(
    BuildContext context,
    List<DailyForecast> forecast,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : scheme.surfaceContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight
              ? scheme.primary.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: forecast.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    item.day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  _getWeatherIcon(item.condition),
                  size: 20,
                  color: const Color(0xFFFBBF24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.condition,
                    style: TextStyle(fontSize: 13, color: scheme.secondary),
                  ),
                ),
                Text(
                  '${item.high} / ${item.low}',
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

  // ---------------------------------------------------------------------------
  // DART CONTAINS HELPER (FIXES THE COMPILER ERROR)
  // ---------------------------------------------------------------------------
  IconData _getWeatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower.contains('shower')) {
      return Icons.water_drop_rounded;
    } else if (lower.contains('t-storm') || lower.contains('thunder')) {
      return Icons.thunderstorm_rounded;
    } else if (lower.contains('mist') ||
        lower.contains('fog') ||
        lower.contains('haze')) {
      return Icons.cloud_queue_rounded;
    } else if (lower.contains('cloud')) {
      return Icons.wb_cloudy_rounded;
    }
    return Icons.wb_sunny_rounded;
  }
}
