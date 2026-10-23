import 'package:equatable/equatable.dart';
import '../models/news_article_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsLoaded extends NewsState {
  final String city;
  final List<NewsArticleModel> articles;

  const NewsLoaded({required this.city, required this.articles});

  @override
  List<Object?> get props => [city, articles];
}

class NewsError extends NewsState {
  final String message;
  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
