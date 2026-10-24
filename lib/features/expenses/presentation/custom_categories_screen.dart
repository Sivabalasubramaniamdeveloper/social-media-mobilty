import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/expenses/cubit/finance_cubit.dart';
import 'package:mineai/features/expenses/models/category_model.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';

class CustomCategoriesScreen extends StatefulWidget {
  const CustomCategoriesScreen({super.key});

  @override
  State<CustomCategoriesScreen> createState() => _CustomCategoriesScreenState();
}

class _CustomCategoriesScreenState extends State<CustomCategoriesScreen> {
  List<CategoryModel> _customCategories = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'expense', 'income'

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final userId = await UserHelper.getCurrentUserId();
      final exp = await ExpenseDatabaseService.instance.getCategories(userId, 'expense');
      final inc = await ExpenseDatabaseService.instance.getCategories(userId, 'income');
      // Custom categories have non-null userId
      final custom = [...exp, ...inc].where((c) => c.userId != null && c.userId!.isNotEmpty).toList();
      if (mounted) {
        setState(() {
          _customCategories = custom;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddCategoryModal(bool isSubscribed) {
    if (!isSubscribed) {
      _showUpgradeModal();
      return;
    }

    final nameController = TextEditingController();
    String type = 'expense';

    final availableIcons = [
      Icons.shopping_bag_rounded,
      Icons.fastfood_rounded,
      Icons.directions_car_rounded,
      Icons.fitness_center_rounded,
      Icons.flight_takeoff_rounded,
      Icons.movie_filter_rounded,
      Icons.pets_rounded,
      Icons.laptop_chromebook_rounded,
      Icons.card_giftcard_rounded,
      Icons.school_rounded,
      Icons.medical_services_rounded,
      Icons.home_repair_service_rounded,
    ];
    int selectedIconIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isLight ? scheme.surface : const Color(0xFF1E1B38),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.addCategory,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Type Selector
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => type = 'expense'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: type == 'expense' ? AppColors.expenseRed : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppStrings.expense,
                                    style: TextStyle(
                                      color: type == 'expense' ? Colors.white : scheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => type = 'income'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: type == 'income' ? AppColors.incomeGreen : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppStrings.income,
                                    style: TextStyle(
                                      color: type == 'income' ? Colors.white : scheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      Text(
                        AppStrings.categoryName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        style: TextStyle(color: scheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. Subscriptions, Freelancing, Gym',
                          filled: true,
                          fillColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Icon Selector
                      Text(
                        AppStrings.selectIcon,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(availableIcons.length, (idx) {
                          final isSel = selectedIconIndex == idx;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedIconIndex = idx),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? scheme.primary
                                    : (isLight
                                        ? scheme.surfaceContainerHighest
                                        : const Color(0xFF262344)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? scheme.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                availableIcons[idx],
                                color: isSel ? Colors.white : scheme.onSurface,
                                size: 20,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              SnackBarHelper.showWarning(context, AppStrings.enterCategoryName);
                              return;
                            }
                            final financeCubit = context.read<FinanceCubit>();
                            final userId = await UserHelper.getCurrentUserId();
                            final catId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                            final newCat = CategoryModel(
                              id: catId,
                              name: name,
                              type: type,
                              userId: userId,
                            );

                            final now = DateTime.now();
                            final monthYear = "${now.year}-${now.month.toString().padLeft(2, '0')}";

                            await financeCubit.addCustomCategory(
                              category: newCat,
                              isSubscribed: true,
                              monthYear: monthYear,
                            );

                            if (!mounted) return;
                            if (modalCtx.mounted) {
                              Navigator.pop(modalCtx);
                            }
                            _loadCategories();
                            SnackBarHelper.showSuccess(context, AppStrings.customCategoryCreated);
                          },
                          child: Text(
                            AppStrings.addCategory,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUpgradeModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return AlertDialog(
          backgroundColor: isLight ? scheme.surface : const Color(0xFF1E1B38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                AppStrings.lockedFeaturePro,
                style: TextStyle(color: scheme.onSurface, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            AppStrings.customCategoryProDesc,
            style: TextStyle(
              color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.push(RouteNames.subscription);
              },
              child: Text(AppStrings.viewPlans),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, subState) {
        final isProOrPremium = subState is SubscriptionLoaded &&
            (subState.plan.tier == PlanTier.pro || subState.plan.tier == PlanTier.premium);

        final filtered = _selectedFilter == 'all'
            ? _customCategories
            : _customCategories.where((c) => c.type == _selectedFilter).toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddCategoryModal(isProOrPremium),
            backgroundColor: scheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(AppStrings.addCategory),
          ),
          body: GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AppScreenHeader(
                      title: AppStrings.customCategories,
                      centerTitle: true,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.dashboard);
                        }
                      },
                    ),
                  ),

                  // Pro / Premium Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isProOrPremium
                            ? const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              )
                            : null,
                        color: isProOrPremium
                            ? null
                            : (isLight ? Colors.amber.shade50 : const Color(0xFF2E2211)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isProOrPremium
                              ? Colors.transparent
                              : Colors.amber.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isProOrPremium
                                ? Icons.verified_rounded
                                : Icons.lock_outline_rounded,
                            color: isProOrPremium ? Colors.white : Colors.amber,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isProOrPremium
                                      ? AppStrings.customCategoriesUnlocked
                                      : AppStrings.lockedFeaturePro,
                                  style: TextStyle(
                                    color: isProOrPremium ? Colors.white : Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isProOrPremium
                                      ? AppStrings.customCategoriesDesc
                                      : AppStrings.customCategoryProDesc,
                                  style: TextStyle(
                                    color: isProOrPremium
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : (isLight ? Colors.brown.shade800 : Colors.amber.shade100),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isProOrPremium)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => context.push(RouteNames.subscription),
                              child: Text(AppStrings.upgrade, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Filter Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        _filterChip('all', AppStrings.allCategories, scheme, isLight),
                        const SizedBox(width: 8),
                        _filterChip('expense', AppStrings.expense, scheme, isLight),
                        const SizedBox(width: 8),
                        _filterChip('income', AppStrings.income, scheme, isLight),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: scheme.primary))
                        : filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        size: 48,
                                        color: scheme.onSurface.withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        AppStrings.noCustomCategoriesYet,
                                        style: TextStyle(
                                          color: scheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isProOrPremium
                                            ? AppStrings.noCustomCategoriesDesc
                                            : AppStrings.customCategoryProDesc,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isLight
                                              ? AppColors.lightSecondaryOnSurface
                                              : AppColors.secondaryText,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                                itemCount: filtered.length,
                                itemBuilder: (ctx, idx) {
                                  final cat = filtered[idx];
                                  final isExp = cat.type == 'expense';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? scheme.surfaceContainerHighest
                                          : const Color(0xFF1E1B38),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isLight ? Colors.black12 : Colors.white10,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isExp
                                                ? AppColors.expenseOrangeBg
                                                : AppColors.incomeGreenBg,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isExp
                                                ? Icons.shopping_bag_outlined
                                                : Icons.account_balance_rounded,
                                            color: isExp
                                                ? AppColors.expenseOrange
                                                : AppColors.incomeGreen,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.name,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: scheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                isExp ? AppStrings.customExpenseCategory : AppStrings.customIncomeSource,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isLight
                                                      ? AppColors.lightSecondaryOnSurface
                                                      : AppColors.secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (isExp ? Colors.orange : Colors.green)
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            cat.type.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isExp ? Colors.orange : Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
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
      },
    );
  }

  Widget _filterChip(
    String id,
    String label,
    ColorScheme scheme,
    bool isLight,
  ) {
    final isSel = _selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSel
              ? scheme.primary
              : (isLight ? scheme.surfaceContainerHighest : const Color(0xFF1E1B38)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSel ? scheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            color: isSel ? Colors.white : scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
