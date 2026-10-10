import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import '../models/expense_model.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  String _selectedCategory = 'Food & Drinks';
  String _selectedPeriod = 'This Week';
  bool _isLoading = true;

  List<ExpenseModel> _allExpenses = [];
  double _totalExpenses = 0.0;
  final double _totalIncome = 6400.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await AppDatabase.instance.getAllExpenses();
      double total = 0.0;
      for (final item in expenses) {
        total += item.amount;
      }
      if (mounted) {
        setState(() {
          _allExpenses = expenses;
          _totalExpenses = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _trackQuickExpense() async {
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newExpense = ExpenseModel(
      title: _selectedCategory,
      amount: amount,
      category: _selectedCategory,
      time: DateTime.now(),
      updateTime: DateTime.now(),
    );

    await AppDatabase.instance.insertExpense(newExpense);
    _amountController.clear();
    await _loadExpenses();
  }

  Future<void> _clearAllExpenses() async {
    final confirm = await showDialog<bool>( 
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B38),
        title: const Text(
          'Clear All Expenses',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete all recorded expenses from SQLite?',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await AppDatabase.instance.database;
      await db.delete('expenses');
      await _loadExpenses();
    }
  }

  void _onOpenAddScreen() async {
    final result = await context.push(RouteNames.addExpense);
    if (result == true) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ExpenseTrackerView(
      amountController: _amountController,
      selectedCategory: _selectedCategory,
      selectedPeriod: _selectedPeriod,
      expenses: _allExpenses,
      totalExpenses: _totalExpenses,
      totalIncome: _totalIncome,
      isLoading: _isLoading,
      onCategoryChanged: (val) => setState(() => _selectedCategory = val),
      onPeriodChanged: (val) => setState(() => _selectedPeriod = val),
      onTrackQuickExpense: _trackQuickExpense,
      onOpenAddScreen: _onOpenAddScreen,
      onClearAll: _clearAllExpenses,
    );
  }
}

class _ExpenseTrackerView extends BaseScreen {
  final TextEditingController amountController;
  final String selectedCategory;
  final String selectedPeriod;
  final List<ExpenseModel> expenses;
  final double totalExpenses;
  final double totalIncome;
  final bool isLoading;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onTrackQuickExpense;
  final VoidCallback onOpenAddScreen;
  final VoidCallback onClearAll;

  const _ExpenseTrackerView({
    required this.amountController,
    required this.selectedCategory,
    required this.selectedPeriod,
    required this.expenses,
    required this.totalExpenses,
    required this.totalIncome,
    required this.isLoading,
    required this.onCategoryChanged,
    required this.onPeriodChanged,
    required this.onTrackQuickExpense,
    required this.onOpenAddScreen,
    required this.onClearAll,
  });

  @override
  String get title => AppStrings.expenseTracker;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Widget? get floatingActionButton => Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF8B5CF6).withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: RawMaterialButton(
      shape: const CircleBorder(),
      onPressed: onOpenAddScreen,
      child: const Icon(
        Icons.add_rounded,
        color: AppColors.whiteColor,
        size: 34,
      ),
    ),
  );

  @override
  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final totalBalance = totalIncome - totalExpenses;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPurple),
      );
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isTablet ? size.width * 0.15 : 20,
          16,
          isTablet ? size.width * 0.15 : 20,
          110,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 20),
            _buildBalanceCard(context, currencyFormat, totalBalance),
            const SizedBox(height: 20),
            _buildSpendingChartCard(context),
            const SizedBox(height: 24),
            _buildRecentExpensesSection(context, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.expenseTracker,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.manageYourSpending,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFFA78BFA),
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B38).withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.whiteColor.withOpacity(0.06)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFA78BFA),
              size: 20,
            ),
            onPressed: onClearAll,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    NumberFormat currencyFormat,
    double totalBalance,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF161426),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.totalBalance,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(totalBalance),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFFA78BFA),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Income Pill
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFF34D399),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.income,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        currencyFormat.format(totalIncome),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 36),
              // Expenses Pill
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFFF87171),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.expenses,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        currencyFormat.format(totalExpenses),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingChartCard(BuildContext context) {
    // Group expenses by Day of Week for Dynamic Graph Plotting
    final dailyTotals = List<double>.filled(7, 0.0);
    final now = DateTime.now();

    for (final exp in expenses) {
      final diff = now.difference(exp.time).inDays;
      if (diff >= 0 && diff < 7) {
        // Monday = 1, Sunday = 7
        final weekdayIndex = exp.time.weekday - 1;
        dailyTotals[weekdayIndex] += exp.amount;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161426),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.spendingAnalysis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFA78BFA),
                    size: 18,
                  ),
                  dropdownColor: const Color(0xFF1E1B38),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA78BFA),
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (val) {
                    if (val != null) onPeriodChanged(val);
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'This Week',
                      child: Text(AppStrings.thisWeek),
                    ),
                    DropdownMenuItem(
                      value: 'This Month',
                      child: Text(AppStrings.thisMonth),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _DynamicSpendingGraphPainter(dailyAmounts: dailyTotals),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mon',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              Text(
                'Tue',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              Text(
                'Wed',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              Text(
                'Thu',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              Text(
                'Fri',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              Text(
                'Sat',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              Text(
                'Sun',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesSection(
    BuildContext context,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentExpenses,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            TextButton(
              onPressed: onOpenAddScreen,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text(
                'Add More',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA78BFA),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (expenses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF161426),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.whiteColor.withOpacity(0.05)),
            ),
            child: const Center(
              child: Text(
                'No expenses logged yet.\nTap + or "Track It" to add your first expense.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length > 5 ? 5 : expenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final categoryMeta = _getCategoryMeta(expense.category);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF161426),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.whiteColor.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryMeta.bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        categoryMeta.icon,
                        color: categoryMeta.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.whiteColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM, hh:mm a').format(expense.time),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-${currencyFormat.format(expense.amount)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF87171),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  _CategoryMeta _getCategoryMeta(String category) {
    switch (category) {
      case 'Food & Drinks':
        return _CategoryMeta(
          icon: Icons.restaurant_rounded,
          bgColor: const Color(0xFF38231E),
          iconColor: const Color(0xFFF97316),
        );
      case 'Transportation':
        return _CategoryMeta(
          icon: Icons.directions_car_rounded,
          bgColor: const Color(0xFF1E2845),
          iconColor: const Color(0xFF38BDF8),
        );
      case 'Shopping':
        return _CategoryMeta(
          icon: Icons.shopping_bag_rounded,
          bgColor: const Color(0xFF331E3D),
          iconColor: const Color(0xFFC084FC),
        );
      case 'Entertainment':
        return _CategoryMeta(
          icon: Icons.movie_filter_rounded,
          bgColor: const Color(0xFF3B1E2E),
          iconColor: const Color(0xFFFB7185),
        );
      case 'Health':
        return _CategoryMeta(
          icon: Icons.medical_services_rounded,
          bgColor: const Color(0xFF16382F),
          iconColor: const Color(0xFF34D399),
        );
      default:
        return _CategoryMeta(
          icon: Icons.receipt_long_rounded,
          bgColor: const Color(0xFF2E2752),
          iconColor: const Color(0xFFA78BFA),
        );
    }
  }
}

class _CategoryMeta {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _CategoryMeta({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

class _DynamicSpendingGraphPainter extends CustomPainter {
  final List<double> dailyAmounts;

  _DynamicSpendingGraphPainter({required this.dailyAmounts});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const int lines = 4;
    for (int i = 0; i <= lines; i++) {
      final y = (size.height / lines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxVal = dailyAmounts.fold<double>(
      0.0,
      (m, val) => val > m ? val : m,
    );
    final effectiveMax = maxVal == 0 ? 100.0 : maxVal * 1.2;

    final points = <Offset>[];
    for (int i = 0; i < 7; i++) {
      final x = (size.width / 6) * i;
      final normalizedY = (dailyAmounts[i] / effectiveMax).clamp(0.0, 1.0);
      final y =
          size.height - (normalizedY * (size.height * 0.8) + size.height * 0.1);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B5CF6).withOpacity(0.35),
          const Color(0xFF8B5CF6).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFA78BFA)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // Highlight the peak day
    int maxIndex = 0;
    for (int i = 1; i < dailyAmounts.length; i++) {
      if (dailyAmounts[i] > dailyAmounts[maxIndex]) maxIndex = i;
    }

    final peakPoint = points[maxIndex];
    final dotOuterPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.4);
    final dotInnerPaint = Paint()..color = const Color(0xFFA78BFA);

    canvas.drawCircle(peakPoint, 8, dotOuterPaint);
    canvas.drawCircle(peakPoint, 4, dotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _DynamicSpendingGraphPainter oldDelegate) {
    return oldDelegate.dailyAmounts != dailyAmounts;
  }
}
