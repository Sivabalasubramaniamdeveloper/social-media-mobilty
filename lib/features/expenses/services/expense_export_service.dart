import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';

class ExpenseExportService {
  static final ExpenseExportService instance = ExpenseExportService._();
  ExpenseExportService._();

  /// Export transactions to a PDF file and save locally
  Future<File?> exportToPdf({
    required BuildContext context,
    required List<TransactionModel> transactions,
    String? periodTitle,
    bool openAfterSave = true,
  }) async {
    try {
      final pdf = pw.Document();

      final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
      final dateFmt = DateFormat('MMM dd, yyyy');
      final exportDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      double totalIncome = 0;
      double totalExpense = 0;
      for (var tx in transactions) {
        if (tx.type == 'income') {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }
      final netBalance = totalIncome - totalExpense;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.only(bottom: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MindAI Expense Report',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF6C5CE7),
                        ),
                      ),
                      if (periodTitle != null)
                        pw.Text(
                          'Period: $periodTitle',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                  pw.Text(
                    'Exported: $exportDate',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 16),
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              ),
            );
          },
          build: (pw.Context context) {
            return [
              // Summary Cards Row
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF8F9FA),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPdfSummaryItem(
                      'Total Income',
                      currencyFmt.format(totalIncome),
                      PdfColor.fromInt(0xFF2ECC71),
                    ),
                    _buildPdfSummaryItem(
                      'Total Expenses',
                      currencyFmt.format(totalExpense),
                      PdfColor.fromInt(0xFFE74C3C),
                    ),
                    _buildPdfSummaryItem(
                      'Net Balance',
                      currencyFmt.format(netBalance),
                      netBalance >= 0
                          ? PdfColor.fromInt(0xFF2ECC71)
                          : PdfColor.fromInt(0xFFE74C3C),
                    ),
                    _buildPdfSummaryItem(
                      'Total Logs',
                      '${transactions.length}',
                      PdfColor.fromInt(0xFF6C5CE7),
                    ),
                  ],
                ),
              ),

              // Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEEEEEE),
                ),
                headerHeight: 28,
                cellHeight: 24,
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
                cellStyle: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey800,
                ),
                headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
                data: transactions.map((tx) {
                  final isIncome = tx.type == 'income';
                  return [
                    dateFmt.format(tx.time),
                    tx.title,
                    tx.categoryId.replaceAll('_', ' '),
                    isIncome ? 'Income' : 'Expense',
                    '${isIncome ? '+' : '-'}${currencyFmt.format(tx.amount)}',
                  ];
                }).toList(),
              ),
            ];
          },
        ),
      );

      final dir = await _getStorageDirectory();
      final fileName =
          'MindAI_Expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        _showSuccessSnackbar(
          context,
          'PDF saved locally: $fileName',
          file.path,
        );
      }

      if (openAfterSave) {
        await OpenFilex.open(file.path);
      }

      return file;
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return null;
    }
  }

  /// Export transactions to an Excel (.xlsx) file and save locally
  Future<File?> exportToExcel({
    required BuildContext context,
    required List<TransactionModel> transactions,
    String? periodTitle,
    bool openAfterSave = true,
  }) async {
    try {
      final excel = xl.Excel.createExcel();
      final sheetName = 'Expenses';
      excel.rename('Sheet1', sheetName);
      final sheet = excel[sheetName];

      final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

      // Title & Period Row
      final titleCell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = xl.TextCellValue('MindAI Expense Report');

      if (periodTitle != null) {
        final periodCell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1));
        periodCell.value = xl.TextCellValue('Period: $periodTitle');
      }

      // Header Row
      final headers = ['Date', 'Title', 'Category', 'Type', 'Amount (\$)', 'Notes'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3));
        cell.value = xl.TextCellValue(headers[i]);
      }

      double totalIncome = 0;
      double totalExpense = 0;

      // Data Rows
      int rowIndex = 4;
      for (var tx in transactions) {
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = xl.TextCellValue(dateFmt.format(tx.time));
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = xl.TextCellValue(tx.title);
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = xl.TextCellValue(tx.categoryId.replaceAll('_', ' '));
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = xl.TextCellValue(tx.type.toUpperCase());
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = xl.DoubleCellValue(tx.amount);
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = xl.TextCellValue(tx.note ?? '');

        if (tx.type == 'income') {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
        rowIndex++;
      }

      // Summary Rows
      rowIndex += 1;
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = xl.TextCellValue('TOTAL INCOME:');
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = xl.DoubleCellValue(totalIncome);

      rowIndex++;
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = xl.TextCellValue('TOTAL EXPENSES:');
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = xl.DoubleCellValue(totalExpense);

      rowIndex++;
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = xl.TextCellValue('NET BALANCE:');
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = xl.DoubleCellValue(totalIncome - totalExpense);

      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception('Failed to generate Excel bytes');

      final dir = await _getStorageDirectory();
      final fileName =
          'MindAI_Expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      if (context.mounted) {
        _showSuccessSnackbar(
          context,
          'Excel sheet saved locally: $fileName',
          file.path,
        );
      }

      if (openAfterSave) {
        await OpenFilex.open(file.path);
      }

      return file;
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export Excel: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return null;
    }
  }

  /// Show export options dialog / modal bottom sheet
  static void showExportBottomSheet({
    required BuildContext context,
    required List<TransactionModel> transactions,
    String? periodTitle,
  }) {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No transactions available to export.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B192E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Download Expense Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                Text(
                  'Choose format to download locally on your device (${transactions.length} records)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),

                // PDF Option
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await ExpenseExportService.instance.exportToPdf(
                      context: context,
                      transactions: transactions,
                      periodTitle: periodTitle,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231F3D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.redAccent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Download as PDF Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Formatted summary document ready to view or print',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white38,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Excel Option
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await ExpenseExportService.instance.exportToExcel(
                      context: context,
                      transactions: transactions,
                      periodTitle: periodTitle,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231F3D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.table_chart_rounded,
                            color: Colors.greenAccent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Download as Excel Sheet (.xlsx)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Spreadsheet with editable rows and summary totals',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white38,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  static pw.Widget _buildPdfSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static Future<Directory> _getStorageDirectory() async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    }
    dir ??= await getApplicationDocumentsDirectory();
    return dir;
  }

  static void _showSuccessSnackbar(
    BuildContext context,
    String message,
    String filePath,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2ECC71),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Share',
          textColor: Colors.white,
          onPressed: () {
            Share.shareXFiles([XFile(filePath)], text: 'MindAI Expense Export');
          },
        ),
      ),
    );
  }
}
