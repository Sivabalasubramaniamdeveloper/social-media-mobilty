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
  Color? get backgroundColor => const Color(0xFF0F0E17);

  @override
  Widget buildBody(BuildContext context) {
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF8B5CF6),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (isLoadingLocation) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Updated just now',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
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
                    color: const Color(0xFF1B192E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
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
                  _buildHeroCard(),
                  const SizedBox(height: 18),

                  // AI Daily Recommendation Card
                  _buildAiRecommendationCard(),
                  const SizedBox(height: 18),

                  // 2x2 Metric Cards Grid
                  _buildMetricsGrid(),
                  const SizedBox(height: 24),

                  // Hourly Forecast
                  Text(
                    AppStrings.hourlyForecast,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHourlyList(),
                  const SizedBox(height: 24),

                  // Weekly Forecast
                  Text(
                    AppStrings.weeklyForecast,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyForecast(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7C3AED).withOpacity(0.35),
            const Color(0xFF1E1B38).withOpacity(0.85),
          ],
        ),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.18),
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
                  const Text(
                    '72°',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: AppColors.whiteColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.partlyCloudy,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA78BFA),
                    ),
                  ),
                ],
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E2752).withOpacity(0.7),
                  border: Border.all(
                    color: const Color(0xFFA78BFA).withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.wb_cloudy_rounded,
                  size: 42,
                  color: Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _pillTag('H: 76°  L: 58°'),
              const SizedBox(width: 10),
              _pillTag('Air Quality: 32 (Good)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }

  Widget _buildAiRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1A47), Color(0xFF1B1832)],
        ),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Color(0xFFA78BFA),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.aiDailyRecommendation,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.weatherRecommendationBody,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _metricTile(
                icon: Icons.water_drop_outlined,
                title: AppStrings.precipitation,
                value: '0%',
              ),
              const SizedBox(height: 12),
              _metricTile(
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
                icon: Icons.waves_rounded,
                title: AppStrings.humidity,
                value: '48%',
              ),
              const SizedBox(height: 12),
              _metricTile(
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
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B38).withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFA78BFA)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyList() {
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
                  ? const Color(0xFF7C3AED).withOpacity(0.35)
                  : const Color(0xFF1E1B38).withOpacity(0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isFirst
                    ? AppColors.primaryPurple.withOpacity(0.5)
                    : AppColors.whiteColor.withOpacity(0.06),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                Icon(
                  item['icon'] as IconData,
                  size: 24,
                  color: const Color(0xFFFBBF24),
                ),
                Text(
                  item['temp'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyForecast() {
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
        color: const Color(0xFF1E1B38).withOpacity(0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.06)),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item['status']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFA78BFA),
                    ),
                  ),
                ),
                Text(
                  '${item['min']} / ${item['max']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
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
