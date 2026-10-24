import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import '../models/news_article_model.dart';

class CityNewsScreen extends StatefulWidget {
  const CityNewsScreen({super.key});

  @override
  State<CityNewsScreen> createState() => _CityNewsScreenState();
}

class _CityNewsScreenState extends State<CityNewsScreen> {
  final List<String> _popularCities = [
    'Chennai',
    'Bengaluru',
    'Mumbai',
    'Delhi',
    'Hyderabad',
    'Kolkata',
    'Coimbatore',
    'Madurai',
  ];

  String _selectedProvider = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NewsCubit>().loadNews();
  }

  Future<void> _openArticle(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        SnackBarHelper.showError(context, AppStrings.newsArticleLinkError);
      }
    }
  }

  void _shareArticle(NewsArticleModel article) {
    final text =
        '${article.title}\n\n${AppStrings.readFullStory}: ${article.link}\n(via MineAI)';
    SharePlus.instance.share(ShareParams(text: text, subject: article.title));
  }

  Color _getProviderColor(String source) {
    final s = source.toLowerCase();
    if (s.contains('hindu')) return const Color(0xFF1D4ED8); // Deep Blue
    if (s.contains('times')) return const Color(0xFFDC2626); // Crimson Red
    if (s.contains('express')) return const Color(0xFFD97706); // Amber
    return const Color(0xFF8B5CF6); // Purple
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppScreenHeader(
                  title: AppStrings.localCityNews,
                  centerTitle: true,
                  onBack: () => context.pop(),
                ),
              ),

              // City Quick Select Chips
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _popularCities.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final city = _popularCities[index];
                    return BlocBuilder<NewsCubit, NewsState>(
                      builder: (context, state) {
                        final currentCity =
                            state is NewsLoaded ? state.city : 'Chennai';
                        final isSelected =
                            currentCity.toLowerCase() == city.toLowerCase();

                        return ChoiceChip(
                          avatar: Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : scheme.primary.withValues(alpha: 0.8),
                          ),
                          label: Text(city),
                          selected: isSelected,
                          selectedColor: scheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : scheme.onSurface.withValues(alpha: 0.85),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12,
                          ),
                          backgroundColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF1E1B38),
                          side: BorderSide(
                            color: isSelected
                                ? scheme.primary
                                : (isLight ? Colors.black12 : Colors.white10),
                          ),
                          onSelected: (val) {
                            if (val && !isSelected) {
                              context.read<NewsCubit>().loadNews(
                                city: city,
                                provider: _selectedProvider,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Provider Filters Row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildProviderFilterChip('all', AppStrings.providerAll),
                      const SizedBox(width: 8),
                      _buildProviderFilterChip('the_hindu', AppStrings.providerTheHindu),
                      const SizedBox(width: 8),
                      _buildProviderFilterChip('times_of_india', AppStrings.providerToi),
                      const SizedBox(width: 8),
                      _buildProviderFilterChip('other', AppStrings.providerOther),
                    ],
                  ),
                ),
              ),

              // Main Articles Area
              Expanded(
                child: BlocBuilder<NewsCubit, NewsState>(
                  builder: (context, state) {
                    if (state is NewsLoading) {
                      return _buildSkeletonLoading(context);
                    }

                    if (state is NewsError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 54,
                                color: scheme.error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.newsArticleLinkError,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: Text(AppStrings.retry),
                                onPressed: () =>
                                    context.read<NewsCubit>().loadNews(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is NewsLoaded) {
                      final articles = _filterArticlesByProvider(
                        state.articles,
                        _selectedProvider,
                      );

                      if (articles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.newspaper_rounded,
                                size: 56,
                                color: scheme.primary.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                AppStrings.noNewsFound,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final heroArticle = articles.first;
                      final otherArticles = articles.skip(1).toList();

                      return RefreshIndicator(
                        onRefresh: () => context.read<NewsCubit>().loadNews(
                          city: state.city,
                          provider: _selectedProvider,
                        ),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                          children: [
                            // Live City Banner
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${state.city.toUpperCase()} • ${articles.length} STORIES',
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    AppStrings.selectedCityOnly,
                                    style: TextStyle(
                                      color: scheme.onSurface.withValues(alpha: 0.6),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Top Featured Hero Magazine Card
                            _buildHeroCard(context, heroArticle),

                            const SizedBox(height: 18),

                            // Remaining Feed Articles
                            ...otherArticles.map((article) =>
                                _buildCompactArticleCard(context, article)),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<NewsArticleModel> _filterArticlesByProvider(
    List<NewsArticleModel> list,
    String provider,
  ) {
    if (provider == 'all') return list;
    final p = provider.toLowerCase().replaceAll('_', '');
    return list.where((a) {
      final s = a.source.toLowerCase().replaceAll(' ', '');
      if (p == 'thehindu') return s.contains('hindu');
      if (p == 'timesofindia') return s.contains('times');
      if (p == 'other') return !s.contains('hindu') && !s.contains('times');
      return true;
    }).toList();
  }

  Widget _buildProviderFilterChip(String key, String label) {
    final isSel = _selectedProvider == key;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return FilterChip(
      selected: isSel,
      label: Text(label),
      showCheckmark: false,
      selectedColor: scheme.primary.withValues(alpha: 0.2),
      backgroundColor: isLight
          ? scheme.surfaceContainerHighest.withValues(alpha: 0.6)
          : const Color(0xFF1E1B38),
      side: BorderSide(
        color: isSel ? scheme.primary : Colors.transparent,
        width: 1.2,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
        color: isSel ? scheme.primary : scheme.onSurface.withValues(alpha: 0.75),
      ),
      onSelected: (_) {
        setState(() => _selectedProvider = key);
      },
    );
  }

  Widget _buildHeroCard(BuildContext context, NewsArticleModel article) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final providerColor = _getProviderColor(article.source);

    return InkWell(
      onTap: () => _openArticle(article.link),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? scheme.surface : const Color(0xFF1A1733),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLight ? Colors.black12 : Colors.white12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High-Res Image with Gradient Overlay
            Stack(
              children: [
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  Image.network(
                    article.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackImagePlaceholder(scheme),
                  )
                else
                  _fallbackImagePlaceholder(scheme),

                // Dark Bottom Scrim
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Source Badge & Published Time
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: providerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      article.source.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // City Tag
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      article.city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  if (article.snippet.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      article.snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(article.pubDate),
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 18),
                            color: scheme.primary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _shareArticle(article),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  AppStrings.readFullStory,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactArticleCard(BuildContext context, NewsArticleModel article) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final providerColor = _getProviderColor(article.source);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLight ? Colors.black.withValues(alpha: 0.06) : Colors.white10,
        ),
      ),
      child: InkWell(
        onTap: () => _openArticle(article.link),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: providerColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.source,
                            style: TextStyle(
                              color: providerColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(article.pubDate),
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    if (article.snippet.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 86,
                  height: 86,
                  color: isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF262344),
                  child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? Image.network(
                          article.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _fallbackImagePlaceholder(scheme),
                        )
                      : _fallbackImagePlaceholder(scheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackImagePlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.newspaper_rounded,
        color: scheme.primary.withValues(alpha: 0.5),
        size: 30,
      ),
    );
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight ? Colors.grey[300]! : const Color(0xFF262344);
    final highlightColor = isLight ? Colors.grey[100]! : const Color(0xFF322E58);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Hero Skeleton
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 16),
          // List Skeletons
          ...List.generate(
            4,
            (_) => Container(
              height: 96,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (_) {
      return 'Recent';
    }
  }
}
