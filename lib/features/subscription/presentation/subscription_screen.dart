import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';

/// Shows the active plan and lets the signed-in user apply another catalog plan.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _changingPlanId;

  /// Loads the current plan and plan catalog when the selector opens.
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().fetchUserPlan();
  }

  /// Saves the selected plan and reports success or failure to the user.
  Future<void> _selectPlan(SubscriptionPlanOption option) async {
    setState(() => _changingPlanId = option.id);
    try {
      await context.read<SubscriptionCubit>().changePlan(option.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.planChangedSuccessfully)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.planChangeFailed)));
    } finally {
      if (mounted) setState(() => _changingPlanId = null);
    }
  }

  /// Renders the current subscription and every plan returned by the API.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.subscriptionPlan)),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }
          if (state is! SubscriptionLoaded) {
            return Center(child: Text(AppStrings.subscriptionLoadFailed));
          }
          if (state.availablePlans.isEmpty) {
            return Center(child: Text(AppStrings.noPlansAvailable));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(AppStrings.choosePlan, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                AppStrings.planChangeUpdatesImmediately,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...state.availablePlans.map((option) {
                final plan = option.plan;
                final isCurrent = option.id == state.planId;
                final isChanging = _changingPlanId == option.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _planName(plan.tier),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Chip(
                                label: Text(AppStrings.currentPlan),
                                backgroundColor: scheme.secondaryContainer,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _featureRow(
                          context,
                          '${plan.maxBudgets} ${AppStrings.budgets}',
                        ),
                        _featureRow(
                          context,
                          '${plan.monthlyBudgetEdits} ${AppStrings.budgetEditsMonthly}',
                        ),
                        _featureRow(
                          context,
                          '${plan.dailyCredits} ${AppStrings.aiCredits}',
                        ),
                        _featureRow(
                          context,
                          plan.cloudSyncEnabled
                              ? AppStrings.cloudSyncIncluded
                              : AppStrings.cloudSyncNotIncluded,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isCurrent || _changingPlanId != null
                                ? null
                                : () => _selectPlan(option),
                            child: isChanging
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isCurrent
                                        ? AppStrings.currentPlan
                                        : AppStrings.selectPlan,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  /// Formats a single entitlement row with theme-aware icon and text colors.
  Widget _featureRow(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  /// Converts a tier enum into the localized display label.
  String _planName(PlanTier tier) => switch (tier) {
    PlanTier.basic => AppStrings.basicPlan,
    PlanTier.pro => AppStrings.proPlan,
    PlanTier.premium => AppStrings.premiumPlan,
  };
}
