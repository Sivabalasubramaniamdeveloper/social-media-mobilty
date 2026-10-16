import 'dart:convert';
import 'package:flutter/material.dart';

class DiaryEntryModel {
  final String id;
  final String userId;
  final String date; // YYYY-MM-DD
  final String title;
  final String content;
  final String mood; // 'happy', 'calm', 'neutral', 'sad', 'stressed'
  final int moodScore; // 1-5
  final String templateId;
  final String genderPreset; // 'men', 'women', 'classic'
  final List<String> imagePaths;
  final String? audioPath;
  final int audioDuration;
  final bool isSynced;
  final String createdAt;
  final String updatedAt;

  DiaryEntryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.content,
    required this.mood,
    required this.moodScore,
    required this.templateId,
    required this.genderPreset,
    required this.imagePaths,
    this.audioPath,
    this.audioDuration = 0,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'date': date,
    'title': title,
    'content': content,
    'mood': mood,
    'mood_score': moodScore,
    'template_id': templateId,
    'gender_preset': genderPreset,
    'image_paths': jsonEncode(imagePaths),
    'audio_path': audioPath,
    'audio_duration': audioDuration,
    'is_synced': isSynced ? 1 : 0,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory DiaryEntryModel.fromMap(Map<String, dynamic> map) => DiaryEntryModel(
    id: map['id'],
    userId: map['user_id'],
    date: map['date'],
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    mood: map['mood'] ?? 'happy',
    moodScore: map['mood_score'] ?? 3,
    templateId: map['template_id'] ?? 'midnight_slate',
    genderPreset: map['gender_preset'] ?? 'classic',
    imagePaths: List<String>.from(jsonDecode(map['image_paths'] ?? '[]')),
    audioPath: map['audio_path'],
    audioDuration: map['audio_duration'] ?? 0,
    isSynced: (map['is_synced'] ?? 0) == 1,
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
  );
}

// Background Visual Themes (Specially Curated For Preferences)
class DiaryTemplate {
  final String id;
  final String name;
  final String category; // 'men', 'women', 'minimal'
  final List<Color> gradientColors;
  final Color cardColor;
  final Color fontColor;
  final Color accentColor;

  const DiaryTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.gradientColors,
    required this.cardColor,
    required this.fontColor,
    required this.accentColor,
  });

  static const List<DiaryTemplate> allTemplates = [
    // Tailored Masculine / Sleek Tech Aesthetics
    DiaryTemplate(
      id: 'midnight_slate',
      name: 'Cyber Noir',
      category: 'men',
      gradientColors: [Color(0xFF0F172A), Color(0xFF020617)],
      cardColor: Color(0xFF1E293B),
      fontColor: Color(0xFFE2E8F0),
      accentColor: Color(0xFF38BDF8),
    ),
    DiaryTemplate(
      id: 'titanium_carbon',
      name: 'Carbon Edge',
      category: 'men',
      gradientColors: [Color(0xFF18181B), Color(0xFF09090B)],
      cardColor: Color(0xFF27272A),
      fontColor: Colors.white,
      accentColor: Color(0xFFA855F7),
    ),
    // Tailored Feminine / Soft Dream Aesthetics
    DiaryTemplate(
      id: 'blush_rosegold',
      name: 'Rose Romance',
      category: 'women',
      gradientColors: [Color(0xFF2C1827), Color(0xFF1A0B1A)],
      cardColor: Color(0xFF3D2137),
      fontColor: Color(0xFFFCE7F3),
      accentColor: Color(0xFFF472B6),
    ),
    DiaryTemplate(
      id: 'lavender_mist',
      name: 'Lavender Dusk',
      category: 'women',
      gradientColors: [Color(0xFF1E1738), Color(0xFF130E26)],
      cardColor: Color(0xFF2C224D),
      fontColor: Color(0xFFEDE9FE),
      accentColor: Color(0xFFC084FC),
    ),
    // Universal Clean Theme
    DiaryTemplate(
      id: 'deep_galaxy',
      name: 'Deep Galaxy',
      category: 'minimal',
      gradientColors: [Color(0xFF161426), Color(0xFF0D0B18)],
      cardColor: Color(0xFF201B38),
      fontColor: Colors.white,
      accentColor: Color(0xFFA78BFA),
    ),
  ];
}
