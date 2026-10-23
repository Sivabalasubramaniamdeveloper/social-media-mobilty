import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/features/diary/cubit/diary_cubit.dart';
import 'package:mineai/features/email_helper/cubit/email_helper_cubit.dart';
import 'package:mineai/features/expenses/cubit/finance_cubit.dart';
import 'package:mineai/features/news/cubit/news_cubit.dart';
import 'package:mineai/features/scraper/cubit/comparison_cubit.dart';
import 'package:mineai/features/scraper/cubit/product_scraper_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/tasks/cubit/task_cubit.dart';
import 'package:mineai/features/vault/cubit/vault_cubit.dart';
import 'package:mineai/features/weather/cubit/weather_cubit.dart';
import 'package:provider/single_child_widget.dart';
import 'config/theme/theme_cubit.dart';
import 'core/network/internet_connectivity.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/profile/cubit/user_profile_cubit.dart';
import 'instance/locator.dart';

List<SingleChildWidget> getAppProviders() {
  return [
    // Repositories
    BlocProvider(create: (_) => ConnectivityCubit()),
    BlocProvider(create: (_) => getIt<AuthCubit>()),
    BlocProvider(create: (_) => getIt<UserProfileCubit>()),
    BlocProvider(create: (_) => getIt<FinanceCubit>()),
    BlocProvider(create: (_) => getIt<ThemeCubit>()),
    BlocProvider(create: (_) => getIt<WeatherCubit>()),
    BlocProvider(create: (_) => getIt<ProductScraperCubit>()),
    BlocProvider(create: (_) => getIt<ComparisonCubit>()),
    BlocProvider(create: (_) => getIt<DiaryCubit>()),
    // In lib/app_providers.dart
    BlocProvider(create: (_) => SubscriptionCubit()..fetchUserPlan()),
    BlocProvider(create: (_) => EmailHelperCubit()),
    BlocProvider(create: (_) => TaskCubit()),
    BlocProvider(create: (_) => NewsCubit()),
    BlocProvider(create: (_) => VaultCubit()),
  ];
}
