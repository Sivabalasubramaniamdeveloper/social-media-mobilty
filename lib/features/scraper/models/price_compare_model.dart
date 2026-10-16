class StoreProductDetail {
  final String store;
  final bool found;
  final String title;
  final int? price;
  final String currency;
  final String formattedPrice;
  final String? rating;
  final String productUrl;
  final String? imageUrl;

  StoreProductDetail({
    required this.store,
    required this.found,
    required this.title,
    this.price,
    required this.currency,
    required this.formattedPrice,
    this.rating,
    required this.productUrl,
    this.imageUrl,
  });

  factory StoreProductDetail.fromJson(Map<String, dynamic> json) {
    return StoreProductDetail(
      store: json['store'] as String? ?? 'Store',
      found: json['found'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toInt(),
      currency: json['currency'] as String? ?? 'INR',
      formattedPrice: json['formattedPrice'] as String? ?? 'Unavailable',
      rating: json['rating']?.toString(),
      productUrl: json['productUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class BestDealVerdict {
  final String store;
  final int savings;
  final String formattedSavings;
  final String message;

  BestDealVerdict({
    required this.store,
    required this.savings,
    required this.formattedSavings,
    required this.message,
  });

  factory BestDealVerdict.fromJson(Map<String, dynamic> json) {
    return BestDealVerdict(
      store: json['store'] as String? ?? '',
      savings: (json['savings'] as num?)?.toInt() ?? 0,
      formattedSavings: json['formattedSavings'] as String? ?? '₹0',
      message: json['message'] as String? ?? '',
    );
  }
}

class DetailedComparisonModel {
  final String query;
  final String searchedAt;
  final BestDealVerdict? bestDeal;
  final String? priceDifference;
  final String? savingsPercentage;
  final List<StoreProductDetail> stores;

  DetailedComparisonModel({
    required this.query,
    required this.searchedAt,
    this.bestDeal,
    this.priceDifference,
    this.savingsPercentage,
    required this.stores,
  });

  factory DetailedComparisonModel.fromJson(Map<String, dynamic> json) {
    final comparisonsMap = json['comparisons'] as Map<String, dynamic>? ?? {};
    final List<StoreProductDetail> storeList = [];

    comparisonsMap.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        storeList.add(StoreProductDetail.fromJson(val));
      }
    });

    return DetailedComparisonModel(
      query: json['query'] as String? ?? '',
      searchedAt: json['searchedAt'] as String? ?? '',
      bestDeal: json['bestDeal'] != null
          ? BestDealVerdict.fromJson(json['bestDeal'] as Map<String, dynamic>)
          : null,
      priceDifference: json['priceDifference'] as String?,
      savingsPercentage: json['savingsPercentage'] as String?,
      stores: storeList,
    );
  }
}
