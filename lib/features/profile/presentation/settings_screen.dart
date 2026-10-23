import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/language/language.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/config/theme/theme_cubit.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/app_widgets.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/instance/locator.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Refreshes plan status and loads device push notification settings whenever settings is opened.
  @override
  void initState() {
    super.initState();
    _loadDevicePreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SubscriptionCubit>().fetchUserPlan();
    });
  }

  Future<void> _loadDevicePreferences() async {
    final pref = await getIt<CustomSecureStorage>().readSecureData('push_notifications_enabled');
    if (pref != null && mounted) {
      setState(() => _notifications = pref != 'false');
    }
  }

  Future<void> _handleNotificationChange(bool val) async {
    setState(() => _notifications = val);
    await getIt<CustomSecureStorage>().writeSecureData('push_notifications_enabled', val ? 'true' : 'false');
  }

  /// Passes local preference values and callbacks to the settings view.
  @override
  Widget build(BuildContext context) {
    return _SettingsView(
      notifications: _notifications,
      autoSummarize: _autoSummarize,
      hapticFeedback: _hapticFeedback,
      onNotificationChanged: _handleNotificationChange,
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

  /// Returns the localized page title used by the shared screen scaffold.
  @override
  String get title => AppStrings.settings;

  /// Hides the default app bar because the page renders its own header.
  @override
  bool get showAppBar => false;

  /// Keeps the app's shared gradient background behind the settings content.
  @override
  bool get useGradientBackground => true;

  /// Confirms logout, clears the session, and returns to sign-in.
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

  /// Presents the supported app languages and applies the chosen locale.
  void _showLanguageSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final sheetBg = isLight ? Colors.white : const Color(0xFF1B192E);
    final textColor = isLight ? AppColors.lightOnSurface : AppColors.whiteColor;
    final checkColor = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    AppStrings.englishLang,
                    style: TextStyle(color: textColor),
                  ),
                  trailing: context.locale.languageCode == 'en'
                      ? Icon(Icons.check_circle_rounded, color: checkColor)
                      : null,
                  onTap: () async {
                    CustomLanguage.changeLanguage(context, 'en');
                    if (bottomSheetCtx.mounted) {
                      Navigator.of(bottomSheetCtx).pop();
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    AppStrings.tamilLang,
                    style: TextStyle(color: textColor),
                  ),
                  trailing: context.locale.languageCode == 'ta'
                      ? Icon(Icons.check_circle_rounded, color: checkColor)
                      : null,
                  onTap: () async {
                    CustomLanguage.changeLanguage(context, 'ta');
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

  /// Presents theme choices and applies the selected theme mode.
  void _showThemeSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final sheetBg = isLight ? Colors.white : const Color(0xFF1B192E);
    final titleColor = isLight
        ? AppColors.lightOnSurface
        : AppColors.whiteColor;
    final subtitleColor = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;
    final nameColor = isLight ? AppColors.lightOnSurface : AppColors.whiteColor;
    final checkColor = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.chooseAppTheme,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.themeSavedDescription,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 16),
                    ...AppThemeMode.values.map((mode) {
                      final isSelected = themeState.mode == mode;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mode.previewBackgroundColor,
                            border: Border.all(
                              color: mode.previewPrimaryColor,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: mode.previewPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          mode.displayName,
                          style: TextStyle(
                            color: nameColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: checkColor,
                              )
                            : null,
                        onTap: () {
                          context.read<ThemeCubit>().setTheme(mode);
                          if (bottomSheetCtx.mounted) {
                            Navigator.of(bottomSheetCtx).pop();
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds settings sections, including the current API-backed subscription tier.
  @override
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AppScreenHeader(
              title: AppStrings.settings,
              centerTitle: true,
              // onBack: () {
              //   if (context.canPop()) context.pop();
              // },
            ),
          ),

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                AppSectionHeader(title: AppStrings.account, isEyebrow: true),
                AppListTileCard(
                  icon: Icons.person_outline_rounded,
                  title: AppStrings.profile,
                  subtitle: AppStrings.editProfileSubtitle,
                  onTap: () => context.push(RouteNames.profile),
                ),
                AppListTileCard(
                  icon: Icons.workspace_premium_outlined,
                  title: AppStrings.subscriptionPlan,
                  subtitle: AppStrings.managePlanCredits,
                  trailing: BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    builder: (context, subscriptionState) {
                      if (subscriptionState is! SubscriptionLoaded) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        _planName(subscriptionState.plan.tier),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                  onTap: () => context.push(RouteNames.subscription),
                ),
                AppListTileCard(
                  icon: Icons.key_rounded,
                  title: 'API Keys & Passwords',
                  subtitle: 'Manage Gemini API Key & Gmail App Password',
                  onTap: () => context.push(RouteNames.apiKeys),
                ),

                const SizedBox(height: 20),

                AppSectionHeader(
                  title: AppStrings.preferences,
                  isEyebrow: true,
                ),
                AppListTileCard.toggle(
                  icon: Icons.notifications_none_rounded,
                  title: AppStrings.pushNotifications,
                  value: notifications,
                  onChanged: onNotificationChanged,
                ),
                AppListTileCard.toggle(
                  icon: Icons.auto_awesome_outlined,
                  title: AppStrings.aiAutoSummarize,
                  value: autoSummarize,
                  onChanged: onAutoSummarizeChanged,
                ),
                AppListTileCard(
                  icon: Icons.translate_rounded,
                  title: AppStrings.appLanguage,
                  subtitle: context.locale.languageCode == 'ta'
                      ? 'தமிழ்'
                      : 'English',
                  onTap: () => _showLanguageSheet(context),
                ),
                AppListTileCard.toggle(
                  icon: Icons.vibration_rounded,
                  title: AppStrings.hapticFeedback,
                  value: hapticFeedback,
                  onChanged: onHapticChanged,
                ),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return AppListTileCard(
                      icon: Icons.palette_outlined,
                      title: AppStrings.appTheme,
                      subtitle: themeState.mode.displayName,
                      onTap: () => _showThemeSheet(context),
                    );
                  },
                ),
                AppListTileCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: AppStrings.expenseSettings,
                  subtitle: AppStrings.expenseSettingsDesc,
                  onTap: () => context.push(RouteNames.expenseSettings),
                ),

                const SizedBox(height: 20),

                AppSectionHeader(
                  title: AppStrings.supportAndAbout,
                  isEyebrow: true,
                ),
                AppListTileCard(
                  icon: Icons.mail_outline_rounded,
                  title: AppStrings.contactSupport,
                  subtitle: AppStrings.contactSupportSubtitle,
                  onTap: () => launchUrl(
                    Uri(
                      scheme: 'mailto',
                      path: AppStrings.contactSupportSubtitle,
                      queryParameters: {
                        'subject': AppStrings.contactEmailSubject,
                      },
                    ),
                  ),
                ),
                AppListTileCard(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.privacyPolicy,
                  onTap: () {},
                ),
                AppListTileCard(
                  icon: Icons.description_outlined,
                  title: AppStrings.termsOfService,
                  onTap: () {},
                ),
                AppListTileCard(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.appVersionLabel,
                  showChevron: false,
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

                // Log Out Action Button
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
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

  /// Maps the current plan tier to its localized display name.
  String _planName(PlanTier tier) => switch (tier) {
    PlanTier.basic => AppStrings.basicPlan,
    PlanTier.pro => AppStrings.proPlan,
    PlanTier.premium => AppStrings.premiumPlan,
  };
}
