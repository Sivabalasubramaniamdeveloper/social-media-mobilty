import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/ott_video.dart';
import '../services/ott_api_service.dart';
import 'ott_player_screen.dart';

class OttHomeScreen extends StatefulWidget {
  const OttHomeScreen({super.key});

  @override
  State<OttHomeScreen> createState() => _OttHomeScreenState();
}

class _OttHomeScreenState extends State<OttHomeScreen> {
  final _api = OttApiService();
  late Future<List<OttVideo>> _videos;
  String _category = 'For you';

  @override
  void initState() {
    super.initState();
    _videos = _api.getVideos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<List<OttVideo>>(
        future: _videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader(context, isLight, scheme);
          }
          if (snapshot.hasError) {
            return _message(
              context,
              AppStrings.ottLoadError,
              AppStrings.ottRetrySub,
              retry: true,
            );
          }
          final videos = snapshot.data ?? [];
          if (videos.isEmpty) {
            return _message(
              context,
              AppStrings.ottEmptyTitle,
              AppStrings.ottEmptySub,
            );
          }
          final categories = [
            AppStrings.forYou,
            ...videos.map((v) => v.category).where((c) => c.isNotEmpty).toSet(),
          ];
          final visible = _category == AppStrings.forYou || _category == 'For you'
              ? videos
              : videos.where((v) => v.category == _category).toList();
          final featured = videos.first;

          return RefreshIndicator(
            color: scheme.primary,
            backgroundColor: isLight ? scheme.surfaceContainerHighest : AppColors.surface,
            onRefresh: () async {
              setState(() => _videos = _api.getVideos());
              await _videos;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _hero(context, featured)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final item = categories[i];
                        final selected = _category == item;
                        return ChoiceChip(
                          label: Text(item),
                          selected: selected,
                          onSelected: (_) => setState(() => _category = item),
                          backgroundColor: isLight
                              ? scheme.surfaceContainerHighest
                              : AppColors.surface,
                          selectedColor: scheme.primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : scheme.onSurface.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: selected
                                ? scheme.primary
                                : (isLight ? scheme.outlineVariant.withValues(alpha: 0.5) : AppColors.cardBorder),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Text(
                      _category == AppStrings.forYou || _category == 'For you'
                          ? AppStrings.popularRightNow
                          : _category,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _poster(context, visible[i]),
                      childCount: visible.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 18,
                      childAspectRatio: .68,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hero(BuildContext context, OttVideo video) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return SizedBox(
      height: 480,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _image(video.posterUrl, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0, .4, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.developerAi,
                    style: TextStyle(
                      color: isLight ? scheme.onSurface : Colors.white,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: isLight
                        ? scheme.surfaceContainerHighest
                        : AppColors.surface.withValues(alpha: 0.8),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.close_rounded, color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppStrings.featured,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  video.category.isEmpty
                      ? '${AppStrings.original} • ${AppStrings.nowStreaming}'
                      : '${video.category.toUpperCase()} • ${AppStrings.nowStreaming}',
                  style: TextStyle(
                    color: isLight
                        ? AppColors.lightSecondaryOnSurface
                        : AppColors.secondaryText,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (video.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isLight
                          ? AppColors.lightSecondaryOnSurface
                          : AppColors.secondaryText,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _play(video),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        AppStrings.watchNow,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.onSurface,
                        side: BorderSide(
                          color: isLight
                              ? scheme.outlineVariant
                              : AppColors.cardBorder,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: Text(AppStrings.myList),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _poster(BuildContext context, OttVideo video) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return GestureDetector(
      onTap: () => _play(video),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLight
                      ? scheme.outlineVariant.withValues(alpha: 0.5)
                      : AppColors.cardBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _image(video.posterUrl, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            video.category,
            style: TextStyle(
              color: isLight
                  ? AppColors.lightSecondaryOnSurface
                  : AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(String? url, {BoxFit fit = BoxFit.cover}) =>
      url == null || url.isEmpty
          ? Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.movie_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 40,
                ),
              ),
            )
          : Image.network(
              url,
              fit: fit,
              errorBuilder: (_, _, _) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.movie_outlined,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 40,
                  ),
                ),
              ),
            );

  Widget _message(BuildContext context, String title, String subtitle, {bool retry = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.live_tv_rounded, color: scheme.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
              ),
            ),
            if (retry) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => setState(() => _videos = _api.getVideos()),
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _play(OttVideo video) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => OttPlayerScreen(video: video)));

  Widget _buildSkeletonLoader(
    BuildContext context,
    bool isLight,
    ColorScheme scheme,
  ) {
    final baseColor = isLight ? Colors.grey[300]! : const Color(0xFF1E1B38);
    final highlightColor = isLight ? Colors.grey[100]! : const Color(0xFF2E2752);

    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Header bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero Featured Video skeleton
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),

            // Category pills skeleton
            Row(
              children: List.generate(
                4,
                (i) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 72,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section title skeleton
            Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 14),

            // Grid cards skeleton
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (_, _) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
