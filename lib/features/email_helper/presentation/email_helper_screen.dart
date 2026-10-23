import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
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
  bool _isGenerating = false;
  SmtpStatusModel? _smtpStatus;
  EmailGenerationResult? _generatedEmail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      SnackBarHelper.showWarning(context, 'Please describe the email purpose');
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

  void _copyToClipboard(String text, [String message = 'Copied to clipboard!']) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Save Generated Email',
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
                'Label Name (e.g. Work, Pitch, Personal, Client)',
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
                  hintText: 'Enter label name',
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
                'Intended Recipient (Optional)',
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
                'Cancel',
                style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
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
                    'Email saved under "$label" successfully!',
                  );
                }
              },
              child: const Text('Save Email', style: TextStyle(color: Colors.white)),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
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
                          icon: Icon(Icons.close,
                              color: scheme.onSurface.withValues(alpha: 0.7)),
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
                                    await _service.sendDirectEmail(
                                      to: toEmail,
                                      cc: ccController.text.trim(),
                                      subject: subjectController.text.trim(),
                                      body: bodyController.text.trim(),
                                    );
                                    if (bottomSheetCtx.mounted) {
                                      Navigator.pop(bottomSheetCtx);
                                    }
                                    if (mounted) {
                                      SnackBarHelper.showSuccess(
                                        context,
                                        'Email sent successfully! (Note: Please check Inbox & Spam folder)',
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
                                  final subject =
                                      subjectController.text.trim();
                                  final body = bodyController.text.trim();
                                  final cc = ccController.text.trim();

                                  final mailtoUrl =
                                      'mailto:$toEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}${cc.isNotEmpty ? "&cc=${Uri.encodeComponent(cc)}" : ""}';
                                  final mailtoUri = Uri.parse(mailtoUrl);

                                  bool opened = false;
                                  try {
                                    if (await canLaunchUrl(mailtoUri)) {
                                      opened = await launchUrl(mailtoUri,
                                          mode:
                                              LaunchMode.externalApplication);
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
                                        'Opening email app... (Check Spam folder note)',
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
                                  const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 18),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppScreenHeader(
                  title: 'Email Helper AI',
                  centerTitle: true,
                  onBack: () => context.pop(),
                  trailing: IconButton(
                    icon: Icon(Icons.key_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.8)),
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
                      icon: Icon(Icons.auto_awesome_rounded, size: 18),
                      text: 'Compose',
                    ),
                    Tab(
                      icon: Icon(Icons.bookmark_added_rounded, size: 18),
                      text: 'Saved Emails',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildComposeTab(scheme, isLight),
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
              const Icon(Icons.info_outline_rounded,
                  color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Important: Mails may initially arrive in the recipient\'s Spam or Junk folder. Advise your recipients to check Spam and mark "Not Spam".',
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
          'Choose Tone',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
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
          'Email Purpose & Instructions',
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
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 18),
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
                          horizontal: 10, vertical: 4),
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
                          icon: const Icon(Icons.bookmark_add_rounded, size: 20),
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
                    icon: Icon(Icons.send_rounded,
                        color: scheme.primary, size: 16),
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
                          horizontal: 10, vertical: 5),
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
                      Icon(Icons.mark_email_read_outlined,
                          size: 48,
                          color: scheme.onSurface.withValues(alpha: 0.3)),
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
                ...emails.map((mail) => _buildSavedEmailTile(mail, scheme, isLight)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedEmailTile(
      SavedEmailModel mail, ColorScheme scheme, bool isLight) {
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(mail.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? Colors.black12 : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  mail.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
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
                    onPressed: () => _showSendEmailModal(mail.subject, mail.body),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: scheme.error, size: 18),
                    tooltip: 'Delete',
                    onPressed: () async {
                      if (mail.id != null) {
                        await context
                            .read<EmailHelperCubit>()
                            .deleteEmail(mail.id!, _getCurrentTier());
                        if (mounted) {
                          SnackBarHelper.showSuccess(
                              context, 'Saved email deleted');
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mail.subject,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mail.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tone: ${mail.tone}',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
