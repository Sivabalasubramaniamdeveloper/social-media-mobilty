import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/support/models/ticket_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return AppColors.incomeGreen;
      case 'closed':
        return AppColors.secondaryText;
      case 'open':
      default:
        return AppColors.expenseOrange;
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 2;
      case 'resolved':
      case 'closed':
        return 3;
      case 'open':
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final statusColor = _getStatusColor(ticket.status);
    final stepIndex = _getStatusStepIndex(ticket.status);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.sm,
                ),
                child: AppScreenHeader(
                  title: ticket.id,
                  titleSize: 18,
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Tracker Banner
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isLight ? scheme.surface : const Color(0xFF1E1B38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isLight
                                ? scheme.outlineVariant.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.ticketStatus,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    ticket.status.replaceAll('_', ' ').toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Progress Steps (Submitted -> Reviewing -> In Progress -> Resolved)
                            Row(
                              children: [
                                _buildStep(
                                  index: 1,
                                  currentStep: stepIndex,
                                  label: AppStrings.stepSubmitted,
                                  scheme: scheme,
                                ),
                                _buildStepConnector(stepIndex >= 2),
                                _buildStep(
                                  index: 2,
                                  currentStep: stepIndex,
                                  label: AppStrings.stepInProgress,
                                  scheme: scheme,
                                ),
                                _buildStepConnector(stepIndex >= 3),
                                _buildStep(
                                  index: 3,
                                  currentStep: stepIndex,
                                  label: AppStrings.stepResolved,
                                  scheme: scheme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Admin Update Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primaryPurple.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.support_agent_rounded,
                                  color: AppColors.primaryPurpleLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.adminTeamResponse,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryPurpleLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ticket.adminNotes ?? AppStrings.adminReviewingNotice,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: scheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Issue Overview Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isLight ? scheme.surface : const Color(0xFF1E1B38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isLight
                                ? scheme.outlineVariant.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.subject,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Metadata Badges
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _badge(
                                  ticket.module.replaceAll('_', ' ').toUpperCase(),
                                  Icons.layers_rounded,
                                  scheme,
                                ),
                                _badge(
                                  ticket.category.replaceAll('_', ' ').toUpperCase(),
                                  Icons.category_rounded,
                                  scheme,
                                ),
                                _badge(
                                  'PRIORITY: ${ticket.priority.toUpperCase()}',
                                  Icons.flag_rounded,
                                  scheme,
                                  color: ticket.priority.toLowerCase() == 'high'
                                      ? AppColors.expenseRed
                                      : null,
                                ),
                              ],
                            ),

                            const Divider(height: 28),

                            Text(
                              AppStrings.issueDescription,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.description,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.55,
                                color: scheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Created: ${DateFormat('MMM dd, yyyy · hh:mm a').format(ticket.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurface.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required int index,
    required int currentStep,
    required String label,
    required ColorScheme scheme,
  }) {
    final isDone = currentStep >= index;
    final isCurrent = currentStep == index;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.primaryPurple
                : Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? AppColors.primaryPurpleLight
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone
                ? scheme.onSurface
                : scheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isDone
            ? AppColors.primaryPurple
            : Colors.grey.withValues(alpha: 0.25),
      ),
    );
  }

  Widget _badge(String text, IconData icon, ColorScheme scheme, {Color? color}) {
    final c = color ?? scheme.onSurface.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color != null
            ? color.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
