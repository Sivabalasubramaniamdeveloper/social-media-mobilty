class WeatherResponseModel {
  final String location;
  final String city;
  final String updatedAt;
  final CurrentWeather current;
  final String mindAiSuggests;
  final WeatherMetrics metrics;
  final List<DailyForecast> forecast;

  WeatherResponseModel({
    required this.location,
    required this.city,
    required this.updatedAt,
    required this.current,
    required this.mindAiSuggests,
    required this.metrics,
    required this.forecast,
  });

  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    return WeatherResponseModel(
      location: json['location'] as String? ?? 'tamil-nadu',
      city: json['city'] as String? ?? 'tenkasi',
      updatedAt: json['updatedAt'] as String? ?? 'Updated just now',
      current: CurrentWeather.fromJson(
        json['current'] as Map<String, dynamic>? ?? {},
      ),
      mindAiSuggests:
          json['mindAiSuggests'] as String? ??
          'Clear skies expected. Ideal conditions for outdoor tasks.',
      metrics: WeatherMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>? ?? {},
      ),
      forecast:
          (json['forecast'] as List<dynamic>?)
              ?.map(
                (item) => DailyForecast.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class CurrentWeather {
  final String temp;
  final String condition;
  final String high;
  final String low;
  final String feelsLike;
  final String chanceOfRain;

  CurrentWeather({
    required this.temp,
    required this.condition,
    required this.high,
    required this.low,
    required this.feelsLike,
    required this.chanceOfRain,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: json['temp'] as String? ?? '--°',
      condition: json['condition'] as String? ?? 'Clear Sky',
      high: json['high'] as String? ?? '--°',
      low: json['low'] as String? ?? '--°',
      feelsLike: json['feelsLike'] as String? ?? '--°',
      chanceOfRain: json['chanceOfRain'] as String? ?? '0%',
    );
  }
}

class WeatherMetrics {
  final MetricItem wind;
  final MetricItem humidity;
  final UvIndexMetric uvIndex;

  WeatherMetrics({
    required this.wind,
    required this.humidity,
    required this.uvIndex,
  });

  factory WeatherMetrics.fromJson(Map<String, dynamic> json) {
    return WeatherMetrics(
      wind: MetricItem.fromJson(json['wind'] as Map<String, dynamic>? ?? {}),
      humidity: MetricItem.fromJson(
        json['humidity'] as Map<String, dynamic>? ?? {},
      ),
      uvIndex: UvIndexMetric.fromJson(
        json['uvIndex'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class MetricItem {
  final String value;
  final String unit;
  final double progress;

  MetricItem({required this.value, required this.unit, required this.progress});

  factory MetricItem.fromJson(Map<String, dynamic> json) {
    return MetricItem(
      value: json['value']?.toString() ?? '0',
      unit: json['unit'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class UvIndexMetric {
  final String display;
  final String status;

  UvIndexMetric({required this.display, required this.status});

  factory UvIndexMetric.fromJson(Map<String, dynamic> json) {
    return UvIndexMetric(
      display: json['display'] as String? ?? 'Index (0)',
      status: json['status'] as String? ?? 'SAFE LEVEL',
    );
  }
}

class DailyForecast {
  final String day;
  final String high;
  final String low;
  final String condition;

  DailyForecast({
    required this.day,
    required this.high,
    required this.low,
    required this.condition,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      day: json['day'] as String? ?? 'Today',
      high: json['high'] as String? ?? '--°',
      low: json['low'] as String? ?? '--°',
      condition: json['condition'] as String? ?? 'Clear Sky',
    );
  }
}
