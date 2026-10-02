import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
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

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Log Out'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Are you sure you want to log out of MindAI?'),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await context.read<AuthCubit>().logout();
              if (mounted) context.go(RouteNames.login);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet() {
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
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text(
                    'English',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: context.locale.languageCode == 'en'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryPurple,
                        )
                      : null,
                  onTap: () {
                    context.setLocale(const Locale('en'));
                    Navigator.of(bottomSheetCtx).pop();
                  },
                ),
                ListTile(
                  title: const Text(
                    'தமிழ் (Tamil)',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: context.locale.languageCode == 'ta'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryPurple,
                        )
                      : null,
                  onTap: () {
                    context.setLocale(const Locale('ta'));
                    Navigator.of(bottomSheetCtx).pop();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

              // Settings List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children: [
                    // Section 1: Account
                    _sectionHeader('ACCOUNT'),
                    _tile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update name, avatar, and personal details',
                      onTap: () => context.push(RouteNames.editProfile),
                    ),
                    _tile(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Subscription Plan',
                      subtitle: 'Manage Pro Plan & Credits',
                      trailing: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Color(0xFFA78BFA),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Preferences
                    _sectionHeader('PREFERENCES'),
                    _switchTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Push Notifications',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    _switchTile(
                      icon: Icons.auto_awesome_outlined,
                      title: 'AI Auto-Summarize',
                      value: _autoSummarize,
                      onChanged: (v) => setState(() => _autoSummarize = v),
                    ),
                    _tile(
                      icon: Icons.translate_rounded,
                      title: 'App Language',
                      subtitle: context.locale.languageCode == 'ta'
                          ? 'தமிழ்'
                          : 'English',
                      onTap: _showLanguageSheet,
                    ),
                    _switchTile(
                      icon: Icons.vibration_rounded,
                      title: 'Haptic Feedback',
                      value: _hapticFeedback,
                      onChanged: (v) => setState(() => _hapticFeedback = v),
                    ),

                    const SizedBox(height: 20),

                    // Section 3: About & Support
                    _sectionHeader('SUPPORT & ABOUT'),
                    _tile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _tile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {},
                    ),
                    _tile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
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
                    // SizedBox(
                    //   height: 52,
                    //   child:
                    //       OutlinedButton.styleFrom(
                    //         side: BorderSide(
                    //           color: Colors.redAccent.withOpacity(0.4),
                    //         ),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(16),
                    //         ),
                    //         backgroundColor: Colors.redAccent.withOpacity(0.08),
                    //       ).copyWith(
                    //         overlayColor: WidgetStateProperty.all(
                    //           Colors.redAccent.withOpacity(0.12),
                    //         ),
                    //       ),
                    //   child: const Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Icon(
                    //         Icons.logout_rounded,
                    //         color: Colors.redAccent,
                    //         size: 20,
                    //       ),
                    //       SizedBox(width: 8),
                    //       Text(
                    //         'Log Out',
                    //         style: TextStyle(
                    //           color: Colors.redAccent,
                    //           fontSize: 15,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    //   onPressed: _showLogoutDialog,
                    // ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            color: Colors.white,
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
            color: Colors.white,
          ),
        ),
        trailing: CupertinoSwitch(
          value: value,
          activeTrackColor: AppColors.primaryPurple,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
