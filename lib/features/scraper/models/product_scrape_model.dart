class ScrapedProduct {
  final String id;
  final String store;
  final String title;
  final int price;
  final String formattedPrice;
  final String? rating;
  final String productUrl;
  final String? imageUrl;

  ScrapedProduct({
    required this.id,
    required this.store,
    required this.title,
    required this.price,
    required this.formattedPrice,
    this.rating,
    required this.productUrl,
    this.imageUrl,
  });

  factory ScrapedProduct.fromJson(Map<String, dynamic> json) {
    return ScrapedProduct(
      id: json['id']?.toString() ?? '',
      store: json['store'] as String? ?? 'Store',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      formattedPrice: json['formattedPrice'] as String? ?? '₹0',
      rating: json['rating']?.toString(),
      productUrl: json['productUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class BestDealInfo {
  final String store;
  final String title;
  final int price;
  final String formattedPrice;
  final String productUrl;

  BestDealInfo({
    required this.store,
    required this.title,
    required this.price,
    required this.formattedPrice,
    required this.productUrl,
  });

  factory BestDealInfo.fromJson(Map<String, dynamic> json) {
    return BestDealInfo(
      store: json['store'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      formattedPrice: json['formattedPrice'] as String? ?? '₹0',
      productUrl: json['productUrl'] as String? ?? '',
    );
  }
}

class PriceComparisonData {
  final String query;
  final String? priceDifference;
  final String? savingsPercentage;
  final String? bestDealMessage;
  final String? bestDealStore;
  final Map<String, dynamic> comparisons;

  PriceComparisonData({
    required this.query,
    this.priceDifference,
    this.savingsPercentage,
    this.bestDealMessage,
    this.bestDealStore,
    required this.comparisons,
  });

  factory PriceComparisonData.fromJson(Map<String, dynamic> json) {
    final bestDeal = json['bestDeal'] as Map<String, dynamic>?;
    return PriceComparisonData(
      query: json['query'] as String? ?? '',
      priceDifference: json['priceDifference'] as String?,
      savingsPercentage: json['savingsPercentage'] as String?,
      bestDealMessage: bestDeal?['message'] as String?,
      bestDealStore: bestDeal?['store'] as String?,
      comparisons: json['comparisons'] as Map<String, dynamic>? ?? {},
    );
  }
}
