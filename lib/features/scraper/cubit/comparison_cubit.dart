import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/comparison_service.dart';
import 'comparison_state.dart';

class ComparisonCubit extends Cubit<ComparisonState> {
  final ComparisonService _service;

  ComparisonCubit({ComparisonService? service})
    : _service = service ?? ComparisonService(),
      super(const ComparisonInitial());

  Future<void> runComparison(String query) async {
    if (query.trim().isEmpty) return;
    emit(const ComparisonLoading());
    try {
      final result = await _service.comparePrice(query);
      emit(ComparisonLoaded(result));
    } catch (e) {
      emit(ComparisonError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
