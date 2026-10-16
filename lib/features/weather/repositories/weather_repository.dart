import '../models/weather_model.dart';
import '../services/weather_service.dart';

abstract class WeatherRepository {
  Future<WeatherResponseModel> getWeather({
    required String state,
    required String city,
    String day,
  });
}

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService _service;

  WeatherRepositoryImpl({WeatherService? service})
    : _service = service ?? WeatherService();

  @override
  Future<WeatherResponseModel> getWeather({
    required String state,
    required String city,
    String day = 'today',
  }) {
    return _service.fetchWeather(state: state, city: city, day: day);
  }
}
