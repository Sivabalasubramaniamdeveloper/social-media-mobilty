import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/logger/app_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:mineai/features/auth/cubit/auth_cubit.dart';
import 'package:mineai/features/auth/repository/auth_repository.dart';
import 'package:mineai/features/auth/services/auth_service.dart';
import 'package:mineai/features/diary/cubit/diary_cubit.dart';
import 'package:mineai/features/diary/repositories/diary_repository.dart';
import 'package:mineai/features/expenses/cubit/finance_cubit.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/repository/user_profile_repository.dart';
import 'package:mineai/features/profile/service/user_profile_service.dart';
import 'package:mineai/features/scraper/cubit/comparison_cubit.dart';
import 'package:mineai/features/scraper/cubit/product_scraper_cubit.dart';
import 'package:mineai/features/scraper/services/comparison_service.dart';
import 'package:mineai/features/scraper/services/product_scraper_service.dart';
import 'package:mineai/features/weather/cubit/weather_cubit.dart';
import 'package:mineai/features/weather/repositories/weather_repository.dart';
import 'package:mineai/features/weather/services/weather_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/responsive/responsive_config.dart';
import '../config/theme/theme_cubit.dart';
import '../core/constants/app_text_styles.dart';
import '../core/network/custom_api_call.dart';
import '../core/utils/secure_storage.dart';
import '../config/supabase/supabase.config.dart';

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
  getIt.registerLazySingleton<SupabaseClient>(() => SupabaseConfig.client);

  // Data Sources
  // Register Auth State Management dependencies
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authService: getIt<AuthService>()),
  );
  getIt.registerLazySingleton<UserProfileService>(() => UserProfileService());

  //==================================
  // Register Services
  //==================================

  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(service: getIt<UserProfileService>()),
  );
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl());
  // lib/instance/locator.dart
  getIt.registerLazySingleton<ExpenseDatabaseService>(
    () => ExpenseDatabaseService.instance,
  );

  //cubit
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(repository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<UserProfileCubit>(
    () => UserProfileCubit(repository: getIt<UserProfileRepository>()),
  );
  getIt.registerFactory<FinanceCubit>(
    () => FinanceCubit(repository: getIt<ExpenseRepository>()),
  );

  // Weather Dependencies
  getIt.registerLazySingleton<WeatherService>(() => WeatherService());
  getIt.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(service: getIt<WeatherService>()),
  );
  getIt.registerFactory<WeatherCubit>(
    () => WeatherCubit(repository: getIt<WeatherRepository>()),
  );
  // Register Scraper Service and Cubit
  getIt.registerLazySingleton<ProductScraperService>(
    () => ProductScraperService(),
  );
  getIt.registerFactory<ProductScraperCubit>(
    () => ProductScraperCubit(service: getIt<ProductScraperService>()),
  );
  getIt.registerLazySingleton<ComparisonService>(() => ComparisonService());
  getIt.registerFactory<ComparisonCubit>(
    () => ComparisonCubit(service: getIt<ComparisonService>()),
  );
  // Diary Module
  getIt.registerLazySingleton<DiaryRepository>(() => DiaryRepositoryImpl());
  getIt.registerFactory<DiaryCubit>(
    () => DiaryCubit(repository: getIt<DiaryRepository>()),
  );
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  await getIt.allReady();
}
