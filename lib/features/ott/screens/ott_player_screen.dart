import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../../../config/router/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/ott_video.dart';

class _HlsRendition {
  final String label;
  final Uri uri;

  const _HlsRendition(this.label, this.uri);
}

class OttPlayerScreen extends StatefulWidget {
  final OttVideo video;

  const OttPlayerScreen({super.key, required this.video});

  @override
  State<OttPlayerScreen> createState() => _OttPlayerScreenState();
}

class _OttPlayerScreenState extends State<OttPlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  List<_HlsRendition> _renditions = const [];
  String? _selectedQuality;
  String? _error;
  bool _initializing = true;
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _fitCover = false;
  double _currentSpeed = 1.0;
  Timer? _hideTimer;

  // Double tap seek animations
  bool _showRewindIndicator = false;
  bool _showForwardIndicator = false;
  Timer? _indicatorTimer;

  @override
  void initState() {
    super.initState();
    _preparePlayer();
  }

  // Future<void> _preparePlayer() async {
  //   try {
  //     _renditions = await _readRenditions();
  //   } catch (e) {
  //     debugPrint('OTT QUALITY LIST UNAVAILABLE: $e');
  //     _renditions = const [];
  //   }
  //   if (!mounted) return;
  //   await _initializePlayer(Uri.parse(widget.video.hlsUrl));
  // }
  Future<void> _preparePlayer() async {
    try {
      _renditions = await _readRenditions();
    } catch (e) {
      debugPrint('OTT QUALITY LIST UNAVAILABLE: $e');
      _renditions = const [];
    }
    if (!mounted) return;

    // Prefer a mid-quality variant instead of master playlist
    final preferred =
        _renditions.where((r) {
          final h = int.tryParse(r.label.replaceAll('p', '')) ?? 9999;
          return h >= 480 && h <= 720;
        }).firstOrNull ??
        _renditions.firstOrNull;

    final startUri = preferred?.uri ?? Uri.parse(widget.video.hlsUrl);
    await _initializePlayer(startUri);
  }

  Future<List<_HlsRendition>> _readRenditions() async {
    final masterUri = Uri.parse(widget.video.hlsUrl);
    final response = await http
        .get(masterUri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Playlist returned HTTP ${response.statusCode}');
    }

    final lines = response.body.split(RegExp(r'\r?\n'));
    final renditions = <_HlsRendition>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('#EXT-X-STREAM-INF:')) continue;

      String? variantPath;
      for (var next = i + 1; next < lines.length; next++) {
        final candidate = lines[next].trim();
        if (candidate.isEmpty) continue;
        if (!candidate.startsWith('#')) {
          variantPath = candidate;
          break;
        }
      }
      if (variantPath == null) continue;

      final resolution = RegExp(
        r'(?:^|,)RESOLUTION=(\d+)x(\d+)(?:,|$)',
      ).firstMatch(line.substring('#EXT-X-STREAM-INF:'.length));
      final height = resolution == null
          ? null
          : int.tryParse(resolution.group(2)!);
      final bandwidth = RegExp(
        r'(?:^|,)BANDWIDTH=(\d+)(?:,|$)',
      ).firstMatch(line.substring('#EXT-X-STREAM-INF:'.length));
      final label = height != null
          ? '${height}p'
          : bandwidth != null
          ? '${(int.parse(bandwidth.group(1)!) / 1000000).toStringAsFixed(1)} Mbps'
          : 'Variant ${renditions.length + 1}';
      renditions.add(_HlsRendition(label, masterUri.resolve(variantPath)));
    }

    final seenLabels = <String>{};
    return renditions.where((item) => seenLabels.add(item.label)).toList()
      ..sort((a, b) => _qualityRank(b.label).compareTo(_qualityRank(a.label)));
  }

  int _qualityRank(String label) =>
      int.tryParse(label.replaceAll('p', '')) ?? 0;

  void _onPlayerUpdate() {
    final value = _controller?.value;
    if (value == null) return;
    if (value.hasError) {
      final message = value.errorDescription ?? 'Unknown native player error';
      debugPrint('OTT PLAYER ERROR: $message');
      if (mounted && _error != message) setState(() => _error = message);
    } else if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializePlayer(Uri source, {Duration? resumeAt}) async {
    if (!mounted) return;
    setState(() {
      _initializing = true;
      _error = null;
    });

    final previous = _controller;
    if (previous != null) {
      previous.removeListener(_onPlayerUpdate);
      _controller = null;
      await previous.dispose();
    }

    final controller = VideoPlayerController.networkUrl(source);
    _controller = controller;
    controller.addListener(_onPlayerUpdate);

    try {
      await controller.initialize();
      await controller.setPlaybackSpeed(_currentSpeed);
      if (resumeAt != null && resumeAt > Duration.zero) {
        await controller.seekTo(resumeAt);
      }
      if (!mounted) return;
      setState(() => _initializing = false);
      await controller.play();
      _startHideControlsTimer();
    } catch (e) {
      debugPrint('OTT INITIALIZATION FAILED: $e');
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = e.toString();
      });
    }
  }

  void _startHideControlsTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _seekRelative(int seconds) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final current = controller.value.position;
    final total = controller.value.duration;
    final target = current + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > total ? total : target);

    controller.seekTo(clamped);

    _indicatorTimer?.cancel();
    if (seconds < 0) {
      setState(() {
        _showRewindIndicator = true;
        _showForwardIndicator = false;
      });
    } else {
      setState(() {
        _showForwardIndicator = true;
        _showRewindIndicator = false;
      });
    }

    _indicatorTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showRewindIndicator = false;
          _showForwardIndicator = false;
        });
      }
    });

    _startHideControlsTimer();
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      controller.play();
      _startHideControlsTimer();
      setState(() {});
    }
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  Future<void> _selectQuality(String? label) async {
    if (label == null || _initializing) return;
    final controller = _controller;
    final rendition = _renditions
        .where((item) => item.label == label)
        .firstOrNull;
    final source = rendition?.uri ?? Uri.parse(widget.video.hlsUrl);
    final position = controller?.value.position;
    setState(() => _selectedQuality = label);
    await _initializePlayer(source, resumeAt: position);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    _currentSpeed = speed;
    await _controller?.setPlaybackSpeed(speed);
    setState(() {});
  }

  void _showQualityModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentLabel = _selectedQuality ?? AppStrings.qualityAuto;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.high_quality_rounded,
                        color: AppColors.primaryPurple,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.videoQuality,
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.cardBorder),
                ListTile(
                  leading: Icon(
                    Icons.auto_awesome,
                    color: currentLabel == AppStrings.qualityAuto
                        ? AppColors.primaryPurple
                        : AppColors.secondaryText,
                  ),
                  title: Text(
                    AppStrings.qualityAuto,
                    style: TextStyle(
                      color: currentLabel == AppStrings.qualityAuto
                          ? AppColors.primaryPurple
                          : AppColors.whiteColor,
                      fontWeight: currentLabel == AppStrings.qualityAuto
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: currentLabel == AppStrings.qualityAuto
                      ? const Icon(Icons.check, color: AppColors.primaryPurple)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _selectQuality('Auto');
                  },
                ),
                ..._renditions.map((rendition) {
                  final isSelected = rendition.label == _selectedQuality;
                  return ListTile(
                    leading: Icon(
                      Icons.hd_outlined,
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.secondaryText,
                    ),
                    title: Text(
                      rendition.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.whiteColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryPurple,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _selectQuality(rendition.label);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSpeedModal() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.speed_rounded,
                        color: AppColors.primaryPurple,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.playbackSpeed,
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.cardBorder),
                ...speeds.map((s) {
                  final isCurrent = (s - _currentSpeed).abs() < 0.05;
                  return ListTile(
                    title: Text(
                      s == 1.0 ? '${s}x (${AppStrings.normalSpeed})' : '${s}x',
                      style: TextStyle(
                        color: isCurrent
                            ? AppColors.primaryPurple
                            : AppColors.whiteColor,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isCurrent
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryPurple,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _setPlaybackSpeed(s);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _handleBackNavigation() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.mineAiStreams);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _indicatorTimer?.cancel();
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onPlayerUpdate);
      controller.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: AppColors.primaryThemeBackground,
      body: SafeArea(
        top: !_isFullscreen,
        bottom: !_isFullscreen,
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Video Canvas with Double-Tap Areas
              if (ready)
                GestureDetector(
                  onTap: _toggleControls,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: _fitCover
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: controller.value.size.width,
                                height: controller.value.size.height,
                                child: VideoPlayer(controller),
                              ),
                            ),
                          )
                        : AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                  ),
                ),

              // Left/Right double-tap detection zones for 10s seek
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onDoubleTap: () => _seekRelative(-10),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onDoubleTap: () => _seekRelative(10),
                      ),
                    ),
                  ],
                ),
              ),

              // Double tap seek indicators
              if (_showRewindIndicator)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.replay_10_rounded,
                          color: AppColors.primaryPurpleLight,
                          size: 42,
                        ),
                        SizedBox(height: 6),
                        Text(
                          '-10 sec',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_showForwardIndicator)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.forward_10_rounded,
                          color: AppColors.primaryPurpleLight,
                          size: 42,
                        ),
                        SizedBox(height: 6),
                        Text(
                          '+10 sec',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 2. Loading State
              if (_initializing || !ready && _error == null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDeep.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Error State
              if (_error != null)
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDeep,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.expenseRed,
                          size: 52,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.videoPlaybackFailed,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.videoPlaybackFailedDesc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: AppColors.whiteColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _initializePlayer(
                            _selectedQuality == null ||
                                    _selectedQuality == 'Auto'
                                ? Uri.parse(widget.video.hlsUrl)
                                : _renditions
                                      .firstWhere(
                                        (item) =>
                                            item.label == _selectedQuality,
                                      )
                                      .uri,
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(AppStrings.retry),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.whiteColor,
                            side: BorderSide(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _handleBackNavigation,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(AppStrings.exitToStreams),
                        ),
                      ],
                    ),
                  ),
                ),

              // Persistent Back Button for Error or Loading states
              if (_error != null || !ready)
                Positioned(
                  top: 14,
                  left: 14,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleBackNavigation,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. Overlays & Controls
              if (ready && _error == null)
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Stack(
                      children: [
                        // Gradient Backdrops for Controls
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 140,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.9),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Top Bar: Back, Video Title, Quality, Speed, Aspect ratio
                        Positioned(
                          top: 12,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.5,
                                  ),
                                  foregroundColor: AppColors.whiteColor,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                ),
                                onPressed: _handleBackNavigation,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.video.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (widget.video.category.isNotEmpty)
                                      Text(
                                        widget.video.category.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.accentBlue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Aspect Ratio Toggle
                              IconButton.filled(
                                tooltip: _fitCover
                                    ? AppStrings.originalAspectRatio
                                    : AppStrings.fitToScreen,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.5,
                                  ),
                                  foregroundColor: _fitCover
                                      ? AppColors.accentBlue
                                      : AppColors.whiteColor,
                                ),
                                icon: Icon(
                                  _fitCover
                                      ? Icons.aspect_ratio_rounded
                                      : Icons.fit_screen_rounded,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _fitCover = !_fitCover),
                              ),
                              const SizedBox(width: 6),
                              // Speed Button
                              InkWell(
                                onTap: _showSpeedModal,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Text(
                                    '${_currentSpeed}x',
                                    style: const TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Quality Button
                              InkWell(
                                onTap: _showQualityModal,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primaryPurple.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.hd_rounded,
                                        color: AppColors.primaryPurpleLight,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _selectedQuality ??
                                            AppStrings.qualityAuto,
                                        style: const TextStyle(
                                          color: AppColors.whiteColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Center Controls: Rewind 10, Play/Pause, Forward 10
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 42,
                                color: AppColors.whiteColor.withValues(
                                  alpha: 0.9,
                                ),
                                icon: const Icon(Icons.replay_10_rounded),
                                onPressed: () => _seekRelative(-10),
                              ),
                              const SizedBox(width: 32),
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primaryPurple,
                                        AppColors.primaryPurpleDark,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple
                                            .withValues(alpha: 0.4),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    controller.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppColors.whiteColor,
                                    size: 42,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              IconButton(
                                iconSize: 42,
                                color: AppColors.whiteColor.withValues(
                                  alpha: 0.9,
                                ),
                                icon: const Icon(Icons.forward_10_rounded),
                                onPressed: () => _seekRelative(10),
                              ),
                            ],
                          ),
                        ),

                        // Bottom Controls: Time, Slider, Fullscreen
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _formatDuration(controller.value.position),
                                    style: const TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor:
                                            AppColors.primaryPurple,
                                        inactiveTrackColor: Colors.white24,
                                        thumbColor: AppColors.accentBlue,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 12,
                                            ),
                                        trackHeight: 3.5,
                                      ),
                                      child: Slider(
                                        min: 0.0,
                                        max:
                                            controller
                                                    .value
                                                    .duration
                                                    .inMilliseconds
                                                    .toDouble() >
                                                0
                                            ? controller
                                                  .value
                                                  .duration
                                                  .inMilliseconds
                                                  .toDouble()
                                            : 1.0,
                                        value: controller
                                            .value
                                            .position
                                            .inMilliseconds
                                            .toDouble()
                                            .clamp(
                                              0.0,
                                              controller
                                                          .value
                                                          .duration
                                                          .inMilliseconds
                                                          .toDouble() >
                                                      0
                                                  ? controller
                                                        .value
                                                        .duration
                                                        .inMilliseconds
                                                        .toDouble()
                                                  : 1.0,
                                            ),
                                        onChanged: (val) {
                                          _hideTimer?.cancel();
                                          controller.seekTo(
                                            Duration(milliseconds: val.toInt()),
                                          );
                                        },
                                        onChangeEnd: (_) =>
                                            _startHideControlsTimer(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _formatDuration(controller.value.duration),
                                    style: const TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: Icon(
                                      _isFullscreen
                                          ? Icons.fullscreen_exit_rounded
                                          : Icons.fullscreen_rounded,
                                      color: AppColors.whiteColor,
                                      size: 26,
                                    ),
                                    onPressed: _toggleFullscreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
}
