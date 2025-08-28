import 'package:flutter_automation/core/logger/app_logger.dart';
import '../../../../core/error/api_failure.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductModel>> getProducts();
}

class ProductRepositoryImp extends ProductRepository {
  final ProductService _service;

  ProductRepositoryImp(this._service);

  @override
  Future<Either<Failure, ProductModel>> getProducts() async {
    try {
      final response = await _service.fetchProductsRaw('s');
      return Right(response);
    } catch (e) {
      CustomAppLogger.error("Repository Error: $e", "Repository Error:");
      return Left(Failure(message: e.toString()));
    }
  }
}
