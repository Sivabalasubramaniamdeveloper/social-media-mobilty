import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import '../../auth/cubit/auth_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoSummarize = true;
  bool _hapticFeedback = true;

  @override
  Widget build(BuildContext context) {
    return _SettingsView(
      notifications: _notifications,
      autoSummarize: _autoSummarize,
      hapticFeedback: _hapticFeedback,
      onNotificationChanged: (v) => setState(() => _notifications = v),
      onAutoSummarizeChanged: (v) => setState(() => _autoSummarize = v),
      onHapticChanged: (v) => setState(() => _hapticFeedback = v),
    );
  }
}

class _SettingsView extends BaseScreen {
  final bool notifications;
  final bool autoSummarize;
  final bool hapticFeedback;
  final ValueChanged<bool> onNotificationChanged;
  final ValueChanged<bool> onAutoSummarizeChanged;
  final ValueChanged<bool> onHapticChanged;

  const _SettingsView({
    required this.notifications,
    required this.autoSummarize,
    required this.hapticFeedback,
    required this.onNotificationChanged,
    required this.onAutoSummarizeChanged,
    required this.onHapticChanged,
  });

  @override
  String get title => AppStrings.settings;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text(AppStrings.logOut),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(AppStrings.logoutConfirmMessage),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(AppStrings.cancel),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            child: Text(AppStrings.logOut),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B192E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.selectLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    AppStrings.englishLang,
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                  trailing: context.locale.languageCode == 'en'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryPurple,
                        )
                      : null,
                  onTap: () async {
                    await context.setLocale(const Locale('en'));
                    if (bottomSheetCtx.mounted) {
                      Navigator.of(bottomSheetCtx).pop();
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    AppStrings.tamilLang,
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                  trailing: context.locale.languageCode == 'ta'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryPurple,
                        )
                      : null,
                  onTap: () async {
                    await context.setLocale(const Locale('ta'));
                    if (bottomSheetCtx.mounted) {
                      Navigator.of(bottomSheetCtx).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  AppStrings.settings,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                _sectionHeader(AppStrings.account),
                _tile(
                  icon: Icons.person_outline_rounded,
                  title: AppStrings.editProfile,
                  subtitle: AppStrings.editProfileSubtitle,
                  onTap: () => context.push(RouteNames.editProfile),
                ),
                _tile(
                  icon: Icons.workspace_premium_outlined,
                  title: AppStrings.subscriptionPlan,
                  subtitle: AppStrings.manageProPlanCredits,
                  trailing: Text(
                    AppStrings.proBadge,
                    style: const TextStyle(
                      color: Color(0xFFA78BFA),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 20),

                _sectionHeader(AppStrings.preferences),
                _switchTile(
                  icon: Icons.notifications_none_rounded,
                  title: AppStrings.pushNotifications,
                  value: notifications,
                  onChanged: onNotificationChanged,
                ),
                _switchTile(
                  icon: Icons.auto_awesome_outlined,
                  title: AppStrings.aiAutoSummarize,
                  value: autoSummarize,
                  onChanged: onAutoSummarizeChanged,
                ),
                _tile(
                  icon: Icons.translate_rounded,
                  title: AppStrings.appLanguage,
                  subtitle: context.locale.languageCode == 'ta'
                      ? 'தமிழ்'
                      : 'English',
                  onTap: () => _showLanguageSheet(context),
                ),
                _switchTile(
                  icon: Icons.vibration_rounded,
                  title: AppStrings.hapticFeedback,
                  value: hapticFeedback,
                  onChanged: onHapticChanged,
                ),

                const SizedBox(height: 20),

                _sectionHeader(AppStrings.supportAndAbout),
                _tile(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.privacyPolicy,
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.description_outlined,
                  title: AppStrings.termsOfService,
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.appVersionLabel,
                  trailing: const Text(
                    '2.4.0-pro',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Log Out Button
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.redAccent.withOpacity(0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.redAccent.withOpacity(0.08),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.logOut,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B38).withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2E2752),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFFA78BFA)),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                )
              : null,
          trailing:
              trailing ??
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.secondaryText,
              ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B38).withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2E2752),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFFA78BFA)),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColor,
            ),
          ),
          trailing: CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primaryPurple,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
