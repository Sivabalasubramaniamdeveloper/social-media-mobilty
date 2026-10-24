import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_sizes.dart';

import '../cubit/comparison_cubit.dart';
import '../cubit/comparison_state.dart';
import '../models/price_compare_model.dart';

class PriceComparisonScreen extends StatefulWidget {
  final String? initialQuery;

  const PriceComparisonScreen({super.key, this.initialQuery});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ComparisonCubit>().runComparison(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCompare() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      context.read<ComparisonCubit>().runComparison(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PriceComparisonView(controller: _controller, onCompare: _onCompare);
  }
}

class _PriceComparisonView extends BaseScreen {
  final TextEditingController controller;
  final VoidCallback onCompare;

  const _PriceComparisonView({
    required this.controller,
    required this.onCompare,
  });

  @override
  String get title => AppStrings.comparePricesTitle;

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
          // Header Bar with Back Action & Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: scheme.onSurface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.comparePricesTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        AppStrings.comparePricesSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: _buildSearchBox(context),
          ),

          // Body Results
          Expanded(
            child: BlocBuilder<ComparisonCubit, ComparisonState>(
              builder: (context, state) {
                if (state is ComparisonLoading) {
                  return _buildLoadingState(context);
                } else if (state is ComparisonError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: scheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.error),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: onCompare,
                            child: Text(AppStrings.tryAgain),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is ComparisonLoaded) {
                  return _buildComparisonDetails(
                    context,
                    state.data,
                    bottomInset,
                  );
                }

                // Initial empty state
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.compare_arrows_rounded,
                          size: 64,
                          color: scheme.primary.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.enterQueryPrompt,
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

  Widget _buildSearchBox(BuildContext context) {
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
              controller: controller,
              style: TextStyle(color: scheme.onSurface, fontSize: 14),
              onSubmitted: (_) => onCompare(),
              decoration: InputDecoration(
                hintText: AppStrings.compareSearchHint,
                hintStyle: TextStyle(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onCompare,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              AppStrings.compareButton,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonDetails(
    BuildContext context,
    DetailedComparisonModel data,
    double bottomInset,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        6,
        20,
        AppSizes.bottomNavHeight + bottomInset + 30,
      ),
      children: [
        // 1. Detailed MindAI Analysis Card
        _buildDetailedAiAnalysisCard(context, data),
        const SizedBox(height: 24),

        // 2. Stores Comparison Header
        Text(
          AppStrings.storesComparison,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.secondaryHeaderColor,
          ),
        ),
        const SizedBox(height: 12),

        // 3. Side-by-Side Store Cards or Empty State
        if (data.stores.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: 40,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  'No live prices found for this item across monitored stores. Please try another search term.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          ...data.stores.map((store) => _buildStoreCard(context, store)),
      ],
    );
  }

  Widget _buildDetailedAiAnalysisCard(
    BuildContext context,
    DetailedComparisonModel data,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final deal = data.bestDeal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.14),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge & Title
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
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.mindAiDealAnalysis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              if (deal != null && deal.store.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    deal.store.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Best Value Verdict Message
          Text(
            deal?.message ?? AppStrings.priceDataAcrossStores,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Savings & Metrics Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricColumn(
                  context,
                  AppStrings.priceDifference,
                  data.priceDifference ?? '₹0',
                  scheme.primary,
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
                _metricColumn(
                  context,
                  AppStrings.savingsOpportunity,
                  data.savingsPercentage ?? '0%',
                  const Color(0xFF34D399),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricColumn(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getStoreBrandColor(String storeName) {
    final s = storeName.toLowerCase();
    if (s.contains('amazon')) return const Color(0xFFFF9900);
    if (s.contains('flipkart')) return const Color(0xFF2874F0);
    if (s.contains('meesho')) return const Color(0xFFF43397);
    return const Color(0xFF8B5CF6);
  }

  IconData _getStoreIcon(String storeName) {
    final s = storeName.toLowerCase();
    if (s.contains('amazon')) return Icons.shopping_cart_checkout_rounded;
    if (s.contains('flipkart')) return Icons.bolt_rounded;
    if (s.contains('meesho')) return Icons.local_offer_rounded;
    return Icons.storefront_rounded;
  }

  Widget _buildStoreCard(BuildContext context, StoreProductDetail store) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final brandColor = _getStoreBrandColor(store.store);
    final storeIcon = _getStoreIcon(store.store);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: store.isBestDeal
              ? Colors.amber.withValues(alpha: 0.85)
              : (isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white12),
          width: store.isBestDeal ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (store.isBestDeal)
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (store.isBestDeal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'LOWEST VERIFIED PRICE • BEST VALUE DEAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Product Image with Animated Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 84,
                        height: 84,
                        color: isLight
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFF262344),
                        child: store.imageUrl != null &&
                                store.imageUrl!.trim().startsWith('http')
                            ? Image.network(
                                store.imageUrl!.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.storefront_rounded,
                                  color: scheme.onSurfaceVariant,
                                  size: 32,
                                ),
                              )
                            : Icon(
                                Icons.storefront_rounded,
                                color: scheme.onSurfaceVariant,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title, Brand & Star Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: brandColor.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: brandColor.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(storeIcon, size: 13, color: brandColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      store.store.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: brandColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (store.rating != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        store.rating!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            store.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Specs & Trust Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: store.found
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            store.found ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 13,
                            color: store.found ? const Color(0xFF10B981) : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.found ? AppStrings.inStock : AppStrings.outOfStock,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: store.found ? const Color(0xFF10B981) : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLight
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFF262344),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Pricing',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: isLight ? Colors.black12 : Colors.white10),
                const SizedBox(height: 12),

                // Price & View Deal CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.formattedPrice,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: store.found ? scheme.primary : scheme.error,
                          ),
                        ),
                        if (store.isBestDeal)
                          const Text(
                            'Cheapest Option',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _launchDealUrl(store.productUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: store.isBestDeal ? const Color(0xFFD97706) : scheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        elevation: store.isBestDeal ? 4 : 1,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 15),
                      label: Text(
                        AppStrings.viewDeal,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildLoadingState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight
        ? Colors.grey[300]!
        : scheme.surfaceContainerHighest;
    final highlightColor = isLight ? Colors.grey[100]! : scheme.surface;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.analyzingDeals,
                style: TextStyle(color: scheme.primary, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchDealUrl(String url) async {
    final clean = url.trim();
    if (clean.isEmpty) return;
    try {
      final uri = Uri.tryParse(clean);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
}
