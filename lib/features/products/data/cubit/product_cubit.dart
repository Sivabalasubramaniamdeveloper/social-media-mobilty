import 'package:mineai/core/logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit(this.repository) : super(ProductInitialState());

  Future<void> fetchProducts() async {
    try {
      emit(ProductLoadingState());
      var response = await repository.getProducts();

      response.fold(
        (failure) {
          emit(ProductErrorState(message: failure.message));
        },
        (data) {
          emit(ProductSuccessState(products: data));
        },
      );
    } catch (e) {
      CustomAppLogger.error(e, "ProductModel cubit");
      emit(ProductErrorState(message: e.toString())); // 🔥 Ensure this fires
    }
  }
}
