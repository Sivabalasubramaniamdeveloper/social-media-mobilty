import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/toast_helper.dart';
import 'package:mineai/core/widgets/cards/credits_tracker_card.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:mineai/features/tasks/presentation/task_detail_screen.dart';
import 'package:mineai/features/tasks/services/task_service.dart';

class AiVoiceAssistantScreen extends StatefulWidget {
  final String? initialPrompt;

  const AiVoiceAssistantScreen({super.key, this.initialPrompt});

  @override
  State<AiVoiceAssistantScreen> createState() => _AiVoiceAssistantScreenState();
}

class _AiVoiceAssistantScreenState extends State<AiVoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final TextEditingController _promptController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  bool _isProcessing = false;

  final List<String> _quickSuggestions = [
    'Schedule a meeting with design team tomorrow at 10 AM',
    'Doctor appointment this Friday at 3:30 PM',
    'Review quarterly budget next Monday at 11 AM',
    'Dinner with Sarah tonight at 8 PM at Italian Bistro',
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      _promptController.text = widget.initialPrompt!;
    }

    // Refresh credits
    context.read<UserProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      showToast('Listening... Speak your task or type below');
    }
  }

  Future<void> _processTask() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      showToast('Please speak or type a task to process with AI');
      return;
    }

    // Check credits
    final profileState = context.read<UserProfileCubit>().state;
    if (profileState is UserProfileLoaded && profileState.profile.credits < 10) {
      showToast(
        'Insufficient credits (requires 10). Recharges in ${profileState.profile.creditsRechargeCountdown ?? "tomorrow"}.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _isListening = false;
    });

    try {
      final task = await _taskService.extractTaskFromPrompt(prompt);
      if (mounted) {
        setState(() => _isProcessing = false);
        // Refresh credits balance
        context.read<UserProfileCubit>().loadProfile();
        // Navigate to the dedicated Task Detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: task),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        showToast('Failed to process task: $e');
      }
    }
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
              // Clean top app bar without bottom nav
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.dashboard);
                        }
                      },
                    ),
                    Text(
                      'AI Voice Assistant',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _circleIconButton(
                      icon: Icons.format_list_bulleted_rounded,
                      onTap: () => context.push(RouteNames.tasksList),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      // Credits Tracker Card
                      const CreditsTrackerCard(compact: true),

                      const SizedBox(height: 16),

                      // Status indicator
                      Text(
                        _isListening
                            ? 'LISTENING TO YOUR VOICE...'
                            : (_isProcessing ? 'AI PROCESSING TASK...' : 'TAP MIC OR TYPE COMMAND'),
                        style: TextStyle(
                          color: _isListening
                              ? Colors.greenAccent
                              : (_isProcessing ? Colors.orangeAccent : scheme.primary),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pulsing Microphone Button
                      _buildMicrophoneRipples(scheme),

                      const SizedBox(height: 24),

                      // Voice / Text Instruction Input Box
                      Container(
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isListening
                                ? scheme.primary
                                : (isLight ? Colors.black12 : Colors.white12),
                            width: _isListening ? 1.5 : 1,
                          ),
                        ),
                        child: TextField(
                          controller: _promptController,
                          maxLines: 3,
                          style: TextStyle(color: scheme.onSurface, fontSize: 15),
                          decoration: InputDecoration(
                            hintText:
                                "Speak or type your task...\n(e.g. 'Schedule team meeting tomorrow at 10 AM')",
                            hintStyle: TextStyle(
                              color: isLight
                                  ? AppColors.lightSecondaryOnSurface.withValues(alpha: 0.7)
                                  : AppColors.secondaryText.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: _promptController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 20),
                                    onPressed: () => setState(() => _promptController.clear()),
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Process with AI Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _isProcessing ? null : _processTask,
                          child: _isProcessing
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'AI Analyzing Task...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Process Task with AI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick Suggestions
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'QUICK EXAMPLES',
                          style: TextStyle(
                            color: isLight
                                ? AppColors.lightSecondaryOnSurface
                                : AppColors.secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._quickSuggestions.map(
                        (sug) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _promptController.text = sug;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? scheme.surfaceContainerHighest
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isLight ? Colors.black12 : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.touch_app_rounded, size: 16, color: scheme.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      sug,
                                      style: TextStyle(
                                        color: scheme.onSurface,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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

  Widget _buildMicrophoneRipples(ColorScheme scheme) {
    return ScaleTransition(
      scale: _isListening ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
            color: scheme.primary.withValues(alpha: _isListening ? 0.3 : 0.1),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Container(
            width: 135,
            height: 135,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: scheme.primary.withValues(alpha: _isListening ? 0.6 : 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary,
                        AppColors.primaryPurpleDeep,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: _isListening ? 0.6 : 0.3),
                        blurRadius: _isListening ? 24 : 14,
                        spreadRadius: _isListening ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLight ? theme.colorScheme.surfaceContainerHighest : AppColors.surface,
        border: Border.all(color: isLight ? Colors.black12 : Colors.white10),
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
