import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/expenses/presentation/widgets/widgets.dart';
import 'package:mineai/features/support/services/ticket_service.dart';
import 'package:mineai/instance/locator.dart';

class CreateTicketScreen extends StatefulWidget {
  final String? preselectedModule;

  const CreateTicketScreen({super.key, this.preselectedModule});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TicketService _ticketService = getIt<TicketService>();

  late String _selectedModule = widget.preselectedModule ?? 'expenses';
  String _selectedCategory = 'bug';
  String _selectedPriority = 'medium';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _modules = [
    {
      'id': 'expenses',
      'label': 'Expenses & Budgets',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'email_helper',
      'label': 'Email Helper',
      'icon': Icons.email_rounded,
    },
    {
      'id': 'tasks',
      'label': 'Task Tracker & Voice',
      'icon': Icons.task_alt_rounded,
    },
    {
      'id': 'price_comparison',
      'label': 'Price Comparison',
      'icon': Icons.compare_arrows_rounded,
    },
    {
      'id': 'mineai_streams',
      'label': 'MineAI Streams (OTT)',
      'icon': Icons.smart_display_rounded,
    },
    {
      'id': 'news',
      'label': 'City News',
      'icon': Icons.newspaper_rounded,
    },
    {
      'id': 'vault',
      'label': 'Secure Vault',
      'icon': Icons.lock_outline_rounded,
    },
    {
      'id': 'diary',
      'label': 'Personal Diary',
      'icon': Icons.auto_stories_rounded,
    },
    {
      'id': 'profile_auth',
      'label': 'Profile & Authentication',
      'icon': Icons.person_rounded,
    },
    {
      'id': 'general',
      'label': 'General / Other',
      'icon': Icons.support_agent_rounded,
    },
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (subject.isEmpty) {
      SnackBarHelper.showWarning(context, AppStrings.subjectRequired);
      return;
    }
    if (description.isEmpty) {
      SnackBarHelper.showWarning(context, AppStrings.descriptionRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _ticketService.createTicket(
        module: _selectedModule,
        category: _selectedCategory,
        priority: _selectedPriority,
        subject: subject,
        description: description,
      );

      if (mounted) {
        SnackBarHelper.showSuccess(context, AppStrings.ticketSubmittedSuccess);
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, AppStrings.failedToSubmitTicket);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

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
                  title: AppStrings.reportIssue,
                  titleSize: AppSizes.fontHeading,
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Module Picker
                        Text(
                          AppStrings.selectModule,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isLight
                                ? scheme.surface
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLight
                                  ? scheme.outlineVariant.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedModule,
                              isExpanded: true,
                              dropdownColor: isLight
                                  ? scheme.surface
                                  : const Color(0xFF1E1B38),
                              borderRadius: BorderRadius.circular(16),
                              items: _modules.map((m) {
                                return DropdownMenuItem<String>(
                                  value: m['id'] as String,
                                  child: Row(
                                    children: [
                                      Icon(
                                        m['icon'] as IconData,
                                        size: 20,
                                        color: AppColors.primaryPurpleLight,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        m['label'] as String,
                                        style: TextStyle(
                                          color: scheme.onSurface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedModule = val);
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Issue Category Chips
                        Text(
                          AppStrings.issueCategory,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChoiceChip(
                              'bug',
                              AppStrings.categoryBug,
                              Icons.bug_report_rounded,
                              scheme,
                              isLight,
                            ),
                            _buildChoiceChip(
                              'feature_request',
                              AppStrings.categoryFeatureRequest,
                              Icons.auto_awesome_rounded,
                              scheme,
                              isLight,
                            ),
                            _buildChoiceChip(
                              'performance',
                              AppStrings.categoryPerformance,
                              Icons.speed_rounded,
                              scheme,
                              isLight,
                            ),
                            _buildChoiceChip(
                              'other',
                              AppStrings.categoryOther,
                              Icons.help_outline_rounded,
                              scheme,
                              isLight,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Priority Selector
                        Text(
                          AppStrings.priorityLevel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPriorityPill(
                                'low',
                                AppStrings.priorityLow,
                                const Color(0xFF3B82F6),
                                isLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPriorityPill(
                                'medium',
                                AppStrings.priorityMedium,
                                AppColors.expenseOrange,
                                isLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPriorityPill(
                                'high',
                                AppStrings.priorityHigh,
                                AppColors.expenseRed,
                                isLight,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Subject
                        AppTextField(
                          controller: _subjectController,
                          label: AppStrings.subjectTitle,
                          hint: AppStrings.subjectHint,
                          isRequired: true,
                          style: AppTextFieldStyle.glass,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        AppTextField(
                          controller: _descriptionController,
                          label: AppStrings.issueDescription,
                          hint: AppStrings.issueDescriptionHint,
                          maxLines: 5,
                          isRequired: true,
                          style: AppTextFieldStyle.glass,
                        ),

                        const SizedBox(height: 18),

                        // Admin routing notice banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryPurple.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: AppColors.primaryPurpleLight,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppStrings.adminTicketNotice,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.45,
                                    color: scheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Submit Button
                        GradientActionButton(
                          text: AppStrings.submitTicket,
                          gradientColors: const [
                            AppColors.primaryPurple,
                            AppColors.primaryPurpleDark,
                          ],
                          isLoading: _isSubmitting,
                          onPressed: _submitTicket,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String id,
    String label,
    IconData icon,
    ColorScheme scheme,
    bool isLight,
  ) {
    final isSelected = _selectedCategory == id;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedCategory = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : (isLight
                  ? scheme.surface
                  : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : (isLight
                    ? scheme.outlineVariant.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : scheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityPill(
    String id,
    String label,
    Color color,
    bool isLight,
  ) {
    final isSelected = _selectedPriority == id;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedPriority = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
