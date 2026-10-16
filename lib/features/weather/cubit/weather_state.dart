import '../models/weather_model.dart';

abstract class WeatherState {
  const WeatherState();
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherLoaded extends WeatherState {
  final WeatherResponseModel weather;
  const WeatherLoaded(this.weather);
}

class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);
}
