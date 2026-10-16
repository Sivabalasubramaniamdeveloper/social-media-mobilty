import '../models/product_scrape_model.dart';

abstract class ProductScraperState {
  const ProductScraperState();
}

class ProductScraperInitial extends ProductScraperState {
  const ProductScraperInitial();
}

class ProductScraperLoading extends ProductScraperState {
  const ProductScraperLoading();
}

class ProductScraperLoaded extends ProductScraperState {
  final List<ScrapedProduct> products;
  final BestDealInfo? bestDeal;
  final PriceComparisonData? comparisonData;
  final bool isComparing;
  final bool showAiSuggestion;

  const ProductScraperLoaded({
    required this.products,
    this.bestDeal,
    this.comparisonData,
    this.isComparing = false,
    this.showAiSuggestion = false,
  });

  ProductScraperLoaded copyWith({
    List<ScrapedProduct>? products,
    BestDealInfo? bestDeal,
    PriceComparisonData? comparisonData,
    bool? isComparing,
    bool? showAiSuggestion,
  }) {
    return ProductScraperLoaded(
      products: products ?? this.products,
      bestDeal: bestDeal ?? this.bestDeal,
      comparisonData: comparisonData ?? this.comparisonData,
      isComparing: isComparing ?? this.isComparing,
      showAiSuggestion: showAiSuggestion ?? this.showAiSuggestion,
    );
  }
}

class ProductScraperError extends ProductScraperState {
  final String message;
  const ProductScraperError(this.message);
}
