import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/services/location_service.dart';
import '../services/news_service.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsService _newsService;

  NewsCubit({NewsService? newsService})
      : _newsService = newsService ?? NewsService(),
        super(const NewsInitial());

  Future<void> loadNews({String? city, String? provider}) async {
    emit(const NewsLoading());
    try {
      String resolvedCity = city?.trim() ?? '';
      if (resolvedCity.isEmpty && state is NewsLoaded) {
        resolvedCity = (state as NewsLoaded).city;
      }

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

      final resolvedProvider = provider ?? (state is NewsLoaded ? (state as NewsLoaded).provider : 'all');
      final articles = await _newsService.fetchCityNews(
        resolvedCity,
        provider: resolvedProvider,
      );

      emit(NewsLoaded(
        city: resolvedCity,
        provider: resolvedProvider,
        articles: articles,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}
