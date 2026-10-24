import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/utils/social_share_helper.dart';
import '../models/diary_entry_model.dart';

class DiaryMoodHypeDialog extends StatefulWidget {
  final DiaryEntryModel entry;
  final String userName;
  final String dailyQuote;

  const DiaryMoodHypeDialog({
    super.key,
    required this.entry,
    required this.userName,
    required this.dailyQuote,
  });

  static Future<void> show(
    BuildContext context, {
    required DiaryEntryModel entry,
    required String userName,
    required String dailyQuote,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DiaryMoodHypeDialog(
        entry: entry,
        userName: userName,
        dailyQuote: dailyQuote,
      ),
    );
  }

  @override
  State<DiaryMoodHypeDialog> createState() => _DiaryMoodHypeDialogState();
}

class _DiaryMoodHypeDialogState extends State<DiaryMoodHypeDialog> {
  final GlobalKey _posterKey = GlobalKey();
  bool _isSharing = false;

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'great':
        return '⚡';
      case 'peaceful':
      case 'calm':
        return '✨';
      case 'loved':
      case 'grateful':
        return '💖';
      case 'productive':
      case 'focused':
        return '🚀';
      case 'sad':
      case 'tired':
        return '🌧️';
      default:
        return '🔥';
    }
  }

  Future<void> _sharePoster() async {
    setState(() => _isSharing = true);
    final moodTitle = widget.entry.mood.toUpperCase();
    final text =
        '🔥 Today\'s Mood Vibe: $moodTitle ${_getMoodEmoji(widget.entry.mood)}! "${widget.entry.title}" - Captured with MineAI Personal Diary.';

    final success = await SocialShareHelper.captureAndShare(
      boundaryKey: _posterKey,
      text: text,
      subject: 'My Mood of Today 🔥',
    );

    if (mounted) {
      setState(() => _isSharing = false);
      if (success) {
        SnackBarHelper.showSuccess(context, AppStrings.moodPosterShared);
      } else {
        SnackBarHelper.showError(context, AppStrings.moodPosterShareFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryDate = DateTime.tryParse(widget.entry.date) ?? DateTime.now();
    final dateStr = DateFormat('EEEE • MMMM d, yyyy').format(entryDate);
    final moodUpper = widget.entry.mood.toUpperCase();
    final emoji = _getMoodEmoji(widget.entry.mood);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Movie-poster style hyped card
          RepaintBoundary(
            key: _posterKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E0826),
                    Color(0xFF380036),
                    Color(0xFF0C071E),
                    Color(0xFF0B192C),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.35),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top District Style Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFF007F),
                            width: 1.2,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFFFF007F),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'DISTRICT MOOD HYPED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        dateStr.split('•').first.trim().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Giant Glowing Emoji / Mood Badge
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF007F).withValues(alpha: 0.8),
                          const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 54)),
                  ),
                  const SizedBox(height: 16),

                  // Hyped Headline
                  Text(
                    'CURRENT VIBE: $moodUpper',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${widget.entry.title}"',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Daily Quote Snippet
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      widget.dailyQuote,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),

                  // Footer Watermark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_stories_rounded,
                            color: Color(0xFFFF007F),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MineAI Personal Diary',
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

          // Action Buttons
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
                  child: Text(
                    "close",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF007F),
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
                      : const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                  label: Text(
                    AppStrings.shareMoodVibe,
                    style: const TextStyle(
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
}
