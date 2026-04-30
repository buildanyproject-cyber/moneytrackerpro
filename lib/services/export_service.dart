import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../database/hive_database.dart';

// ============================================================
// Export Service — PDF, CSV, and Excel report generation
// ============================================================

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final HiveDatabase _db = HiveDatabase();

  // ─────────── Export as CSV ───────────

  Future<String> exportAsCsv({DateTime? month}) async {
    if (kIsWeb) throw UnsupportedError('CSV Export not supported on Web');
    final transactions = month != null
        ? _db.getTransactionsByMonth(month)
        : _db.getAllTransactions();

    final rows = <List<String>>[
      ['Date', 'Type', 'Category', 'Wallet', 'Amount', 'Note'],
    ];

    for (final t in transactions) {
      final category = _db.getCategoryById(t.categoryId);
      final wallet = _db.getWalletById(t.walletId);
      rows.add([
        DateFormat('dd/MM/yyyy').format(t.date),
        t.type.toUpperCase(),
        category?.name ?? 'Unknown',
        wallet?.name ?? 'Unknown',
        t.amount.toStringAsFixed(2),
        t.note,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/moneytracker_report_$timestamp.csv');
    await file.writeAsString(csvString);

    return file.path;
  }

  // ─────────── Export as Excel ───────────

  Future<String> exportAsExcel({DateTime? month}) async {
    if (kIsWeb) throw UnsupportedError('Excel Export not supported on Web');
    final transactions = month != null
        ? _db.getTransactionsByMonth(month)
        : _db.getAllTransactions();

    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    // Header
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Wallet'),
      TextCellValue('Amount'),
      TextCellValue('Note'),
    ]);

    for (final t in transactions) {
      final category = _db.getCategoryById(t.categoryId);
      final wallet = _db.getWalletById(t.walletId);
      sheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy').format(t.date)),
        TextCellValue(t.type.toUpperCase()),
        TextCellValue(category?.name ?? 'Unknown'),
        TextCellValue(wallet?.name ?? 'Unknown'),
        DoubleCellValue(t.amount),
        TextCellValue(t.note),
      ]);
    }

    // Summary sheet
    final summary = excel['Summary'];
    final totalIncome = _db.getTotalIncome(month: month);
    final totalExpense = _db.getTotalExpense(month: month);

    summary.appendRow([TextCellValue('Metric'), TextCellValue('Value')]);
    summary.appendRow([
      TextCellValue('Total Income'),
      DoubleCellValue(totalIncome),
    ]);
    summary.appendRow([
      TextCellValue('Total Expense'),
      DoubleCellValue(totalExpense),
    ]);
    summary.appendRow([
      TextCellValue('Net Balance'),
      DoubleCellValue(totalIncome - totalExpense),
    ]);

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/moneytracker_report_$timestamp.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      await File(filePath).writeAsBytes(fileBytes);
    }

    return filePath;
  }

  // ─────────── Export as PDF ───────────

  Future<String> exportAsPdf({DateTime? month}) async {
    if (kIsWeb) throw UnsupportedError('PDF Export not supported on Web');
    final transactions = month != null
        ? _db.getTransactionsByMonth(month)
        : _db.getAllTransactions();

    final totalIncome = _db.getTotalIncome(month: month);
    final totalExpense = _db.getTotalExpense(month: month);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'MoneyTracker Pro',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              month != null
                  ? 'Report for ${DateFormat('MMMM yyyy').format(month)}'
                  : 'Complete Transaction Report',
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.Divider(),
            pw.SizedBox(height: 8),
            // Summary row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Total Income',
                  '₹${totalIncome.toStringAsFixed(2)}',
                  PdfColors.green700,
                ),
                _buildSummaryItem(
                  'Total Expense',
                  '₹${totalExpense.toStringAsFixed(2)}',
                  PdfColors.red700,
                ),
                _buildSummaryItem(
                  'Net Balance',
                  '₹${(totalIncome - totalExpense).toStringAsFixed(2)}',
                  PdfColors.blue700,
                ),
              ],
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: ['Date', 'Type', 'Category', 'Amount', 'Note'],
            data: transactions.map((t) {
              final category = _db.getCategoryById(t.categoryId);
              return [
                DateFormat('dd/MM/yyyy').format(t.date),
                t.type.toUpperCase(),
                category?.name ?? 'Unknown',
                '₹${t.amount.toStringAsFixed(2)}',
                t.note.length > 30 ? '${t.note.substring(0, 30)}...' : t.note,
              ];
            }).toList(),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/moneytracker_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
