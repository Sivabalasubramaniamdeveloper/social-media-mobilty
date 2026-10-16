import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import '../cubit/product_scraper_cubit.dart';
import '../cubit/product_scraper_state.dart';
import '../models/product_scrape_model.dart';

class ProductScraperScreen extends StatefulWidget {
  const ProductScraperScreen({super.key});

  @override
  State<ProductScraperScreen> createState() => _ProductScraperScreenState();
}

class _ProductScraperScreenState extends State<ProductScraperScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<ProductScraperCubit>().searchProducts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProductScraperView(
      searchController: _searchController,
      onSearch: _onSearch,
    );
  }
}

class _ProductScraperView extends BaseScreen {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const _ProductScraperView({
    required this.searchController,
    required this.onSearch,
  });

  @override
  String get title => AppStrings.productScraperTitle;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header & Search Box Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.productScraperTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.secondaryHeaderColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.productScraperSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchInput(context),
              ],
            ),
          ),

          // Dynamic Body (Loader, Empty state, or Product Feed)
          Expanded(
            child: BlocBuilder<ProductScraperCubit, ProductScraperState>(
              builder: (context, state) {
                if (state is ProductScraperLoading) {
                  return _buildShimmerLoading(context);
                } else if (state is ProductScraperError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.message,
                        style: TextStyle(color: scheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (state is ProductScraperLoaded) {
                  if (state.products.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noProductsFound,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    );
                  }
                  return _buildContentList(context, state, bottomInset);
                }

                // Initial empty state
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 56,
                          color: scheme.primary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.searchPrompt,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: scheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(color: scheme.onSurface, fontSize: 14),
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                hintText: AppStrings.searchProductsHint,
                hintStyle: TextStyle(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_rounded, color: scheme.primary),
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(
    BuildContext context,
    ProductScraperLoaded state,
    double bottomInset,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        AppSizes.bottomNavHeight + bottomInset + 30,
      ),
      children: [
        // Action Header: Toggle MindAI Suggestions & Compare
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () =>
                  context.read<ProductScraperCubit>().toggleAiSuggestion(),
              icon: Icon(
                state.showAiSuggestion
                    ? Icons.auto_awesome
                    : Icons.auto_awesome_outlined,
                size: 18,
                color: scheme.primary,
              ),
              label: Text(
                state.showAiSuggestion
                    ? AppStrings.hideAiDeal
                    : AppStrings.showAiDeal,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
            ),
            SizedBox(width: 5),
            if (state.bestDeal != null)
              OutlinedButton.icon(
                onPressed: () => context.push(
                  RouteNames.comparePrices,
                  extra: searchController.text.trim(),
                ),
                icon: Icon(
                  Icons.compare_arrows_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
                label: Text(
                  AppStrings.comparePrices,
                  style: TextStyle(fontSize: 12, color: scheme.onSurface),
                ),
              ),
          ],
        ),

        // MindAI Suggestions & Comparison Section (conditionally displayed)
        if (state.showAiSuggestion) ...[
          const SizedBox(height: 10),
          _buildAiSuggestionCard(context, state),
          const SizedBox(height: 16),
        ],

        // Product Cards Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${AppStrings.allProducts} (${state.products.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.secondaryHeaderColor,
            ),
          ),
        ),

        // Product Cards Grid
        ...state.products.map((product) => _buildProductCard(context, product)),
      ],
    );
  }

  Widget _buildAiSuggestionCard(
    BuildContext context,
    ProductScraperLoaded state,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final deal = state.bestDeal;
    final comp = state.comparisonData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.mindAiSuggestion,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              if (deal != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    deal.store.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (deal != null)
            Text(
              deal.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${AppStrings.lowestPrice}: ',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              Text(
                deal?.formattedPrice ?? '₹0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          if (comp != null && comp.bestDealMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comp.bestDealMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ScrapedProduct product) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: scheme.surfaceContainerHighest,
              image: product.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(product.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imageUrl == null
                ? Icon(
                    Icons.image_not_supported_rounded,
                    color: scheme.onSurfaceVariant,
                  )
                : null,
          ),
          const SizedBox(width: 14),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.store,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    if (product.rating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _launchProductUrl(product.productUrl),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          Text(
                            AppStrings.viewProduct,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 12,
                            color: scheme.primary,
                          ),
                        ],
                      ),
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

  Widget _buildShimmerLoading(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final baseColor = isLight
        ? Colors.grey[300]!
        : scheme.surfaceContainerHighest;
    final highlightColor = isLight ? Colors.grey[100]! : scheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _launchProductUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
