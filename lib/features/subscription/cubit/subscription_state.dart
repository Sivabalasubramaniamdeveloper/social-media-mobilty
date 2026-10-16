// lib/features/subscription/cubit/subscription_state.dart
import 'package:equatable/equatable.dart';
import '../models/subscription_plan.dart';

/// Base type for loading, loaded, and failed subscription UI states.
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  /// Defines equality for immutable subscription state values.
  @override
  List<Object?> get props => [];
}

/// Indicates the subscription request has not started.
class SubscriptionInitial extends SubscriptionState {}

/// Indicates plan and user subscription data are being loaded.
class SubscriptionLoading extends SubscriptionState {}

/// Holds the current plan plus the selectable plans returned by the API.
class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionPlan plan;
  final int currentCredits;
  final String? planId;
  final List<SubscriptionPlanOption> availablePlans;

  /// Creates a state containing the selected plan and available catalog rows.
  const SubscriptionLoaded({
    required this.plan,
    required this.currentCredits,
    this.planId,
    this.availablePlans = const [],
  });

  /// Includes all displayed fields so plan changes notify every subscriber.
  @override
  List<Object?> get props => [plan, currentCredits, planId, availablePlans];
}

/// Holds a plan catalog row together with its stable database identifier.
class SubscriptionPlanOption {
  final String id;
  final SubscriptionPlan plan;

  /// Creates a selectable plan entry with its persistent database ID.
  const SubscriptionPlanOption({required this.id, required this.plan});
}

/// Carries a localized-safe failure state for subscription screens.
class SubscriptionError extends SubscriptionState {
  final String message;

  /// Creates a failed state with a localized message for the subscription UI.
  const SubscriptionError(this.message);

  /// Includes the message in equality checks so changed errors rebuild the UI.
  @override
  List<Object?> get props => [message];
}
