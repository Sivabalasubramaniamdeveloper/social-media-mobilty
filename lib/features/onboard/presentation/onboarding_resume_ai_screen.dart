import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingItem> _slides = [
    const _OnboardingItem(
      titlePrefix: 'Study & ',
      titleHighlight: 'Learning AI',
      description:
          'Master any subject with personalized AI tutors. Summarize complex topics and generate practice quizzes in seconds.',
      iconType: _OnboardIconType.study,
    ),
    _OnboardingItem(
      titlePrefix: '${AppStrings.resumeAnd} ',
      titleHighlight: AppStrings.careerAi,
      description: AppStrings.resumeOnboardingDesc,
      iconType: _OnboardIconType.resume,
    ),
    const _OnboardingItem(
      titlePrefix: 'Voice & ',
      titleHighlight: 'Smart Productivity',
      description:
          'Take control with your voice. MindAI automates your workflow and handles tasks hands-free, so you can focus on what matters most.',
      iconType: _OnboardIconType.voice,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingView(
      currentIndex: _currentIndex,
      slides: _slides,
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      onNext: _onNext,
      onSkip: () => context.go(RouteNames.login),
    );
  }
}

class _OnboardingView extends BaseScreen {
  final int currentIndex;
  final List<_OnboardingItem> slides;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _OnboardingView({
    required this.currentIndex,
    required this.slides,
    required this.controller,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  String get title => 'Onboarding';

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? width * 0.2 : 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  AppStrings.skip,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Column(
                    children: [
                      SizedBox(height: height * 0.02),
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: _buildGraphicContainer(
                            context,
                            isTablet,
                            width,
                            slide.iconType,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: slide.titlePrefix,
                              style: TextStyle(
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                            TextSpan(
                              text: slide.titleHighlight,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          height: 1.5,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const Spacer(),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => _dot(i == currentIndex),
              ),
            ),
            SizedBox(height: height * 0.04),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: AppColors.whiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentIndex == slides.length - 1
                          ? 'Get Started'
                          : AppStrings.next,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphicContainer(
    BuildContext context,
    bool isTablet,
    double width,
    _OnboardIconType type,
  ) {
    final boxSize = isTablet ? 280.0 : width * 0.72;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBackgroundMid.withOpacity(0.9),
            AppColors.darkBackgroundBottom.withOpacity(0.95),
          ],
        ),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.15),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(child: _getHeroContent(type)),
    );
  }

  Widget _getHeroContent(_OnboardIconType type) {
    switch (type) {
      case _OnboardIconType.study:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.psychology_alt_rounded,
                size: 64,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _badgeIcon(Icons.menu_book_rounded),
                const SizedBox(width: 12),
                _badgeIcon(Icons.quiz_rounded),
                const SizedBox(width: 12),
                _badgeIcon(Icons.edit_note_rounded),
              ],
            ),
          ],
        );
      case _OnboardIconType.resume:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.accentBlue.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.badge_rounded,
                size: 64,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.auto_awesome,
              size: 24,
              color: AppColors.primaryPurple,
            ),
          ],
        );
      case _OnboardIconType.voice:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                size: 64,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        );
    }
  }

  Widget _badgeIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.1)),
      ),
      child: Icon(icon, size: 20, color: AppColors.whiteColor),
    );
  }

  Widget _dot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? AppColors.primaryPurple
            : AppColors.whiteColor.withOpacity(0.25),
      ),
    );
  }
}

enum _OnboardIconType { study, resume, voice }

class _OnboardingItem {
  final String titlePrefix;
  final String titleHighlight;
  final String description;
  final _OnboardIconType iconType;

  const _OnboardingItem({
    required this.titlePrefix,
    required this.titleHighlight,
    required this.description,
    required this.iconType,
  });
}
