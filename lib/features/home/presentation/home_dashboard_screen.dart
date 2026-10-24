import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/cards/app_feature_card.dart';
import 'package:mineai/core/widgets/cards/app_list_tile_card.dart';
import 'package:mineai/core/widgets/buttons/app_icon_action_button.dart';
import 'package:mineai/core/widgets/forms/app_search_field.dart';
import 'package:mineai/core/widgets/headers/app_section_header.dart';
import 'package:mineai/features/diary/presentation/diary_dashboard_screen.dart';
import 'package:mineai/features/expenses/presentation/expense_tracker_screen.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/features/profile/presentation/settings_screen.dart';
import 'package:mineai/features/scraper/presentation/product_scraper_screen.dart';
import 'package:mineai/features/tasks/models/task_model.dart';
import 'package:mineai/features/tasks/presentation/task_detail_screen.dart';
import 'package:mineai/features/tasks/services/task_database_service.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _navIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<TaskModel> _recentTasks = [];

  @override
  void initState() {
    super.initState();
    // Load dynamic profile details from GET /api/v1/user/me
    context.read<UserProfileCubit>().loadProfile();
    _loadRecentTasks();
  }

  Future<void> _loadRecentTasks() async {
    try {
      final userId = await UserHelper.getCurrentUserId();
      final tasks = await TaskDatabaseService.instance.getTasks(userId);
      if (mounted) {
        setState(() {
          _recentTasks = tasks.take(3).toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _navIndex,
            children: [
              _buildHomeContent(),
              const ProductScraperScreen(),
              const ExpenseTrackerScreen(),
              const SettingsScreen(),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isTablet = size.width > 600;

    return GradientBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isTablet ? size.width * 0.15 : AppSizes.pagePadding,
            AppSizes.lg,
            isTablet ? size.width * 0.15 : AppSizes.pagePadding,
            AppSizes.bottomNavHeight +
                bottomInset +
                20, // Avoid Android navigation bar collision
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildToolsGrid(context),
              const SizedBox(height: 28),
              _buildRecentActivityHeader(),
              const SizedBox(height: 14),
              _buildRecentActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

        String greetingName = 'User';
        if (state is UserProfileLoaded) {
          greetingName = state.profile.fullName.split(' ').first;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeGreeting(greetingName),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.secondaryHeaderColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.yourAiProductivityHub,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AppIconActionButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return AppSearchField(
      controller: _searchController,
      hint: AppStrings.searchAiTools,
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    final List<_ToolItem> tools = [
      _ToolItem(
        title: AppStrings.voiceTasks,
        description: AppStrings.voiceTasksDesc,
        icon: Icons.mic_none_rounded,
        onTap: () => context.push(RouteNames.voiceTasks),
      ),
      _ToolItem(
        title: AppStrings.aiEmailHelper,
        description: AppStrings.generateDraft,
        icon: Icons.mark_email_read_outlined,
        onTap: () => context.push(RouteNames.emailHelper),
      ),
      _ToolItem(
        title: AppStrings.localCityNews,
        description: AppStrings.webScrapingNews,
        icon: Icons.newspaper_rounded,
        onTap: () => context.push(RouteNames.news),
      ),
      _ToolItem(
        title: AppStrings.secureVault,
        description: AppStrings.vaultSubtitle,
        icon: Icons.shield_rounded,
        onTap: () => context.push(RouteNames.vault),
      ),
      _ToolItem(
        title: AppStrings.comparePricesTag,
        description: AppStrings.searchingStores,
        icon: Icons.compare_arrows_rounded,
        onTap: () => context.push(RouteNames.comparePrices),
      ),
      _ToolItem(
        title: AppStrings.mineAiStreams,
        description: AppStrings.mineAiStreamsDesc,
        icon: Icons.video_library_sharp,
        onTap: () => context.push(RouteNames.ott),
      ),
      _ToolItem(
        title: AppStrings.weatherInsights,
        description: AppStrings.weatherAiDesc,
        icon: Icons.wb_sunny_outlined,
        onTap: () => context.push(RouteNames.weather),
      ),
      _ToolItem(
        title: AppStrings.personalDiary,
        description: AppStrings.diarySubtitle,
        icon: Icons.auto_stories_rounded,
        onTap: () async {
          final userId = await UserHelper.getCurrentUserId();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryDashboardScreen(userId: userId),
              ),
            );
          }
        },
      ),
      _ToolItem(
        title: AppStrings.apiKeysTitle,
        description: AppStrings.apiKeysSubtitle,
        icon: Icons.key_rounded,
        onTap: () => context.push(RouteNames.apiKeys),
      ),
    ];

    return GridView.builder(
      itemCount: tools.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return AppFeatureCard(
          title: tool.title,
          description: tool.description,
          icon: tool.icon,
          onTap: tool.onTap,
        );
      },
    );
  }

  Widget _buildRecentActivityHeader() {
    return AppSectionHeader(
      title: AppStrings.recentActivity,
      actionLabel: AppStrings.viewAll,
      onAction: () async {
        await context.push(RouteNames.tasksList);
        _loadRecentTasks();
      },
    );
  }

  Widget _buildRecentActivityList() {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final secondaryTextColor = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    if (_recentTasks.isNotEmpty) {
      return Column(
        children: _recentTasks.map((task) {
          return AppListTileCard(
            icon: Icons.task_alt_rounded,
            title: task.title,
            subtitle: '${task.category} • ${task.dateDisplay} at ${task.timeDisplay}',
            showChevron: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? (isLight ? Colors.green.withValues(alpha: 0.12) : Colors.green.withValues(alpha: 0.2))
                    : (isLight ? theme.colorScheme.primary.withValues(alpha: 0.12) : theme.colorScheme.primary.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.isCompleted ? AppStrings.taskCompleted : AppStrings.taskPending,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: task.isCompleted ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
              );
              _loadRecentTasks();
            },
          );
        }).toList(),
      );
    }

    final List<_ActivityItem> activities = [
      _ActivityItem(
        title: 'Voice Assistant Ready',
        subtitle: 'Tap microphone in Voice Tasks to plan meetings',
        time: 'Ready',
        icon: Icons.mic_none_rounded,
      ),
      _ActivityItem(
        title: 'Email Helper Active',
        subtitle: 'Draft professional emails & send directly',
        time: 'Active',
        icon: Icons.mark_email_read_outlined,
      ),
      _ActivityItem(
        title: 'Expenses & Budget',
        subtitle: 'Track spending and auto-categorize transactions',
        time: 'Active',
        icon: Icons.account_balance_wallet_outlined,
      ),
    ];

    return Column(
      children: activities
          .map(
            (item) => AppListTileCard(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              showChevron: false,
              trailing: Text(
                item.time,
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, AppStrings.navHome),
              _navItem(1, Icons.compare_arrows_rounded, AppStrings.comparePrices),
              _navItem(2, Icons.bar_chart_rounded, AppStrings.expenses),
              _navItem(3, Icons.person_outline_rounded, AppStrings.profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final isSelected = _navIndex == index;

    final color = isSelected
        ? scheme.primary
        : (isLight
              ? AppColors.lightSecondaryOnSurface
              : AppColors.secondaryText);

    return InkWell(
      onTap: () {
        setState(() => _navIndex = index);
        if (index == 0) _loadRecentTasks();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });
}
