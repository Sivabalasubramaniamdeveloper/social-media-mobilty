import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primaryThemeBackground,
    body: FutureBuilder<List<OttVideo>>(
      future: _videos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
          );
        }
        if (snapshot.hasError) {
          return _message(
            'We couldn’t load the collection.',
            'Check your connection and try again.',
            retry: true,
          );
        }
        final videos = snapshot.data ?? [];
        if (videos.isEmpty) {
          return _message(
            'Your next favorite is coming.',
            'Published titles will appear here.',
          );
        }
        final categories = [
          'For you',
          ...videos.map((v) => v.category).where((c) => c.isNotEmpty).toSet(),
        ];
        final visible = _category == 'For you'
            ? videos
            : videos.where((v) => v.category == _category).toList();
        final featured = videos.first;
        return RefreshIndicator(
          color: AppColors.primaryPurple,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            setState(() => _videos = _api.getVideos());
            await _videos;
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _hero(featured)),
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
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primaryPurple,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.whiteColor : AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: selected ? AppColors.primaryPurple : AppColors.cardBorder,
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
                    _category == 'For you' ? 'Popular right now' : _category,
                    style: const TextStyle(
                      color: AppColors.whiteColor,
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
                    (context, i) => _poster(visible[i]),
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

  Widget _hero(OttVideo video) => SizedBox(
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
                Colors.black.withValues(alpha: 0.6),
                Colors.transparent,
                AppColors.primaryThemeBackground,
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
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.accentBlue],
                    ),
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
                const Text(
                  'MINE STREAM',
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: AppColors.surface,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.whiteColor),
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
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
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
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                video.category.isEmpty
                    ? 'ORIGINAL • NOW STREAMING'
                    : '${video.category.toUpperCase()}  •  NOW STREAMING',
                style: const TextStyle(
                  color: AppColors.secondaryText,
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
                  style: const TextStyle(color: AppColors.secondaryText, height: 1.4),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: AppColors.whiteColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      foregroundColor: AppColors.whiteColor,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _poster(OttVideo video) => GestureDetector(
    onTap: () => _play(video),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
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
                          Colors.black.withValues(alpha: 0.6),
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
                        color: AppColors.primaryPurple.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
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
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          video.category,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _image(String? url, {BoxFit fit = BoxFit.cover}) =>
      url == null || url.isEmpty
          ? Container(
              color: AppColors.surface,
              child: const Center(
                child: Icon(Icons.movie_outlined, color: AppColors.hintText, size: 40),
              ),
            )
          : Image.network(
              url,
              fit: fit,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(
                    Icons.movie_outlined,
                    color: AppColors.hintText,
                    size: 40,
                  ),
                ),
              ),
            );

  Widget _message(String title, String subtitle, {bool retry = false}) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.live_tv_rounded, color: AppColors.primaryPurple, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
              if (retry) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: AppColors.whiteColor,
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

  void _play(OttVideo video) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => OttPlayerScreen(video: video)));
}
