import 'package:dio/dio.dart';
import 'package:mineai/core/constants/api_constants.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/logger/app_logger.dart';
import 'package:mineai/features/products/data/models/product_model.dart';
import '../../../../core/network/custom_api_call.dart';

abstract class ProductService {
  Future<ProductModel> fetchProductsRaw(String token);
}

class ProductServiceImp extends ProductService {
  CustomApiCallService customApiCallService = CustomApiCallService();

  @override
  Future<ProductModel> fetchProductsRaw(String token) async {
    try {
      final response = await customApiCallService.makeApiRequest(
        method: AppStrings.getAPI,
        token: token,
        url: APIConstants.demoAPI,
      );
      if (response.statusCode == 200) {
        final result = response.data;
        return ProductModel.fromJson(result);
      } else {
        CustomAppLogger.error(
          'Failed to load driver data: ${response.statusCode}',
        );
        throw Exception('Failed to load driver data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      CustomAppLogger.error(e);
      throw Exception('${AppStrings.failedToLoad} ${e.error}');
    }
  }
}
