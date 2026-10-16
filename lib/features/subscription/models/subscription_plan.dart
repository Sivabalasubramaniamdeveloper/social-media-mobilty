// lib/features/subscription/models/subscription_plan.dart
enum PlanTier { basic, pro, premium }

class SubscriptionPlan {
  final PlanTier tier;
  final int dailyCredits;
  final int maxBudgets;
  final int monthlyBudgetEdits;
  final bool cloudSyncEnabled;
  final int diaryImageLimit;
  final bool isMonthlyImageLimit; // true = monthly, false = total
  final int dailyScrapes;

  const SubscriptionPlan({
    required this.tier,
    required this.dailyCredits,
    required this.maxBudgets,
    required this.monthlyBudgetEdits,
    required this.cloudSyncEnabled,
    required this.diaryImageLimit,
    required this.isMonthlyImageLimit,
    required this.dailyScrapes,
  });

  factory SubscriptionPlan.fromTierCode(int code) {
    switch (code) {
      case 1:
        return const SubscriptionPlan(
          tier: PlanTier.pro,
          dailyCredits: 1000,
          maxBudgets: 10,
          monthlyBudgetEdits: 10,
          cloudSyncEnabled: true,
          diaryImageLimit: 10,
          isMonthlyImageLimit: true,
          dailyScrapes: 10,
        );
      case 2:
        return const SubscriptionPlan(
          tier: PlanTier.premium,
          dailyCredits: 5000,
          maxBudgets: 30,
          monthlyBudgetEdits: 30,
          cloudSyncEnabled: true,
          diaryImageLimit: 30,
          isMonthlyImageLimit: true,
          dailyScrapes: 25,
        );
      case 0:
      default:
        return const SubscriptionPlan(
          tier: PlanTier.basic,
          dailyCredits: 100,
          maxBudgets: 4,
          monthlyBudgetEdits: 5,
          cloudSyncEnabled: false,
          diaryImageLimit: 5,
          isMonthlyImageLimit: false,
          dailyScrapes: 2,
        );
    }
  }
}
