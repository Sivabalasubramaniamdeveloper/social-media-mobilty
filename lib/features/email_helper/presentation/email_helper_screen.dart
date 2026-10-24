import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/cards/credits_tracker_card.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/email_helper/cubit/email_helper_cubit.dart';
import 'package:mineai/features/email_helper/cubit/email_helper_state.dart';
import 'package:mineai/features/email_helper/models/email_helper_model.dart';
import 'package:mineai/features/email_helper/service/email_helper_service.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailHelperScreen extends StatefulWidget {
  const EmailHelperScreen({super.key});

  @override
  State<EmailHelperScreen> createState() => _EmailHelperScreenState();
}

class _EmailHelperScreenState extends State<EmailHelperScreen>
    with SingleTickerProviderStateMixin {
  final EmailHelperService _service = EmailHelperService();
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _directToController = TextEditingController();
  final TextEditingController _directSubjectController = TextEditingController();
  final TextEditingController _directBodyController = TextEditingController();
  late TabController _tabController;

  final List<String> _tones = [
    'Professional',
    'Friendly',
    'Formal',
    'Apologetic',
    'Urgent',
    'Casual',
  ];

  String _selectedTone = 'Professional';
  String _directTone = 'Professional';
  bool _isGenerating = false;
  SmtpStatusModel? _smtpStatus;
  EmailGenerationResult? _generatedEmail;
  String? _expandedEmailId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSmtpStatus();
    context.read<UserProfileCubit>().loadProfile();
    _loadSavedEmails();
  }

  PlanTier _getCurrentTier() {
    final subState = context.read<SubscriptionCubit>().state;
    if (subState is SubscriptionLoaded) {
      return subState.plan.tier;
    }
    return PlanTier.basic;
  }

  void _loadSavedEmails() {
    context.read<EmailHelperCubit>().loadSavedEmails(_getCurrentTier());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _instructionController.dispose();
    _directToController.dispose();
    _directSubjectController.dispose();
    _directBodyController.dispose();
    super.dispose();
  }

  Future<void> _loadSmtpStatus() async {
    try {
      final status = await _service.getSmtpStatus();
      if (mounted) setState(() => _smtpStatus = status);
    } catch (_) {}
  }

  Future<void> _generateEmail() async {
    final text = _instructionController.text.trim();
    if (text.isEmpty) {
      SnackBarHelper.showWarning(context, AppStrings.describeEmailPurpose);
      return;
    }

    final profileState = context.read<UserProfileCubit>().state;
    if (profileState is UserProfileLoaded &&
        profileState.profile.credits < 20) {
      SnackBarHelper.showError(
        context,
        'Insufficient credits (requires 20). Recharges in ${profileState.profile.creditsRechargeCountdown ?? "tomorrow"}.',
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final result = await _service.generateEmail(
        instructions: text,
        tone: _selectedTone,
      );
      if (mounted) {
        setState(() {
          _generatedEmail = result;
          _isGenerating = false;
        });
        SnackBarHelper.showSuccess(
          context,
          'Email generated! (20 credits used)',
        );
        context.read<UserProfileCubit>().loadProfile();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        SnackBarHelper.showError(context, '$e');
      }
    }
  }

  void _copyToClipboard(
    String text, [
    String message = 'Copied to clipboard!',
  ]) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarHelper.showSuccess(context, message);
  }

  void _shareEmail(String subject, String body) {
    final shareContent = 'Subject: $subject\n\n$body';
    SharePlus.instance.share(ShareParams(text: shareContent, subject: subject));
  }

  void _showSaveEmailModal(String subject, String body, String tone) {
    final tier = _getCurrentTier();
    final labelController = TextEditingController(text: 'Work');
    final recipientController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return AlertDialog(
          backgroundColor: isLight ? scheme.surface : const Color(0xFF1E1B38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppStrings.saveGeneratedEmail,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.labelNameHint,
                style: TextStyle(
                  fontSize: 12,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  hintText: AppStrings.enterLabelName,
                  filled: true,
                  fillColor: isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF262344),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.intendedRecipient,
                style: TextStyle(
                  fontSize: 12,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: recipientController,
                decoration: InputDecoration(
                  hintText: 'client@example.com',
                  filled: true,
                  fillColor: isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF262344),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final label = labelController.text.trim();
                final recipient = recipientController.text.trim();
                Navigator.pop(ctx);

                final saved = await context.read<EmailHelperCubit>().saveEmail(
                  label: label.isEmpty ? 'General' : label,
                  subject: subject,
                  body: body,
                  tone: tone,
                  recipient: recipient.isEmpty ? null : recipient,
                  tier: tier,
                );

                if (saved && mounted) {
                  SnackBarHelper.showSuccess(
                    context,
                    AppStrings.emailSavedSuccess,
                  );
                }
              },
              child: Text(
                AppStrings.saveEmail,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSendEmailModal(String initialSubject, String initialBody) {
    final toController = TextEditingController();
    final ccController = TextEditingController();
    final subjectController = TextEditingController(text: initialSubject);
    final bodyController = TextEditingController(text: initialBody);

    bool isSending = false;
    final isSmtpConfigured = _smtpStatus?.isConfigured ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isLight ? scheme.surface : const Color(0xFF1B192E),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Send Email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          onPressed: () => Navigator.pop(bottomSheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: toController,
                      decoration: InputDecoration(
                        labelText: 'To Recipient *',
                        hintText: 'colleague@example.com',
                        filled: true,
                        fillColor: isLight
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFF262344),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ccController,
                      decoration: InputDecoration(
                        labelText: 'CC (Optional)',
                        hintText: 'team@example.com',
                        filled: true,
                        fillColor: isLight
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFF262344),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        filled: true,
                        fillColor: isLight
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFF262344),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSending
                            ? null
                            : () async {
                                final toEmail = toController.text.trim();
                                if (toEmail.isEmpty) {
                                  SnackBarHelper.showWarning(
                                    context,
                                    'Please enter recipient email',
                                  );
                                  return;
                                }

                                if (isSmtpConfigured) {
                                  setModalState(() => isSending = true);
                                  try {
                                    final sendResult = await _service
                                        .sendDirectEmail(
                                          to: toEmail,
                                          cc: ccController.text.trim(),
                                          subject: subjectController.text
                                              .trim(),
                                          body: bodyController.text.trim(),
                                        );
                                    if (bottomSheetCtx.mounted) {
                                      Navigator.pop(bottomSheetCtx);
                                    }
                                    if (mounted) {
                                      SnackBarHelper.showSuccess(
                                        context,
                                        sendResult.deliveryNotice.isNotEmpty
                                            ? sendResult.deliveryNotice
                                            : 'Email accepted by the mail server. Please check Inbox and Spam/Junk.',
                                      );
                                    }
                                  } catch (e) {
                                    setModalState(() => isSending = false);
                                    if (mounted) {
                                      SnackBarHelper.showError(
                                        context,
                                        'Failed to send: $e',
                                      );
                                    }
                                  }
                                } else {
                                  Navigator.pop(bottomSheetCtx);
                                  final subject = subjectController.text.trim();
                                  final body = bodyController.text.trim();
                                  final cc = ccController.text.trim();

                                  final mailtoUrl =
                                      'mailto:$toEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}${cc.isNotEmpty ? "&cc=${Uri.encodeComponent(cc)}" : ""}';
                                  final mailtoUri = Uri.parse(mailtoUrl);

                                  bool opened = false;
                                  try {
                                    if (await canLaunchUrl(mailtoUri)) {
                                      opened = await launchUrl(
                                        mailtoUri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  } catch (_) {}

                                  if (!opened) {
                                    _copyToClipboard(
                                      'Subject: $subject\n\n$body',
                                      'Email content copied to clipboard! Open your email app to send.',
                                    );
                                  } else {
                                    if (mounted) {
                                      SnackBarHelper.showSuccess(
                                        context,
                                        AppStrings.emailSent,
                                      );
                                    }
                                  }
                                }
                              },
                        child: isSending
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSmtpConfigured
                                        ? 'Send via MineAI Engine'
                                        : 'Open in Email Client',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AppScreenHeader(
                  title: 'Email Helper AI',
                  centerTitle: true,
                  onBack: () => context.pop(),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.key_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.8),
                    ),
                    tooltip: 'Email App Passwords',
                    onPressed: () => context.push(RouteNames.apiKeys),
                  ),
                ),
              ),
              // Segmented Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF1E1B38),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isLight ? Colors.black12 : Colors.white10,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.6),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.auto_awesome_rounded, size: 17),
                      text: 'AI Draft',
                    ),
                    Tab(
                      icon: Icon(Icons.edit_note_rounded, size: 18),
                      text: 'Direct Compose',
                    ),
                    Tab(
                      icon: Icon(Icons.bookmark_added_rounded, size: 17),
                      text: 'Saved Mails',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildComposeTab(scheme, isLight),
                    _buildDirectComposeTab(scheme, isLight),
                    _buildSavedEmailsTab(scheme, isLight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposeTab(ColorScheme scheme, bool isLight) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const CreditsTrackerCard(compact: true),
        const SizedBox(height: 12),

        // Spam Advisory Notice Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.emailSpamNotice,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight
                        ? Colors.brown.shade800
                        : Colors.amber.shade200,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tone Selector
        Text(
          AppStrings.chooseTone,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _tones.map((tone) {
              final isSelected = _selectedTone == tone;
              return GestureDetector(
                onTap: () => setState(() => _selectedTone = tone),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary
                        : (isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF1E1B38)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? scheme.primary : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    tone,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : scheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Prompt / Instruction Field
        Text(
          AppStrings.emailPurposeInstructions,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _instructionController,
          maxLines: 4,
          style: TextStyle(color: scheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText:
                'e.g. Write a resignation letter with 2 weeks notice thanking the team for 3 wonderful years...',
            hintStyle: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.4),
              fontSize: 13,
            ),
            filled: true,
            fillColor: isLight
                ? scheme.surfaceContainerHighest
                : const Color(0xFF1E1B38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isLight ? Colors.black12 : Colors.white10,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isLight ? Colors.black12 : Colors.white10,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Generate Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isGenerating ? null : _generateEmail,
            child: _isGenerating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Generate Email (20 Credits)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Generated Output Card
        if (_generatedEmail != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight
                  ? scheme.surfaceContainerHighest
                  : const Color(0xFF1E1B38),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _generatedEmail!.tone,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          tooltip: 'Copy',
                          onPressed: () => _copyToClipboard(
                            'Subject: ${_generatedEmail!.subject}\n\n${_generatedEmail!.body}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 20),
                          tooltip: 'Share',
                          onPressed: () => _shareEmail(
                            _generatedEmail!.subject,
                            _generatedEmail!.body,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.bookmark_add_rounded,
                            size: 20,
                          ),
                          tooltip: 'Save with Label',
                          onPressed: () => _showSaveEmailModal(
                            _generatedEmail!.subject,
                            _generatedEmail!.body,
                            _generatedEmail!.tone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Subject: ${_generatedEmail!.subject}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _generatedEmail!.body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: scheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: scheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.send_rounded,
                      color: scheme.primary,
                      size: 16,
                    ),
                    label: Text(
                      'Send Directly or via Email Client',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _showSendEmailModal(
                      _generatedEmail!.subject,
                      _generatedEmail!.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildDirectComposeTab(ColorScheme scheme, bool isLight) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // Zero credit cost banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Direct Compose Active • 0 Credits Used (Completely Free)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? Colors.green.shade900 : Colors.green.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Compose Form Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight
                ? scheme.surfaceContainerHighest
                : const Color(0xFF1E1B38),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isLight ? Colors.black12 : Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient Field
              Text(
                'To (Recipient Email)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _directToController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: scheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'recipient@example.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded, size: 18, color: scheme.primary),
                  filled: true,
                  fillColor: isLight ? scheme.surface : const Color(0xFF262344),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              // Subject Field
              Text(
                'Subject',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _directSubjectController,
                style: TextStyle(color: scheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter email subject...',
                  prefixIcon: Icon(Icons.subject_rounded, size: 18, color: scheme.primary),
                  filled: true,
                  fillColor: isLight ? scheme.surface : const Color(0xFF262344),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              // Tone selector
              Text(
                'Style / Tone (Optional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tones.map((t) {
                    final isSel = _directTone == t;
                    return GestureDetector(
                      onTap: () => setState(() => _directTone = t),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel
                              ? scheme.primary
                              : (isLight ? scheme.surface : const Color(0xFF262344)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? scheme.primary : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Body Field
              Text(
                'Message Body',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _directBodyController,
                maxLines: 7,
                style: TextStyle(color: scheme.onSurface, fontSize: 14, height: 1.4),
                decoration: InputDecoration(
                  hintText: 'Type your email message directly here...',
                  filled: true,
                  fillColor: isLight ? scheme.surface : const Color(0xFF262344),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        AppStrings.sendEmail,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final subject = _directSubjectController.text.trim();
                        final body = _directBodyController.text.trim();
                        if (subject.isEmpty && body.isEmpty) {
                          SnackBarHelper.showWarning(context, AppStrings.enterSubjectOrMessage);
                          return;
                        }
                        _showSendEmailModal(subject, body);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.bookmark_add_rounded, size: 16),
                    label: Text(AppStrings.saveEmail),
                    onPressed: () {
                      final subject = _directSubjectController.text.trim();
                      final body = _directBodyController.text.trim();
                      if (subject.isEmpty && body.isEmpty) {
                        SnackBarHelper.showWarning(context, AppStrings.enterEmailContentToSave);
                        return;
                      }
                      _showSaveEmailModal(
                        subject.isEmpty ? 'Untitled' : subject,
                        body,
                        _directTone,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSavedEmailsTab(ColorScheme scheme, bool isLight) {
    return BlocBuilder<EmailHelperCubit, EmailHelperState>(
      builder: (context, state) {
        if (state is EmailHelperLoading) {
          return Center(
            child: CircularProgressIndicator(color: scheme.primary),
          );
        }

        List<SavedEmailModel> emails = [];
        int count = 0;
        int limit = 5;

        if (state is EmailHelperSavedEmailsLoaded) {
          emails = state.savedEmails;
          count = state.count;
          limit = state.limit;
        }

        final tier = _getCurrentTier();
        final tierName = tier == PlanTier.premium
            ? 'Premium (50 Mails)'
            : tier == PlanTier.pro
            ? 'Pro (20 Mails)'
            : 'Basic (5 Mails)';

        return RefreshIndicator(
          onRefresh: () async => _loadSavedEmails(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Quota tracker header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF1E1B38),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLight ? Colors.black12 : Colors.white10,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Emails Quota',
                          style: TextStyle(
                            fontSize: 13,
                            color: isLight
                                ? AppColors.lightSecondaryOnSurface
                                : AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$count of $limit Mails Used',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tierName,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (emails.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 48,
                        color: scheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Saved Emails Yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Generate an email and tap "Save with Label" to keep it stored here with all details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...emails.map(
                  (mail) => _buildSavedEmailTile(mail, scheme, isLight),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedEmailTile(
    SavedEmailModel mail,
    ColorScheme scheme,
    bool isLight,
  ) {
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(mail.createdAt);
    final isExpanded = _expandedEmailId == mail.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? scheme.primary.withValues(alpha: 0.6)
              : (isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white10),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _expandedEmailId = isExpanded ? null : mail.id;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            mail.label.toUpperCase(),
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mail.tone,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: scheme.primary,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  mail.subject,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                if (mail.recipient != null && mail.recipient!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.alternate_email_rounded,
                        size: 13,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'To: ${mail.recipient!}',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    mail.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isLight
                          ? AppColors.lightSecondaryOnSurface
                          : AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLight ? scheme.surface : const Color(0xFF262344),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mail.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isLight ? Colors.black12 : Colors.white12,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: 'Copy',
                          onPressed: () => _copyToClipboard(
                            'Subject: ${mail.subject}\n\n${mail.body}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 18),
                          tooltip: 'Share',
                          onPressed: () => _shareEmail(mail.subject, mail.body),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, size: 18),
                          tooltip: 'Send',
                          onPressed: () =>
                              _showSendEmailModal(mail.subject, mail.body),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          tooltip: 'Delete',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(AppStrings.delete),
                                content: Text(AppStrings.deleteSavedEmailConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(AppStrings.cancel),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      AppStrings.delete,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && mail.id != null && mounted) {
                              await context.read<EmailHelperCubit>().deleteEmail(
                                mail.id!,
                                _getCurrentTier(),
                              );
                              if (mounted) {
                                SnackBarHelper.showSuccess(
                                  context,
                                  AppStrings.itemDeleted,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
