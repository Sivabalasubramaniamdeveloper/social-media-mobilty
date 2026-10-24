import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/app_widgets.dart';
import 'package:mineai/features/profile/models/user_profile_model.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Reloads the plan and profile on entry so external changes appear immediately.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SubscriptionCubit>().fetchUserPlan();
        context.read<UserProfileCubit>().loadProfile();
      }
    });
  }

  /// Creates the shared profile view after scheduling refreshes.
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
  /// Builds profile content and reads subscription status from the shared API-backed cubit.
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return SafeArea(
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return _buildProfileSkeleton(context, scheme, isLight);
          }

          if (state is UserProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: scheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<UserProfileCubit>().loadProfile(),
                      child: Text(AppStrings.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          final UserProfileModel? profile =
              state is UserProfileLoaded ? state.profile : null;

          final creditLimit = (profile?.dailyCreditLimit != null &&
                  profile!.dailyCreditLimit > 0)
              ? profile.dailyCreditLimit
              : 100;
          final currentCredits = profile?.credits ?? 100;
          final double rawRatio = currentCredits / creditLimit;
          final double creditProgress =
              rawRatio.isNaN ? 1.0 : rawRatio.clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                AppScreenHeader(
                  title: AppStrings.profile,
                  trailing: IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: scheme.onSurface,
                    ),
                    onPressed: () => context.push(RouteNames.settings),
                  ),
                ),
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
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF2E2752),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildAvatar(profile?.avatarUrl, scheme),
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

                // Show the user's name beside the plan tier loaded from the API.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile?.fullName.isNotEmpty == true
                          ? profile!.fullName
                          : 'User Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<SubscriptionCubit, SubscriptionState>(
                      builder: (context, subscriptionState) {
                        if (subscriptionState is! SubscriptionLoaded) {
                          return const SizedBox.shrink();
                        }
                        return Container(
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
                            _planName(subscriptionState.plan.tier),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: scheme.secondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  profile?.email.isNotEmpty == true
                      ? profile!.email
                      : 'user@mineai.io',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (profile?.phone != null && profile!.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: isLight
                            ? AppColors.lightSecondaryOnSurface
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.phone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 18),

                // Real Account Info Details Card
                Container(
                  width: double.infinity,
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
                          Text(
                            AppStrings.account,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(Icons.edit_outlined,
                                size: 14, color: scheme.primary),
                            label: Text(
                              AppStrings.edit,
                              style: TextStyle(
                                  fontSize: 12, color: scheme.primary),
                            ),
                            onPressed: () =>
                                context.push(RouteNames.editProfile),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.person_outline_rounded,
                        label: AppStrings.username,
                        value: profile?.username.isNotEmpty == true
                            ? '@${profile!.username}'
                            : '@user',
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.alternate_email_rounded,
                        label: AppStrings.emailAddress,
                        value: profile?.email.isNotEmpty == true
                            ? profile!.email
                            : '—',
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.phone_outlined,
                        label: AppStrings.phoneNumber,
                        value: (profile?.phone != null &&
                                profile!.phone!.isNotEmpty)
                            ? profile.phone!
                            : AppStrings.notSpecified,
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.schedule_rounded,
                        label: AppStrings.timezone,
                        value: profile?.timezone?.isNotEmpty == true
                            ? profile!.timezone!
                            : 'Asia/Kolkata',
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.public_rounded,
                        label: AppStrings.country,
                        value: profile?.countryCode?.isNotEmpty == true
                            ? profile!.countryCode!
                            : 'India (IN)',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Real AI Credits Card
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
                                '$currentCredits / $creditLimit ${AppStrings.aiCredits}',
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
                      const SizedBox(height: 6),
                      Text(
                        (profile?.creditsRechargeCountdown != null &&
                                profile!.creditsRechargeCountdown!.isNotEmpty)
                            ? 'Recharges in ${profile.creditsRechargeCountdown}'
                            : AppStrings.creditsRenewOn,
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
                          value: creditProgress,
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
                            'Used Today: ${profile?.creditsUsedToday ?? 0}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isLight
                                  ? AppColors.lightSecondaryOnSurface
                                  : AppColors.secondaryText,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.subscription),
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
                              Icons.upgrade_rounded,
                              size: 16,
                              color: scheme.onPrimary,
                            ),
                            label: Text(
                              AppStrings.viewPlans,
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

                // Upgrade to MineAI Ultra Banner
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

  Widget _buildAvatar(String? url, ColorScheme scheme) {
    final cleanUrl = url?.trim();
    if (cleanUrl != null && cleanUrl.startsWith('http')) {
      return Image.network(
        cleanUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackAvatar(scheme),
      );
    }
    return _fallbackAvatar(scheme);
  }

  Widget _fallbackAvatar(ColorScheme scheme) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: 56,
        color: scheme.primary.withValues(alpha: 0.8),
      ),
    );
  }

  /// Maps the API plan tier to the active app language.
  String _planName(PlanTier tier) => switch (tier) {
    PlanTier.basic => AppStrings.basicPlan,
    PlanTier.pro => AppStrings.proPlan,
    PlanTier.premium => AppStrings.premiumPlan,
  };

  /// Builds a clean informational data row for the user profile.
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final secondaryColor = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSkeleton(
    BuildContext context,
    ColorScheme scheme,
    bool isLight,
  ) {
    final baseColor = isLight ? Colors.grey[300]! : const Color(0xFF1E1B38);
    final highlightColor = isLight ? Colors.grey[100]! : const Color(0xFF2E2752);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Header skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Avatar skeleton
            Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 14),

            // Name bar skeleton
            Container(
              width: 160,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),

            // Email bar skeleton
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),

            // Account details card skeleton
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Credits card skeleton
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
