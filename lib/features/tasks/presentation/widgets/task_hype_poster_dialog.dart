import 'package:flutter/material.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/utils/social_share_helper.dart';

class TaskHypePosterDialog extends StatefulWidget {
  final String periodName;
  final int totalTasks;
  final int completedTasks;
  final double percentage;
  final String userName;

  const TaskHypePosterDialog({
    super.key,
    required this.periodName,
    required this.totalTasks,
    required this.completedTasks,
    required this.percentage,
    required this.userName,
  });

  static Future<void> show(
    BuildContext context, {
    required String periodName,
    required int totalTasks,
    required int completedTasks,
    required double percentage,
    required String userName,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => TaskHypePosterDialog(
        periodName: periodName,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        percentage: percentage,
        userName: userName,
      ),
    );
  }

  @override
  State<TaskHypePosterDialog> createState() => _TaskHypePosterDialogState();
}

class _TaskHypePosterDialogState extends State<TaskHypePosterDialog> {
  final GlobalKey _posterKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _sharePoster() async {
    setState(() => _isSharing = true);
    final text =
        '🔥 I have completed ${widget.completedTasks}/${widget.totalTasks} tasks (${widget.percentage.toStringAsFixed(0)}%) for this ${widget.periodName}! Powered by MineAI Voice Task Assistant.';

    final success = await SocialShareHelper.captureAndShare(
      boundaryKey: _posterKey,
      text: text,
      subject: 'My Task Completion Status 🔥',
    );

    if (mounted) {
      setState(() => _isSharing = false);
      if (success) {
        SnackBarHelper.showSuccess(context, 'Hype poster shared successfully!');
      } else {
        SnackBarHelper.showError(context, 'Failed to share poster');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Hyped Poster that gets captured to image
          RepaintBoundary(
            key: _posterKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F0C29),
                    Color(0xFF302B63),
                    Color(0xFF24243E),
                    Color(0xFF141E30),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0055).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFF0055),
                            width: 1.2,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded,
                                color: Color(0xFFFF0055), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'TASK SLAYER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.periodName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Giant percentage readout with neon glow
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFF06B6D4),
                          Colors.transparent,
                        ],
                        stops: [0.3, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Punchy Movie Title / Hyped Header
                  Text(
                    'I CRUSHED MY GOALS 🔥',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.completedTasks} of ${widget.totalTasks} Tasks Locked & Executed',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Stats pills row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniBadge(
                        icon: Icons.check_circle_rounded,
                        color: Colors.greenAccent,
                        label: '${widget.completedTasks} Done',
                      ),
                      const SizedBox(width: 8),
                      _buildMiniBadge(
                        icon: Icons.bolt_rounded,
                        color: Colors.amberAccent,
                        label: 'Unstoppable Momentum',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),

                  // Watermark footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mic_none_rounded,
                              color: Colors.cyanAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'MineAI Voice Assistant',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '@${widget.userName.replaceAll(" ", "").toLowerCase()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0055),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 8,
                  ),
                  icon: _isSharing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.share_rounded,
                          color: Colors.white, size: 20),
                  label: const Text(
                    'Share Hyped Story 🔥',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: _isSharing ? null : _sharePoster,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
