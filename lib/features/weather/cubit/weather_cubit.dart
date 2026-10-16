import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository _repository;

  WeatherCubit({required WeatherRepository repository})
    : _repository = repository,
      super(const WeatherInitial());

  Future<void> fetchWeather({
    required String state,
    required String city,
    String day = 'today',
  }) async {
    emit(const WeatherLoading());
    try {
      final weather = await _repository.getWeather(
        state: state,
        city: city,
        day: day,
      );
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
