import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/features/diary/services/diary_database_service.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/diary_cubit.dart';
import '../models/diary_entry_model.dart';

class DiaryEntryEditorScreen extends StatefulWidget {
  final String userId;
  final DateTime selectedDate;
  final DiaryEntryModel? existingEntry;

  const DiaryEntryEditorScreen({
    super.key,
    required this.userId,
    required this.selectedDate,
    this.existingEntry,
  });

  @override
  State<DiaryEntryEditorScreen> createState() => _DiaryEntryEditorScreenState();
}

class _DiaryEntryEditorScreenState extends State<DiaryEntryEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _currentMood = 'happy';
  int _currentMoodScore = 5;
  String _activeTemplateId = 'minimal_theme';

  List<String> _imagePaths = [];
  String? _audioPath;

  Map<String, int> get _moodMap => {
    '😄 ${AppStrings.moodHappy}': 5,
    '😌 ${AppStrings.moodCalm}': 4,
    '😐 ${AppStrings.moodNeutral}': 3,
    '😔 ${AppStrings.moodSad}': 2,
    '😫 ${AppStrings.moodStressed}': 1,
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      final e = widget.existingEntry!;
      _titleController.text = e.title;
      _contentController.text = e.content;
      _currentMood = e.mood;
      _currentMoodScore = e.moodScore;
      _activeTemplateId = e.templateId;
      _imagePaths = List.from(e.imagePaths);
      _audioPath = e.audioPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showUpgradeDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B38),
        title: Text(
          AppStrings.planLimitReached,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.dismiss,
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push(RouteNames.subscription);
            },
            child: Text(
              AppStrings.viewPlans,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPickImages() async {
    final subState = context.read<SubscriptionCubit>().state;
    final plan = subState is SubscriptionLoaded
        ? subState.plan
        : SubscriptionPlan.fromTierCode(0);
    String userid = await UserHelper.getCurrentUserId();
    // 1. Fetch current usage (total for Basic, current month for Pro/Premium)
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final usedCount = await DiaryDatabaseService.instance
        .getUploadedImagesCount(
          userid,
          monthYear: plan.isMonthlyImageLimit ? currentMonth : null,
        );

    final remainingQuota = plan.diaryImageLimit - usedCount;
    if (!mounted) return;

    if (remainingQuota <= 0) {
      _showUpgradeDialog(
        context,
        AppStrings.imageQuotaReached(
          plan.diaryImageLimit,
          plan.isMonthlyImageLimit ? AppStrings.thisMonth : AppStrings.allTime,
        ),
      );
      return;
    }

    // 2. Select images, capping at remainingQuota
    final List<XFile> picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty || !mounted) return;

    if (picked.length > remainingQuota) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.remainingImageQuota(remainingQuota)),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }

    final acceptedPaths = picked
        .take(remainingQuota)
        .map((e) => e.path)
        .toList();
    setState(() {
      _imagePaths.addAll(acceptedPaths);
    });
  }

  Future<void> _save() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    final entry = DiaryEntryModel(
      id: widget.existingEntry?.id ?? const Uuid().v4(),
      userId: widget.userId,
      date: dateStr,
      title: _titleController.text.trim().isEmpty
          ? AppStrings.defaultHeadline(
              DateFormat('MMM dd').format(widget.selectedDate),
            )
          : _titleController.text.trim(),
      content: _contentController.text.trim(),
      mood: _currentMood,
      moodScore: _currentMoodScore,
      templateId: _activeTemplateId,
      genderPreset: 'neutral',
      imagePaths: _imagePaths,
      audioPath: _audioPath,
      createdAt:
          widget.existingEntry?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await context.read<DiaryCubit>().saveEntry(entry);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          DateFormat('MMMM dd, yyyy').format(widget.selectedDate),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              AppStrings.save,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.howAreYouFeeling,
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _moodMap.entries.map((m) {
                  final isSel = _currentMoodScore == m.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSel,
                      label: Text(m.key),
                      selectedColor: scheme.primary.withOpacity(0.25),
                      backgroundColor: scheme.surface,
                      labelStyle: TextStyle(
                        color: isSel ? scheme.primary : scheme.onSurface,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _currentMood = m.key.split(' ').last.toLowerCase();
                            _currentMoodScore = m.value;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Content Area Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.onSurface.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.headlineHint,
                      hintStyle: TextStyle(
                        color: scheme.onSurface.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(color: scheme.onSurface.withOpacity(0.08)),
                  TextField(
                    controller: _contentController,
                    maxLines: 9,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.contentHint,
                      hintStyle: TextStyle(
                        color: scheme.onSurface.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Picked Images
            if (_imagePaths.isNotEmpty) ...[
              SizedBox(
                height: 85,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.file(
                            File(_imagePaths[i]),
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _imagePaths.removeAt(i)),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.primary,
                    side: BorderSide(color: scheme.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _onPickImages,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(AppStrings.addImages),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.primary,
                    side: BorderSide(color: scheme.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.voiceRecordedMsg)),
                    );
                  },
                  icon: const Icon(Icons.mic_none_rounded, size: 18),
                  label: Text(AppStrings.voiceNote),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
