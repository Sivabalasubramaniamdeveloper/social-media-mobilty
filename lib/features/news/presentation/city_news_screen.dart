import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import '../models/news_article_model.dart';

class CityNewsScreen extends StatefulWidget {
  const CityNewsScreen({super.key});

  @override
  State<CityNewsScreen> createState() => _CityNewsScreenState();
}

class _CityNewsScreenState extends State<CityNewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _popularCities = [
    'Chennai',
    'Bengaluru',
    'Mumbai',
    'Delhi',
    'Hyderabad',
    'Kolkata',
  ];

  @override
  void initState() {
    super.initState();
    context.read<NewsCubit>().loadNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openArticle(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Could not open article link: $e');
      }
    }
  }

  void _shareArticle(NewsArticleModel article) {
    final text = '${article.title}\n\nRead more: ${article.link}\n(via MineAI News)';
    SharePlus.instance.share(ShareParams(text: text, subject: article.title));
  }

  void _shareViaEmail(NewsArticleModel article) async {
    final subject = Uri.encodeComponent(article.title);
    final body = Uri.encodeComponent(
      'Check out this news from ${article.city}:\n\n${article.title}\n\n${article.snippet}\n\nRead full story: ${article.link}\n\nShared via MineAI',
    );
    final mailto = Uri.parse('mailto:?subject=$subject&body=$body');
    try {
      if (await canLaunchUrl(mailto)) {
        await launchUrl(mailto, mode: LaunchMode.externalApplication);
      } else {
        _shareArticle(article);
      }
    } catch (_) {
      _shareArticle(article);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppScreenHeader(
                  title: 'Local City News',
                  centerTitle: true,
                  onBack: () => context.pop(),
                ),
              ),

              // City Quick Select Chips
              Container(
                height: 38,
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
                          label: Text(city),
                          selected: isSelected,
                          selectedColor: scheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : scheme.onSurface.withValues(alpha: 0.8),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
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
                          onSelected: (_) {
                            context.read<NewsCubit>().loadNews(city: city);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: BlocConsumer<NewsCubit, NewsState>(
                  listener: (context, state) {
                    if (state is NewsError) {
                      SnackBarHelper.showError(
                        context,
                        'Failed to load news: ${state.message}',
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is NewsLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: scheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              'Web scraping local city headlines...',
                              style: TextStyle(
                                color: isLight
                                    ? AppColors.lightSecondaryOnSurface
                                    : AppColors.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is NewsLoaded) {
                      final articles = state.articles;
                      if (articles.isEmpty) {
                        return Center(
                          child: Text(
                            'No news found for ${state.city}. Pull to refresh.',
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async =>
                            context.read<NewsCubit>().loadNews(city: state.city),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: articles.length,
                          itemBuilder: (context, idx) {
                            return _buildNewsCard(
                              articles[idx],
                              scheme,
                              isLight,
                            );
                          },
                        ),
                      );
                    }

                    return Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Load Chennai News'),
                        onPressed: () => context
                            .read<NewsCubit>()
                            .loadNews(city: 'Chennai'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(
    NewsArticleModel article,
    ColorScheme scheme,
    bool isLight,
  ) {
    String formattedTime = '';
    try {
      final dt = DateTime.parse(article.pubDate);
      formattedTime = DateFormat('MMM d, hh:mm a').format(dt);
    } catch (_) {
      formattedTime = 'Recent';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLight ? Colors.black12 : Colors.white10,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openArticle(article.link),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with source and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.source,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: isLight
                            ? AppColors.lightSecondaryOnSurface
                            : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Headline
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    height: 1.3,
                  ),
                ),
                if (article.snippet.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    article.snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isLight
                          ? AppColors.lightSecondaryOnSurface
                          : AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tap to read full story →',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.mail_outline_rounded, size: 18),
                          tooltip: 'Share via Email',
                          color: scheme.onSurface.withValues(alpha: 0.7),
                          onPressed: () => _shareViaEmail(article),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 18),
                          tooltip: 'Share Article',
                          color: scheme.onSurface.withValues(alpha: 0.7),
                          onPressed: () => _shareArticle(article),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
