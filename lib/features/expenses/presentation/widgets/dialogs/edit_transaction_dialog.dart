import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/features/expenses/cubit/finance_cubit.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';

class EditTransactionDialog {
  static Future<bool?> show(
    BuildContext context, {
    required TransactionModel transaction,
  }) {
    final titleController = TextEditingController(text: transaction.title);
    final amountController =
        TextEditingController(text: transaction.amount.toStringAsFixed(0));
    final noteController =
        TextEditingController(text: transaction.note ?? '');
    String selectedType = transaction.type;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final isExpense = selectedType == 'expense';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isLight ? scheme.surface : const Color(0xFF1E1B38),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
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

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isExpense
                                      ? AppColors.expenseOrangeBg
                                      : AppColors.incomeGreenBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isExpense
                                      ? Icons.edit_note_rounded
                                      : Icons.account_balance_wallet_rounded,
                                  color: isExpense
                                      ? AppColors.expenseOrange
                                      : AppColors.incomeGreen,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppStrings.editTransaction,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(modalCtx, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Type Switcher (Expense / Income)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedType = 'expense'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isExpense ? AppColors.expenseRed : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppStrings.expense,
                                    style: TextStyle(
                                      color: isExpense ? Colors.white : scheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedType = 'income'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isExpense ? AppColors.incomeGreen : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppStrings.income,
                                    style: TextStyle(
                                      color: !isExpense ? Colors.white : scheme.onSurface,
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
                      const SizedBox(height: 18),

                      // Title Field
                      Text(
                        AppStrings.titleLabel,
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
                        controller: titleController,
                        style: TextStyle(color: scheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. Grocery, Salary, Coffee',
                          filled: true,
                          fillColor: isLight ? scheme.surfaceContainerHighest : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Amount Field
                      Text(
                        AppStrings.amountLabel,
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
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: scheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '₹0.00',
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: isLight ? scheme.surfaceContainerHighest : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Notes Field
                      Text(
                        AppStrings.notesLabel,
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
                        controller: noteController,
                        maxLines: 2,
                        style: TextStyle(color: scheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Optional notes...',
                          filled: true,
                          fillColor: isLight ? scheme.surfaceContainerHighest : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Save Button
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
                            elevation: 2,
                          ),
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final amountText = amountController.text.trim();
                            final amount = double.tryParse(amountText);

                            if (title.isEmpty || amount == null || amount <= 0) {
                              SnackBarHelper.showWarning(
                                context,
                                AppStrings.enterValidAmount,
                              );
                              return;
                            }

                            final subState = context.read<SubscriptionCubit>().state;
                            final isSubscribed = subState is SubscriptionLoaded &&
                                subState.plan.cloudSyncEnabled;

                            final updated = transaction.copyWith(
                              title: title,
                              amount: amount,
                              type: selectedType,
                              note: noteController.text.trim().isNotEmpty
                                  ? noteController.text.trim()
                                  : null,
                              updateTime: DateTime.now(),
                            );

                            final monthYear =
                                "${transaction.time.year}-${transaction.time.month.toString().padLeft(2, '0')}";

                            await context.read<FinanceCubit>().updateTransaction(
                              transaction: updated,
                              isSubscribed: isSubscribed,
                              monthYear: monthYear,
                            );

                            if (modalCtx.mounted) {
                              Navigator.pop(modalCtx, true);
                              SnackBarHelper.showSuccess(
                                context,
                                AppStrings.transactionUpdated,
                              );
                            }
                          },
                          child: Text(
                            AppStrings.updateTransaction,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
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
}
