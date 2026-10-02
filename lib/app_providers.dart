import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
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
  ];
}
