import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/app_widgets.dart';
import 'package:mineai/features/profile/models/user_profile_model.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends BaseScreen {
  const _ProfileView();

  @override
  String get title => AppStrings.profile;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return SafeArea(
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }

          final UserProfileModel? profile = state is UserProfileLoaded
              ? state.profile
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                AppScreenHeader(title: AppStrings.profile),
                const SizedBox(height: 16),

                // Avatar with Verified Badge
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.4),
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              profile?.avatarUrl ??
                                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => context.push(RouteNames.editProfile),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // User Full Name & Pro Plan Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile?.fullName ?? 'User Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFF2E2752),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppStrings.proPlan,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: scheme.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  profile?.email ?? 'user@mindai.io',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                // Edit Profile Button
                // SizedBox(
                //   width: 140,
                //   height: 40,
                //   child: ElevatedButton(
                //     onPressed: () => context.push(RouteNames.editProfile),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color(0xFF7C3AED),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       elevation: 0,
                //     ),
                //     child: Text(
                //       AppStrings.editProfile,
                //       style: const TextStyle(
                //         fontSize: 13,
                //         fontWeight: FontWeight.w600,
                //         color: AppColors.whiteColor,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 24),

                // 2x2 Metric Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.auto_awesome,
                        title: AppStrings.prompts,
                        value: '1,250',
                        delta: '+12%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.access_time_rounded,
                        title: AppStrings.timeSaved,
                        value: '42h',
                        delta: '+5%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.local_fire_department_rounded,
                        title: AppStrings.streak,
                        value: '15 days',
                        subtext: AppStrings.top5PercentUsers,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.psychology_rounded,
                        title: AppStrings.topModel,
                        value: 'GPT-4o',
                        subtext: AppStrings.highEfficiency,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Credits Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isLight
                        ? scheme.surfaceContainerHighest
                        : const Color(0xFF1E1B38).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLight
                          ? scheme.primary.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.token_rounded,
                                size: 18,
                                color: scheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${profile?.credits ?? 1250} ${AppStrings.aiCredits}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? scheme.surfaceContainerHighest
                                  : const Color(0xFF2E2752),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppStrings.active,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: scheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.creditsRenewOn,
                        style: TextStyle(
                          fontSize: 11,
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.65,
                          minHeight: 6,
                          backgroundColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF2E2752),
                          valueColor: AlwaysStoppedAnimation(scheme.primary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.monthlyLimitUsed,
                            style: TextStyle(
                              fontSize: 11,
                              color: isLight
                                  ? AppColors.lightSecondaryOnSurface
                                  : AppColors.secondaryText,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                            ),
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: scheme.onPrimary,
                            ),
                            label: Text(
                              AppStrings.topUp,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: scheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Upgrade to MindAI Ultra Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.upgradeToMindAiUltra,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: scheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.unlimitedPromptsEarlyAccess,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.primary.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: scheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    String? delta,
    String? subtext,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLight
              ? scheme.primary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: scheme.secondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          if (delta != null)
            Text(
              delta,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF34D399), // semantic income-green, kept as-is
              ),
            )
          else if (subtext != null)
            Text(
              subtext,
              style: TextStyle(
                fontSize: 11,
                color: isLight
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }
}
