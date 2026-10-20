import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../models/subscription_plan.dart';

/// Highly attractive, modern subscription plan screen with glassmorphic cards and tier comparisons.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _changingPlanId;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().fetchUserPlan();
  }

  Future<void> _selectPlan(SubscriptionPlanOption option) async {
    setState(() => _changingPlanId = option.id);
    try {
      await context.read<SubscriptionCubit>().changePlan(option.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.planChangedSuccessfully),
          backgroundColor: AppColors.incomeGreenDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.planChangeFailed),
          backgroundColor: AppColors.expenseRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _changingPlanId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppStrings.subscriptionPlan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            );
          }
          if (state is! SubscriptionLoaded) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.expenseRed),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.subscriptionLoadFailed,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<SubscriptionCubit>().fetchUserPlan(),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state.availablePlans.isEmpty) {
            return Center(child: Text(AppStrings.noPlansAvailable));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Banner
                _buildHeaderBanner(context, state),
                const SizedBox(height: 20),

                // 2. Section Heading
                Text(
                  AppStrings.choosePlan,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.planChangeUpdatesImmediately,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.secondaryText : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Plan Cards List
                ...state.availablePlans.map((option) {
                  final isCurrent = option.id == state.planId;
                  final isChanging = _changingPlanId == option.id;
                  return _buildPlanCard(
                    context: context,
                    option: option,
                    isCurrent: isCurrent,
                    isChanging: isChanging,
                    isDark: isDark,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, SubscriptionLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryPurpleDeep,
            AppColors.primaryPurple,
            AppColors.accentBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.upgradeToUnlock,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _planName(state.plan.tier).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.unlockUnlimitedPower,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.accentOrange, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${state.currentCredits} ${AppStrings.aiCredits} ${AppStrings.active.toLowerCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required SubscriptionPlanOption option,
    required bool isCurrent,
    required bool isChanging,
    required bool isDark,
  }) {
    final plan = option.plan;
    final isPro = plan.tier == PlanTier.pro;
    final isPremium = plan.tier == PlanTier.premium;

    Color badgeColor = AppColors.primaryPurple;
    String badgeText = '';
    if (isPro) {
      badgeText = AppStrings.mostPopular;
      badgeColor = AppColors.primaryPurple;
    } else if (isPremium) {
      badgeText = AppStrings.bestValue;
      badgeColor = AppColors.accentOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? AppColors.incomeGreen
              : (isPro ? AppColors.primaryPurple.withValues(alpha: 0.8) : (isDark ? AppColors.cardBorder : Colors.black12)),
          width: isCurrent || isPro ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPro
                ? AppColors.primaryPurple.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tier row with Price and current status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _planName(plan.tier),
                            style: TextStyle(
                              color: isPro
                                  ? AppColors.primaryPurpleLight
                                  : (isPremium ? AppColors.accentOrange : (isDark ? Colors.white : Colors.black87)),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _planPrice(plan.tier),
                            style: TextStyle(
                              color: isDark ? AppColors.secondaryText : Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.incomeGreen.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.incomeGreen),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.incomeGreen, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.currentPlanBadge,
                              style: const TextStyle(
                                color: AppColors.incomeGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 14),

                // Feature items with icons
                _featureItem(
                  context,
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.accentOrange,
                  title: '${plan.dailyCredits} ${AppStrings.dailyAiCreditsFeature}',
                  subtitle: '${plan.dailyCredits} daily refresh',
                ),
                _featureItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.accentBlue,
                  title: '${plan.maxBudgets} ${AppStrings.budgetTrackingFeature}',
                  subtitle: '${plan.monthlyBudgetEdits} ${AppStrings.monthlyBudgetEditsFeature}',
                ),
                _featureItem(
                  context,
                  icon: Icons.storefront_rounded,
                  iconColor: AppColors.primaryPurple,
                  title: '${plan.dailyScrapes} ${AppStrings.smartScrapesFeature}',
                  subtitle: 'Amazon, Flipkart, Meesho deals',
                ),
                _featureItem(
                  context,
                  icon: Icons.cloud_done_rounded,
                  iconColor: plan.cloudSyncEnabled ? AppColors.incomeGreen : Colors.grey,
                  title: plan.cloudSyncEnabled
                      ? AppStrings.cloudSyncIncluded
                      : AppStrings.cloudSyncNotIncluded,
                  enabled: plan.cloudSyncEnabled,
                ),
                _featureItem(
                  context,
                  icon: Icons.photo_library_rounded,
                  iconColor: AppColors.primaryPurpleLight,
                  title: '${plan.diaryImageLimit} ${AppStrings.diaryImagesFeature}',
                  subtitle: plan.isMonthlyImageLimit ? 'Monthly allowance' : 'Total limit',
                ),
                const SizedBox(height: 18),

                // Plan Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? (isDark ? AppColors.surfaceDeep : Colors.grey[200])
                          : (isPro ? AppColors.primaryPurple : (isPremium ? AppColors.accentOrange : AppColors.surfaceElevated)),
                      foregroundColor: isCurrent
                          ? (isDark ? AppColors.secondaryText : Colors.grey[700])
                          : Colors.white,
                      elevation: isCurrent ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: isCurrent
                            ? BorderSide(color: isDark ? AppColors.cardBorder : Colors.black12)
                            : BorderSide.none,
                      ),
                    ),
                    onPressed: isCurrent || _changingPlanId != null
                        ? null
                        : () => _selectPlan(option),
                    child: isChanging
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : Text(
                            isCurrent
                                ? AppStrings.activePlan
                                : (isPro || isPremium ? AppStrings.upgradeNow : AppStrings.switchPlan),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Ribbon badge for Most Popular / Best Value
          if (badgeText.isNotEmpty && !isCurrent)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _featureItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: enabled
                        ? (isDark ? AppColors.whiteColor : Colors.black87)
                        : (isDark ? AppColors.hintText : Colors.grey[500]),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? AppColors.hintText : Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            enabled ? Icons.check_rounded : Icons.close_rounded,
            color: enabled ? AppColors.incomeGreen : Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _planName(PlanTier tier) => switch (tier) {
    PlanTier.basic => AppStrings.basicPlan,
    PlanTier.pro => AppStrings.proPlan,
    PlanTier.premium => AppStrings.premiumPlan,
  };

  String _planPrice(PlanTier tier) => switch (tier) {
    PlanTier.basic => AppStrings.freeForever,
    PlanTier.pro => '₹299 ${AppStrings.perMonth}',
    PlanTier.premium => '₹799 ${AppStrings.perMonth}',
  };
}
