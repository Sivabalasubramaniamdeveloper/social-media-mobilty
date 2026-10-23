import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/services/location_service.dart';
import '../services/news_service.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsService _newsService;

  NewsCubit({NewsService? newsService})
      : _newsService = newsService ?? NewsService(),
        super(const NewsInitial());

  Future<void> loadNews({String? city}) async {
    emit(const NewsLoading());
    try {
      String resolvedCity = city?.trim() ?? '';
      if (resolvedCity.isEmpty) {
        try {
          final loc = await LocationService.getCurrentStateAndCity();
          if (loc.city.isNotEmpty && loc.city != 'Unknown') {
            resolvedCity = loc.city;
          }
        } catch (_) {}
      }

      if (resolvedCity.isEmpty) {
        resolvedCity = 'Chennai';
      }

      final articles = await _newsService.fetchCityNews(resolvedCity);
      emit(NewsLoaded(city: resolvedCity, articles: articles));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}
