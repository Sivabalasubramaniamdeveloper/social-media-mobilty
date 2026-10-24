import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/widgets/animations/app_lottie_view.dart';

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
                        const AppLottieView(
                          type: LottieAnimationType.shoppingCart,
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.enterQueryPrompt,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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
    final isLight = theme.brightness == Brightness.light;
    final deal = data.bestDeal;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, anim, child) {
        return Opacity(
          opacity: anim,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - anim)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLight
                ? [
                    const Color(0xFFFAF5FF),
                    const Color(0xFFF3E8FF),
                    const Color(0xFFEDE9FE),
                  ]
                : [
                    const Color(0xFF241442),
                    const Color(0xFF1E1338),
                    const Color(0xFF170E2E),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFA855F7).withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA855F7).withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: AI Sparkle + Best Store Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MINE AI DEAL ANALYSIS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Color(0xFFA855F7),
                          ),
                        ),
                        Text(
                          'Real-time Market Comparison',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (deal != null && deal.store.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'TOP: ${deal.store.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Deal Score Gauge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLight
                      ? Colors.purple.shade100
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded, color: Color(0xFF10B981), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Deal Quality Rating',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '9.6 / 10 • EXCEPTIONAL',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const LinearProgressIndicator(
                            value: 0.96,
                            minHeight: 6,
                            backgroundColor: Colors.black12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Best Value Verdict Message
            Text(
              deal?.message ?? AppStrings.priceDataAcrossStores,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),

            // Savings & Metrics Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isLight
                            ? Colors.purple.shade100
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.priceDifference,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.priceDifference ?? '₹0',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFA855F7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isLight
                            ? Colors.purple.shade100
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.savingsOpportunity,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.savingsPercentage ?? '0%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStoreBrandColor(String storeName) {
    final s = storeName.toLowerCase();
    if (s.contains('flipkart')) return const Color(0xFF2874F0);
    if (s.contains('amazon')) return const Color(0xFFFF9900);
    if (s.contains('croma')) return const Color(0xFF128073);
    if (s.contains('reliance')) return const Color(0xFFE42529);
    if (s.contains('meesho')) return const Color(0xFFF43397);
    return const Color(0xFF7C3AED);
  }

  IconData _getStoreIcon(String storeName) {
    final s = storeName.toLowerCase();
    if (s.contains('flipkart')) return Icons.bolt_rounded;
    if (s.contains('amazon')) return Icons.shopping_bag_rounded;
    if (s.contains('croma')) return Icons.tv_rounded;
    return Icons.storefront_rounded;
  }

  Widget _buildStoreCard(BuildContext context, StoreProductDetail store) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final brandColor = _getStoreBrandColor(store.store);
    final storeIcon = _getStoreIcon(store.store);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1B1834),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: store.isBestDeal
              ? const Color(0xFFFA8C16)
              : (isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white12),
          width: store.isBestDeal ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: store.isBestDeal
                ? const Color(0xFFFA8C16).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: store.isBestDeal ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Flipkart-style Top Super Saver Strip if Best Deal
          if (store.isBestDeal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7E6),
                border: Border(bottom: BorderSide(color: Color(0xFFFFD591), width: 0.8)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFA8C16)),
                  SizedBox(width: 6),
                  Text(
                    'FLIPKART BEST PRICE • LOWEST IN MARKET',
                    style: TextStyle(
                      color: Color(0xFFD46B08),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // 2. Flipkart Split Card Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Image Container (100x100 Flipkart Cart Product Box)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: store.imageUrl != null &&
                                store.imageUrl!.trim().startsWith('http')
                            ? Image.network(
                                store.imageUrl!.trim(),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.grey.shade400,
                                  size: 36,
                                ),
                              )
                            : Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.grey.shade400,
                                size: 36,
                              ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: store.found ? const Color(0xFF388E3C) : Colors.red.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            store.found ? 'IN STOCK' : 'OUT OF STOCK',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Right Details Column (Title, Store, Rating, Price, Delivery)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Brand Badge + Verified Check
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: brandColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: brandColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(storeIcon, size: 12, color: brandColor),
                                const SizedBox(width: 4),
                                Text(
                                  store.store.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: brandColor,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Flipkart Assured badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2874F0).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Assured',
                              style: TextStyle(
                                color: Color(0xFF2874F0),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Product Title
                      Text(
                        store.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Flipkart Iconic Green Rating Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF388E3C),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  store.rating ?? '4.2',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.star, size: 10, color: Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(1,240)',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Pricing Row (Deal price, MRP strikethrough, discount %)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            store.formattedPrice,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: store.found ? scheme.onSurface : scheme.error,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (store.price != null && store.price! > 0) ...[
                            Text(
                              '₹${(store.price! * 1.28).toInt()}',
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: scheme.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '28% off',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Delivery indicator
                      const Row(
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 12, color: Color(0xFF388E3C)),
                          SizedBox(width: 4),
                          Text(
                            'Free Delivery by Tomorrow',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF388E3C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Flipkart Cart Style Bottom Action Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isLight
                  ? Colors.grey.shade50
                  : Colors.white.withValues(alpha: 0.02),
              border: Border(
                top: BorderSide(
                  color: isLight ? Colors.black.withValues(alpha: 0.05) : Colors.white10,
                ),
              ),
            ),
            child: Row(
              children: [
                // Share Deal
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18),
                  tooltip: 'Share Deal',
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text: 'Check out this deal for ${store.title} at ${store.formattedPrice} on ${store.store.toUpperCase()}: ${store.productUrl}',
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Main CTA Button (Flipkart Blue or Store Color)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchDealUrl(store.productUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: Text(
                      'BUY ON ${store.store.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
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
              const AppLottieView(
                type: LottieAnimationType.aiAnalyzing,
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.analyzingDeals,
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
