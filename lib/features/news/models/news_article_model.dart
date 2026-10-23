class NewsArticleModel {
  final String id;
  final String title;
  final String link;
  final String pubDate;
  final String source;
  final String snippet;
  final String city;

  NewsArticleModel({
    required this.id,
    required this.title,
    required this.link,
    required this.pubDate,
    required this.source,
    required this.snippet,
    required this.city,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      link: json['link'] as String? ?? '',
      pubDate: json['pubDate'] as String? ?? '',
      source: json['source'] as String? ?? 'Local News',
      snippet: json['snippet'] as String? ?? '',
      city: json['city'] as String? ?? 'Chennai',
    );
  }
}
