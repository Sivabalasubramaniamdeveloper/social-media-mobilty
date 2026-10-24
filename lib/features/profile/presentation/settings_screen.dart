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

  @override
  Widget build(BuildContext context) {
    return _SettingsView(
      notifications: _notifications,
      onNotificationChanged: _handleNotificationChange,
    );
  }
}

class _SettingsView extends BaseScreen {
  final bool notifications;
  final ValueChanged<bool> onNotificationChanged;

  const _SettingsView({
    required this.notifications,
    required this.onNotificationChanged,
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
                AppListTileCard(
                  icon: Icons.translate_rounded,
                  title: AppStrings.appLanguage,
                  subtitle: context.locale.languageCode == 'ta'
                      ? 'தமிழ்'
                      : 'English',
                  onTap: () => _showLanguageSheet(context),
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
                  icon: Icons.confirmation_number_outlined,
                  title: AppStrings.supportTickets,
                  subtitle: AppStrings.trackIssuesAndRequests,
                  onTap: () => context.push(RouteNames.supportTickets),
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
                  onTap: () => _showLegalDialog(
                    context,
                    AppStrings.privacyPolicy,
                    'MineAI Privacy Policy (v1.0.0)\n\n'
                    '1. Data Collection: MineAI collects minimal essential data (email, name, device token) strictly to deliver AI productivity, expense management, secure vault, and localized news features.\n\n'
                    '2. Local Storage: Personal diary entries, private vault credentials, and expenses are encrypted and stored locally on your device with biometric protection.\n\n'
                    '3. Third-Party AI: Prompts sent to Gemini or LLM providers are processed securely and never used to train public models without consent.\n\n'
                    '4. Data Deletion: You retain full ownership and can export or delete your account data at any time from Settings.',
                  ),
                ),
                AppListTileCard(
                  icon: Icons.description_outlined,
                  title: AppStrings.termsOfService,
                  onTap: () => _showLegalDialog(
                    context,
                    AppStrings.termsOfService,
                    'MineAI Terms & Conditions (v1.0.0)\n\n'
                    '1. Acceptance: By installing and using MineAI, you agree to these Terms of Service.\n\n'
                    '2. Responsible Use: You agree not to misuse AI services for unlawful content, harassment, or unauthorized automated crawling.\n\n'
                    '3. Subscriptions & Credits: Daily credits recharge automatically. Paid tiers unlock expanded image quotas and cloud sync.\n\n'
                    '4. Warranty: Services are provided "as is". MineAI is designed for personal productivity and decision support.',
                  ),
                ),
                AppListTileCard(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.appVersionLabel,
                  showChevron: false,
                  trailing: const Text(
                    '1.0.0 (First Version)',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  void _showLegalDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.close),
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
