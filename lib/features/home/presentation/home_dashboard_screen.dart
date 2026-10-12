import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/app_widgets.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/features/expenses/presentation/expense_tracker_screen.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:mineai/features/profile/presentation/settings_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _navIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch profile data from GET /api/v1/user/me
    context.read<UserProfileCubit>().loadProfile();
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
              const Center(
                child: Text('History', style: TextStyle(color: Colors.white)),
              ),
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
    final isTablet = size.width > 600;

    return GradientBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isTablet ? size.width * 0.15 : AppSizes.pagePadding,
            AppSizes.lg,
            isTablet ? size.width * 0.15 : AppSizes.pagePadding,
            90,
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
                  'Good Evening, $greetingName 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.yourAiProductivityHub,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryPurple,
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
        title: AppStrings.resumeAi,
        description: AppStrings.resumeAiDesc,
        icon: Icons.description_outlined,
        onTap: () {},
      ),
      _ToolItem(
        title: AppStrings.studyAi,
        description: AppStrings.studyAiDesc,
        icon: Icons.school_outlined,
        onTap: () {},
      ),
      _ToolItem(
        title: AppStrings.voiceTasks,
        description: AppStrings.voiceTasksDesc,
        icon: Icons.mic_none_rounded,
        onTap: () {},
      ),
      _ToolItem(
        title: AppStrings.imageCaptions,
        description: AppStrings.imageCaptionsDesc,
        icon: Icons.image_outlined,
        onTap: () {},
      ),
      _ToolItem(
        title: AppStrings.developerAi,
        description: AppStrings.developerAiDesc,
        icon: Icons.code_rounded,
        onTap: () {},
      ),
      // REPLACED DOC ANALYZER WITH WEATHER & INSIGHTS:
      _ToolItem(
        title: AppStrings.weatherInsights,
        description: AppStrings.weatherAiDesc,
        icon: Icons.wb_sunny_outlined,
        onTap: () => context.go(RouteNames.weather),
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
      onAction: () {},
    );
  }

  Widget _buildRecentActivityList() {
    final List<_ActivityItem> activities = [
      _ActivityItem(
        title: AppStrings.resumeUpdated,
        subtitle: AppStrings.resumeUpdatedDesc,
        time: AppStrings.time2mAgo,
        icon: Icons.edit_document,
      ),
      _ActivityItem(
        title: AppStrings.apiIntegration,
        subtitle: AppStrings.apiIntegrationDesc,
        time: AppStrings.time45mAgo,
        icon: Icons.integration_instructions_outlined,
      ),
      _ActivityItem(
        title: AppStrings.meetingTranscript,
        subtitle: AppStrings.meetingTranscriptDesc,
        time: AppStrings.time3hAgo,
        icon: Icons.record_voice_over_outlined,
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
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: AppSizes.bottomNavHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF110E24).withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: AppColors.whiteColor.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, AppStrings.navHome),
          _navItem(1, Icons.history_rounded, AppStrings.navHistory),
          _navItem(2, Icons.bar_chart_rounded, AppStrings.expense),
          _navItem(3, Icons.person_outline_rounded, AppStrings.navProfile),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _navIndex == index;
    final color = isSelected
        ? AppColors.accentLavender
        : AppColors.secondaryText;

    return InkWell(
      onTap: () => setState(() => _navIndex = index),
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
