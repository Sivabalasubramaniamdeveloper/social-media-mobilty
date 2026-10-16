import '../models/price_compare_model.dart';

abstract class ComparisonState {
  const ComparisonState();
}

class ComparisonInitial extends ComparisonState {
  const ComparisonInitial();
}

class ComparisonLoading extends ComparisonState {
  const ComparisonLoading();
}

class ComparisonLoaded extends ComparisonState {
  final DetailedComparisonModel data;
  const ComparisonLoaded(this.data);
}

class ComparisonError extends ComparisonState {
  final String message;
  const ComparisonError(this.message);
}
