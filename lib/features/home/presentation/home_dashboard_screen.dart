import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import '../../profile/cubit/user_profile_cubit.dart';
import '../../profile/cubit/user_profile_state.dart';
import '../../profile/presentation/profile_screen.dart';

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
              const Center(
                child: Text('Stats', style: TextStyle(color: Colors.white)),
              ),
              const ProfileScreen(),
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
            isTablet ? size.width * 0.15 : 20,
            16,
            isTablet ? size.width * 0.15 : 20,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B38).withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.06),
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.whiteColor,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181528).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.secondaryText,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchAiTools,
                hintStyle: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
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
        return InkWell(
          onTap: tool.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B38).withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.whiteColor.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2752),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tool.icon,
                    size: 22,
                    color: const Color(0xFFA78BFA),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.recentActivity,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.viewAll,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
      children: activities.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B38).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.whiteColor.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2752),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: const Color(0xFFA78BFA),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFF110E24).withOpacity(0.96),
        border: Border(
          top: BorderSide(color: AppColors.whiteColor.withOpacity(0.08)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, AppStrings.navHome),
          _navItem(1, Icons.history_rounded, AppStrings.navHistory),
          _navItem(2, Icons.bar_chart_rounded, AppStrings.navStats),
          _navItem(3, Icons.person_outline_rounded, AppStrings.navProfile),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _navIndex == index;
    final color = isSelected
        ? const Color(0xFFA78BFA)
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
