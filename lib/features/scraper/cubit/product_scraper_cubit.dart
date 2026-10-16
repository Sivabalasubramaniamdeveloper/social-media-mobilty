import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/product_scraper_service.dart';
import 'product_scraper_state.dart';

class ProductScraperCubit extends Cubit<ProductScraperState> {
  final ProductScraperService _service;

  ProductScraperCubit({ProductScraperService? service})
    : _service = service ?? ProductScraperService(),
      super(const ProductScraperInitial());

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) return;
    emit(const ProductScraperLoading());

    try {
      final res = await _service.searchProducts(query: query.trim());
      emit(
        ProductScraperLoaded(
          products: res['products'],
          bestDeal: res['bestDeal'],
          showAiSuggestion: false, // Initially hidden until requested by user
        ),
      );
    } catch (e) {
      emit(ProductScraperError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void toggleAiSuggestion() {
    if (state is ProductScraperLoaded) {
      final current = state as ProductScraperLoaded;
      emit(current.copyWith(showAiSuggestion: !current.showAiSuggestion));
    }
  }

  Future<void> runPriceComparison(String query) async {
    if (state is! ProductScraperLoaded) return;
    final current = state as ProductScraperLoaded;

    emit(current.copyWith(isComparing: true));
    try {
      final compData = await _service.compareSingleProduct(query);
      emit(
        current.copyWith(
          comparisonData: compData,
          isComparing: false,
          showAiSuggestion: true, // Auto show comparison insight
        ),
      );
    } catch (e) {
      emit(current.copyWith(isComparing: false));
    }
  }
}
