import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';

class CreditsTrackerCard extends StatelessWidget {
  final bool compact;

  const CreditsTrackerCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        int credits = 100;
        int limit = 100;
        int usedToday = 0;
        String? countdown;

        if (state is UserProfileLoaded) {
          credits = state.profile.credits;
          limit = state.profile.dailyCreditLimit > 0
              ? state.profile.dailyCreditLimit
              : 100;
          usedToday = state.profile.creditsUsedToday;
          countdown = state.profile.creditsRechargeCountdown;
        }

        final double ratio = limit > 0 ? (credits / limit).clamp(0.0, 1.0) : 1.0;
        final bool isExhausted = credits <= 0;

        // Auto-calculate fallback countdown if null
        if (countdown == null || countdown.isEmpty) {
          final now = DateTime.now().toUtc();
          final nextReset = DateTime.utc(now.year, now.month, now.day + 1);
          final diff = nextReset.difference(now);
          countdown = '${diff.inHours}h ${diff.inMinutes % 60}m';
        }

        if (compact) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLight ? scheme.surfaceContainerHighest : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExhausted
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : scheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExhausted ? Icons.timer_outlined : Icons.bolt_rounded,
                  size: 16,
                  color: isExhausted ? Colors.redAccent : AppColors.accentLavender,
                ),
                const SizedBox(width: 6),
                Text(
                  isExhausted
                      ? '0 Credits • Recharges in $countdown'
                      : '$credits / $limit Credits Left',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isExhausted ? Colors.redAccent : scheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight
                ? scheme.surfaceContainerHighest
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExhausted
                  ? Colors.redAccent.withValues(alpha: 0.6)
                  : (isLight
                      ? scheme.outlineVariant.withValues(alpha: 0.4)
                      : scheme.primary.withValues(alpha: 0.25)),
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
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isExhausted
                              ? Colors.redAccent.withValues(alpha: 0.15)
                              : scheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isExhausted ? Icons.lock_clock : Icons.auto_awesome_rounded,
                          size: 16,
                          color: isExhausted ? Colors.redAccent : scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily AI Credits',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push(RouteNames.subscription),
                    child: Text(
                      'Upgrade Plan →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$credits Credits Remaining',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isExhausted ? Colors.redAccent : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$usedToday credits used today of $limit daily quota',
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
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: isLight
                      ? Colors.grey.withValues(alpha: 0.2)
                      : Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isExhausted
                        ? Colors.redAccent
                        : (ratio < 0.25 ? Colors.orangeAccent : scheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: isExhausted ? Colors.redAccent : Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isExhausted
                        ? 'Quota exhausted! Full recharge in $countdown (00:00 UTC)'
                        : 'Recharges daily to $limit credits in $countdown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isExhausted ? FontWeight.bold : FontWeight.normal,
                      color: isExhausted
                          ? Colors.redAccent
                          : (isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
