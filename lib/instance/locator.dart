import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:mineai/core/logger/app_logger.dart';
import 'package:get_it/get_it.dart';
import '../config/responsive/responsive_config.dart';
import '../core/constants/app_text_styles.dart';
import '../core/network/custom_api_call.dart';
import '../core/utils/secure_storage.dart';
import '../features/products/data/repositories/product_repository.dart';
import '../features/products/data/services/product_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator(BuildContext context) async {
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<CustomAppLogger>(() => CustomAppLogger());
  getIt.registerLazySingleton<ResponsiveConfig>(
    () => ResponsiveConfig(context),
  );
  getIt.registerLazySingleton<AppTextStyles>(() => AppTextStyles());
  getIt.registerLazySingleton<CustomApiCallService>(
    () => CustomApiCallService(),
  );
  getIt.registerLazySingleton<CustomSecureStorage>(() => CustomSecureStorage());

  //==================================
  // Register Services
  //==================================

  getIt.registerLazySingleton<ProductServiceImp>(() => ProductServiceImp());

  //==================================
  // Register Repositories
  //==================================

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImp(getIt<ProductServiceImp>()),
  );
  await getIt.allReady();
}
