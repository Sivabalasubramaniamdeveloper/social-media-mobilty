import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/toast_helper.dart';
import 'package:mineai/core/widgets/cards/credits_tracker_card.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/email_helper/models/email_helper_model.dart';
import 'package:mineai/features/email_helper/service/email_helper_service.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailHelperScreen extends StatefulWidget {
  const EmailHelperScreen({super.key});

  @override
  State<EmailHelperScreen> createState() => _EmailHelperScreenState();
}

class _EmailHelperScreenState extends State<EmailHelperScreen> {
  final EmailHelperService _service = EmailHelperService();
  final TextEditingController _instructionController = TextEditingController();

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
    _loadSmtpStatus();
    // Refresh user profile credits
    context.read<UserProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
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
      showToast('Please describe the email purpose');
      return;
    }

    // Check user credits
    final profileState = context.read<UserProfileCubit>().state;
    if (profileState is UserProfileLoaded && profileState.profile.credits < 20) {
      showToast(
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
        showToast('Email generated! (20 credits used)');
        // Refresh credit balance
        context.read<UserProfileCubit>().loadProfile();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        showToast('$e');
      }
    }
  }

  void _copyToClipboard() {
    if (_generatedEmail == null) return;
    final content =
        'Subject: ${_generatedEmail!.subject}\n\n${_generatedEmail!.body}';
    Clipboard.setData(ClipboardData(text: content));
    showToast('Email copied to clipboard!');
  }

  Future<void> _handleSendClick() async {
    if (_generatedEmail == null) return;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final toController = TextEditingController();
    final ccController = TextEditingController();
    final subjectController =
        TextEditingController(text: _generatedEmail!.subject);
    final bodyController = TextEditingController(text: _generatedEmail!.body);

    final isSmtpConfigured = _smtpStatus?.isConfigured ?? false;
    bool isSending = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight ? Colors.white : AppColors.surfaceDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(bottomSheetCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSmtpConfigured
                                  ? Icons.send_rounded
                                  : Icons.open_in_new_rounded,
                              color: scheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isSmtpConfigured
                                  ? 'Send via MineAI App'
                                  : 'Dispatch via Gmail App',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface.withValues(alpha: 0.6)),
                          onPressed: () => Navigator.pop(bottomSheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (!isSmtpConfigured)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: scheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No Gmail App Password configured',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurface,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Clicking send will launch your Gmail app with this draft. Add your Gmail App Password in Settings to send directly from MineAI.',
                                    style: TextStyle(
                                      color: isLight
                                          ? AppColors.lightSecondaryOnSurface
                                          : AppColors.secondaryText,
                                      fontSize: 11,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 24),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(bottomSheetCtx);
                                      context.push(RouteNames.apiKeys);
                                    },
                                    child: Text(
                                      'Setup App Password in Settings →',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: toController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'To (Recipient Email)*',
                        labelStyle: TextStyle(
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                        hintText: 'manager@example.com',
                        filled: true,
                        fillColor: isLight ? scheme.surfaceContainerHighest : AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ccController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'CC (Optional)',
                        labelStyle: TextStyle(
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                        hintText: 'colleague@example.com',
                        filled: true,
                        fillColor: isLight ? scheme.surfaceContainerHighest : AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectController,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        labelStyle: TextStyle(
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                        filled: true,
                        fillColor: isLight ? scheme.surfaceContainerHighest : AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 5,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Message Body',
                        labelStyle: TextStyle(
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                        filled: true,
                        fillColor: isLight ? scheme.surfaceContainerHighest : AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                  showToast('Please enter recipient email');
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
                                    showToast('Email sent successfully!');
                                  } catch (e) {
                                    setModalState(() => isSending = false);
                                    showToast('Failed to send: $e');
                                  }
                                } else {
                                  Navigator.pop(bottomSheetCtx);
                                  final uri = Uri(
                                    scheme: 'mailto',
                                    path: toEmail,
                                    queryParameters: {
                                      if (ccController.text.trim().isNotEmpty)
                                        'cc': ccController.text.trim(),
                                      'subject': subjectController.text.trim(),
                                      'body': bodyController.text.trim(),
                                    },
                                  );
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    showToast('Could not open mail app');
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
                                  Icon(
                                    isSmtpConfigured
                                        ? Icons.send_rounded
                                        : Icons.mail_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSmtpConfigured
                                        ? 'Confirm & Send Email'
                                        : 'Open & Send via Gmail',
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppScreenHeader(
                  title: 'Email Helper',
                  centerTitle: true,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.dashboard);
                    }
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Credits Tracking Card with live recharge countdown
                      const CreditsTrackerCard(),

                      const SizedBox(height: 20),

                      // SELECT TONE
                      Text(
                        'SELECT TONE',
                        style: TextStyle(
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _tones.map((tone) {
                            final isSelected = _selectedTone == tone;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(tone),
                                selected: isSelected,
                                selectedColor: scheme.primary,
                                backgroundColor: isLight
                                    ? scheme.surfaceContainerHighest
                                    : AppColors.surface,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : scheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? scheme.primary
                                        : (isLight
                                            ? Colors.black12
                                            : Colors.white12),
                                  ),
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _selectedTone = tone);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // USER INSTRUCTIONS
                      Text(
                        'USER INSTRUCTIONS',
                        style: TextStyle(
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLight
                                ? scheme.outlineVariant.withValues(alpha: 0.4)
                                : Colors.white12,
                          ),
                        ),
                        child: TextField(
                          controller: _instructionController,
                          maxLines: 5,
                          style: TextStyle(color: scheme.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            hintText:
                                "Describe the email purpose... (e.g. 'Asking my manager for a 1:1 meeting to discuss a raise next Tuesday at 3 PM')",
                            hintStyle: TextStyle(
                              color: isLight
                                  ? AppColors.lightSecondaryOnSurface.withValues(alpha: 0.7)
                                  : AppColors.secondaryText.withValues(alpha: 0.7),
                              fontSize: 14,
                              height: 1.4,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Generate Email Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _isGenerating ? null : _generateEmail,
                          child: _isGenerating
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Composing with AI...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Generate Email (20 Credits)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Generated Output Card
                      if (_generatedEmail != null) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: isLight
                                ? scheme.surfaceContainerHighest
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SUBJECT',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _generatedEmail!.subject,
                                      style: TextStyle(
                                        color: scheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Divider(
                                      color: isLight ? Colors.black12 : Colors.white12,
                                      height: 1,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _generatedEmail!.body,
                                      style: TextStyle(
                                        color: scheme.onSurface.withValues(alpha: 0.9),
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        // Copy Button
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: isLight
                                                      ? Colors.black26
                                                      : Colors.white24,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                backgroundColor: isLight
                                                    ? Colors.white
                                                    : AppColors.iconSurface,
                                              ),
                                              icon: Icon(
                                                Icons.copy_rounded,
                                                size: 16,
                                                color: scheme.onSurface,
                                              ),
                                              label: Text(
                                                'Copy',
                                                style: TextStyle(
                                                  color: scheme.onSurface,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              onPressed: _copyToClipboard,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Send Button
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: scheme.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.send_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Send',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              onPressed: _handleSendClick,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
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
}
