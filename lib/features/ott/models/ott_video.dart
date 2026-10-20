import '../../../config/env/env_config.dart';

class OttVideo {
  final String id;
  final String title;
  final String description;
  final String category;
  final String hlsUrl;
  final String? posterUrl;
  final int? durationSeconds;

  const OttVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.hlsUrl,
    this.posterUrl,
    this.durationSeconds,
  });

  factory OttVideo.fromJson(Map<String, dynamic> json) {
    String storageUrl(Object? value) {
      final path = value?.toString() ?? '';
      if (path.isEmpty) return '';
      if (path.startsWith('http://') || path.startsWith('https://')) return path;
      final cleanPath = path.startsWith('ott-videos/') ? path.substring('ott-videos/'.length) : path;
      return '${EnvConfig.supabaseUrl}/storage/v1/object/public/ott-videos/$cleanPath';
    }
    return OttVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      hlsUrl: storageUrl(json['hls_url'] ?? json['hls_path']),
      posterUrl: storageUrl(json['poster_url'] ?? json['poster_path']),
      durationSeconds: json['duration_seconds'] as int?,
    );
  }
}
