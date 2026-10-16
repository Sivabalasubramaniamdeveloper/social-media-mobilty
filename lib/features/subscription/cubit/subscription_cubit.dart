// lib/features/subscription/cubit/subscription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/constants/app_strings.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionService _service;

  SubscriptionCubit({SubscriptionService? service})
    : _service = service ?? SubscriptionService(),
      super(SubscriptionInitial());

  /// Fetches the latest plan catalog and resolves the user's plan foreign key.
  Future<void> fetchUserPlan() async {
    emit(SubscriptionLoading());
    try {
      // The authenticated API avoids client database-policy restrictions and reads the latest DB assignment.
      final payload = await _service.fetchPlanData();
      final catalog = payload['plans'] as List<dynamic>;
      final availablePlans = catalog
          .map(
            (row) => SubscriptionPlanOption(
              id: row['id'].toString(),
              plan: SubscriptionPlan.fromTierCode(
                (row['tier_code'] as num?)?.toInt() ?? 0,
              ),
            ),
          )
          .toList(growable: false);

      final userRes = payload['user'] as Map<String, dynamic>;
      final credits = (userRes['credits'] as num?)?.toInt() ?? 100;
      final planId = userRes['plan_id'] as String?;
      // Resolve the tier from the fresh catalog by the stored foreign key so DB changes appear on reload.
      final selectedRow = catalog.whereType<Map<String, dynamic>>().firstWhere(
        (row) => row['id']?.toString() == planId,
        orElse: () => <String, dynamic>{},
      );
      final tierCode = (selectedRow['tier_code'] as num?)?.toInt() ?? 0;

      emit(
        SubscriptionLoaded(
          plan: SubscriptionPlan.fromTierCode(tierCode),
          currentCredits: credits,
          planId: planId,
          availablePlans: availablePlans,
        ),
      );
    } catch (_) {
      emit(SubscriptionError(AppStrings.subscriptionLoadFailed));
    }
  }

  /// Persists the selected foreign key, then emits the server-confirmed plan immediately.
  Future<void> changePlan(String planId) async {
    final current = state;
    if (current is! SubscriptionLoaded) {
      throw StateError(AppStrings.planChangeFailed);
    }
    final selected = current.availablePlans.where(
      (option) => option.id == planId,
    );
    if (selected.isEmpty) {
      throw ArgumentError(AppStrings.planChangeFailed);
    }

    final user = await _service.updatePlan(planId);
    final joinedPlan = user['plans'];
    final tierCode = joinedPlan is Map<String, dynamic>
        ? (joinedPlan['tier_code'] as num?)?.toInt() ??
              selected.first.plan.tier.index
        : selected.first.plan.tier.index;
    emit(
      SubscriptionLoaded(
        plan: SubscriptionPlan.fromTierCode(tierCode),
        currentCredits:
            (user['credits'] as num?)?.toInt() ?? current.currentCredits,
        planId: user['plan_id'] as String? ?? planId,
        availablePlans: current.availablePlans,
      ),
    );
  }
}
