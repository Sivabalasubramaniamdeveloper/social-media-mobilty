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
    _OnboardingItem(
      titlePrefix: AppStrings.studyAndPrefix,
      titleHighlight: AppStrings.learningAiTitle,
      description: AppStrings.studyTutorDescription,
      iconType: _OnboardIconType.study,
    ),
    _OnboardingItem(
      titlePrefix: '${AppStrings.resumeAnd} ',
      titleHighlight: AppStrings.careerAi,
      description: AppStrings.resumeOnboardingDesc,
      iconType: _OnboardIconType.resume,
    ),
    _OnboardingItem(
      titlePrefix: AppStrings.voiceAndPrefix,
      titleHighlight: AppStrings.smartProductivityTitle,
      description: AppStrings.voiceWorkflowDescription,
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
  String get title => AppStrings.onboarding;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;

    final secondaryTextColor = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
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
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
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
                          color: secondaryTextColor,
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
                (i) => _dot(i == currentIndex, scheme),
              ),
            ),
            SizedBox(height: height * 0.04),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final boxSize = isTablet ? 280.0 : width * 0.72;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [scheme.surfaceContainerHighest, scheme.surfaceContainerHighest]
              : [
                  AppColors.darkBackgroundMid.withValues(alpha: 0.9),
                  AppColors.darkBackgroundBottom.withValues(alpha: 0.95),
                ],
        ),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: scheme.secondary.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.15),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(child: _getHeroContent(context, type)),
    );
  }

  Widget _getHeroContent(BuildContext context, _OnboardIconType type) {
    final scheme = Theme.of(context).colorScheme;

    switch (type) {
      case _OnboardIconType.study:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.psychology_alt_rounded,
                size: 64,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _badgeIcon(context, Icons.menu_book_rounded),
                const SizedBox(width: 12),
                _badgeIcon(context, Icons.quiz_rounded),
                const SizedBox(width: 12),
                _badgeIcon(context, Icons.edit_note_rounded),
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
                color: scheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: scheme.secondary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.badge_rounded,
                size: 64,
                color: scheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Icon(Icons.auto_awesome, size: 24, color: scheme.primary),
          ],
        );
      case _OnboardIconType.voice:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 64,
                color: scheme.onSurface,
              ),
            ),
          ],
        );
    }
  }

  Widget _badgeIcon(BuildContext context, IconData icon) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, size: 20, color: scheme.onSurface),
    );
  }

  Widget _dot(bool isActive, ColorScheme scheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? scheme.primary
            : scheme.onSurface.withValues(alpha: 0.25),
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
