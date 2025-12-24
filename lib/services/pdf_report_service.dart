import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:printing/printing.dart';
import '../models/currency.dart';
import '../models/subscription.dart';
import '../models/subscription_brand.dart';

/// Report type for PDF generation
enum ReportType {
  monthly,
  yearly,
}

/// Report data model
class ReportData {
  final DateTime startDate;
  final DateTime endDate;
  final List<Subscription> subscriptions;
  final String currencyCode;
  final ReportType reportType;

  ReportData({
    required this.startDate,
    required this.endDate,
    required this.subscriptions,
    required this.currencyCode,
    required this.reportType,
  });

  SubscriptionBrand? _resolveBrand(Subscription sub) {
    final brandId = sub.brandId;
    if (brandId != null && brandId.trim().isNotEmpty) {
      final byId = SubscriptionBrands.getById(brandId);
      if (byId != null) return byId;
    }

    // Fallback: try fuzzy match by name (e.g. user typed "Netflix" but didn't pick a brand).
    final byName = SubscriptionBrands.getByName(sub.name);
    return byName;
  }

  /// Best-effort category label for a subscription.
  String categoryFor(Subscription sub) {
    return _resolveBrand(sub)?.category ?? BrandCategory.other;
  }

  /// Best-effort brand display name for a subscription.
  String brandNameFor(Subscription sub) {
    final brand = _resolveBrand(sub);
    if (brand != null) return brand.name;

    // If no brand match, show the stored brandId (if any) or a friendly fallback.
    final brandId = sub.brandId;
    if (brandId != null && brandId.trim().isNotEmpty) return brandId;
    return 'Other';
  }

  /// Currency codes present in the report subscriptions.
  Set<String> get currenciesInReport {
    return subscriptions
        .map((s) => s.currency.trim())
        .where((c) => c.isNotEmpty)
        .toSet();
  }

  /// If the report contains exactly one currency, returns it. Otherwise null.
  String? get singleCurrency {
    final set = currenciesInReport;
    if (set.length == 1) return set.first;
    return null;
  }

  /// Total spent per currency.
  Map<String, double> get totalSpentByCurrency {
    final totals = <String, double>{};
    for (final sub in subscriptions) {
      final code = sub.currency.trim().isEmpty ? currencyCode : sub.currency;
      totals[code] = (totals[code] ?? 0) + _calculateSubscriptionCost(sub);
    }
    return totals;
  }

  /// Calculate total spent in the period.
  ///
  /// NOTE: Only meaningful when the report contains a single currency.
  double? get totalSpentSingleCurrency {
    final code = singleCurrency;
    if (code == null) return null;
    return totalSpentByCurrency[code] ?? 0.0;
  }

  /// Calculate cost for a single subscription in the period
  double _calculateSubscriptionCost(Subscription sub) {
    // Get number of payments in the period
    final payments = _getPaymentsInPeriod(sub);
    return payments * sub.price;
  }

  /// Count how many payments occurred in the period
  int _getPaymentsInPeriod(Subscription sub) {
    int payments = 0;
    DateTime checkDate = sub.createdAt;

    while (checkDate.isBefore(endDate) || checkDate.isAtSameMomentAs(endDate)) {
      if ((checkDate.isAfter(startDate) ||
              checkDate.isAtSameMomentAs(startDate)) &&
          (checkDate.isBefore(endDate) ||
              checkDate.isAtSameMomentAs(endDate))) {
        payments++;
      }

      // Move to next billing date based on cycle
      switch (sub.cycle.toLowerCase()) {
        case 'weekly':
          checkDate = checkDate.add(const Duration(days: 7));
          break;
        case 'monthly':
          checkDate =
              DateTime(checkDate.year, checkDate.month + 1, checkDate.day);
          break;
        case 'quarterly':
          checkDate =
              DateTime(checkDate.year, checkDate.month + 3, checkDate.day);
          break;
        case 'yearly':
        case 'annual':
          checkDate =
              DateTime(checkDate.year + 1, checkDate.month, checkDate.day);
          break;
        default:
          checkDate =
              DateTime(checkDate.year, checkDate.month + 1, checkDate.day);
      }
    }

    return payments;
  }

  /// Get subscriptions grouped by category.
  Map<String, List<Subscription>> get subscriptionsByCategory {
    final Map<String, List<Subscription>> grouped = {};
    for (final sub in subscriptions) {
      final category = categoryFor(sub);
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(sub);
    }
    return grouped;
  }

  /// Get spending by category
  Map<String, double> get spendingByCategory {
    final Map<String, double> spending = {};
    for (final sub in subscriptions) {
      final category = categoryFor(sub);
      spending.putIfAbsent(category, () => 0);
      spending[category] = spending[category]! + _calculateSubscriptionCost(sub);
    }
    return spending;
  }
}

/// Service for generating PDF subscription reports
class PDFReportService {
  static final PDFReportService _instance = PDFReportService._internal();
  factory PDFReportService() => _instance;
  PDFReportService._internal();

  /// Generate a monthly report PDF
  Future<File?> generateMonthlyReport({
    required List<Subscription> subscriptions,
    required int month,
    required int year,
    required String currencyCode,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Last day of month

    final reportData = ReportData(
      startDate: startDate,
      endDate: endDate,
      subscriptions: subscriptions.where((s) => !s.isCancelled).toList(),
      currencyCode: currencyCode,
      reportType: ReportType.monthly,
    );

    return _generatePDF(reportData,
        'Monthly Report - ${DateFormat('MMMM yyyy').format(startDate)}');
  }

  /// Generate a yearly report PDF
  Future<File?> generateYearlyReport({
    required List<Subscription> subscriptions,
    required int year,
    required String currencyCode,
  }) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    final reportData = ReportData(
      startDate: startDate,
      endDate: endDate,
      subscriptions: subscriptions.where((s) => !s.isCancelled).toList(),
      currencyCode: currencyCode,
      reportType: ReportType.yearly,
    );

    return _generatePDF(reportData, 'Yearly Report - $year');
  }

  /// Generate a custom date range report PDF
  Future<File?> generateCustomReport({
    required List<Subscription> subscriptions,
    required DateTime startDate,
    required DateTime endDate,
    required String currencyCode,
  }) async {
    final reportData = ReportData(
      startDate: startDate,
      endDate: endDate,
      subscriptions: subscriptions.where((s) => !s.isCancelled).toList(),
      currencyCode: currencyCode,
      reportType: ReportType.monthly, // Custom uses monthly-style format
    );

    final dateFormat = DateFormat('MMM d, yyyy');
    return _generatePDF(
      reportData,
      'Report: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
    );
  }

  /// Internal method to generate the PDF document
  Future<File?> _generatePDF(ReportData data, String title) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('MMM d, yyyy');

      // Use a Unicode-capable font so currency symbols like "€" render correctly.
      // The default built-in PDF fonts may substitute/misrender such characters.
      pw.ThemeData? theme;
      try {
        final base = await PdfGoogleFonts.notoSansRegular();
        final bold = await PdfGoogleFonts.notoSansBold();
        final italic = await PdfGoogleFonts.notoSansItalic();
        final boldItalic = await PdfGoogleFonts.notoSansBoldItalic();
        theme = pw.ThemeData.withFont(
          base: base,
          bold: bold,
          italic: italic,
          boldItalic: boldItalic,
        );
      } catch (_) {
        // If font download fails (offline, etc.), fall back to default fonts.
        theme = null;
      }

      // IMPORTANT:
      // We currently do not convert between currencies in the PDF.
      // Therefore, we must not display amounts using a different currency symbol
      // than the underlying subscription prices.
      final effectiveCurrencyCode = data.singleCurrency ?? data.currencyCode;

      final Map<String, NumberFormat> currencyFormatCache = {};
      NumberFormat fmtFor(String currencyCode) {
        return currencyFormatCache.putIfAbsent(currencyCode, () {
          final symbol = Currencies.getSymbol(currencyCode);
          return NumberFormat.currency(
            name: currencyCode,
            symbol: symbol,
            decimalDigits: 2,
          );
        });
      }

      String formatMoney(double amount, String currencyCode) {
        return fmtFor(currencyCode).format(amount);
      }

      // Colors
      const primaryColor = PdfColor.fromInt(0xFF2196F3);
      const secondaryColor = PdfColor.fromInt(0xFF4CAF50);
      const headerBgColor = PdfColor.fromInt(0xFFF5F5F5);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: theme,
          build: (context) => [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Subscription Alert',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Period: ${dateFormat.format(data.startDate)} - ${dateFormat.format(data.endDate)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Generated: ${dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Total Subscriptions',
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey600),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${data.subscriptions.length}',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 28,
                            color: primaryColor),
                      ),
                    ],
                  ),
                  pw.Container(
                    width: 1,
                    height: 50,
                    color: PdfColors.grey300,
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Spending',
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey600),
                      ),
                      pw.SizedBox(height: 5),
                      if (data.totalSpentSingleCurrency != null)
                        pw.Text(
                          formatMoney(
                            data.totalSpentSingleCurrency!,
                            effectiveCurrencyCode,
                          ),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 28,
                              color: secondaryColor),
                        )
                      else ...[
                        pw.Text(
                          'Multiple currencies',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 18,
                              color: secondaryColor),
                        ),
                        pw.SizedBox(height: 6),
                        ...data.totalSpentByCurrency.entries.map((e) {
                          return pw.Text(
                            '${e.key}: ${formatMoney(e.value, e.key)}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Spending by Category Section
            pw.Text(
              'Spending by Category',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
            ),
            pw.SizedBox(height: 15),
            ...data.spendingByCategory.entries.map((entry) {
              final totalForPercent = (data.totalSpentSingleCurrency ?? 0.0);
              final percentage = totalForPercent > 0
                  ? (entry.value / totalForPercent * 100)
                  : 0.0;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          entry.key,
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                            '${formatMoney(entry.value, effectiveCurrencyCode)} (${percentage.toStringAsFixed(1)}%)',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: percentage.toInt().clamp(0, 100),
                            child: pw.Container(
                              decoration: pw.BoxDecoration(
                                color: primaryColor,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          if (percentage < 100)
                            pw.Expanded(
                              flex: (100 - percentage).toInt().clamp(0, 100),
                              child: pw.Container(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 30),

            // Subscriptions Table
            pw.Text(
              'Subscription Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
            ),
            pw.SizedBox(height: 15),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(1.4),
                2: const pw.FlexColumnWidth(1.4),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(1.4),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: headerBgColor),
                  children: [
                    _buildTableCell('Name', isHeader: true),
                    _buildTableCell('Brand', isHeader: true),
                    _buildTableCell('Category', isHeader: true),
                    _buildTableCell('Cycle', isHeader: true),
                    _buildTableCell('Price', isHeader: true),
                  ],
                ),
                // Data rows
                ...data.subscriptions.map((sub) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(sub.name),
                      _buildTableCell(data.brandNameFor(sub)),
                      _buildTableCell(data.categoryFor(sub)),
                      _buildTableCell(_formatBillingCycle(sub.cycle)),
                      _buildTableCell(formatMoney(sub.price, sub.currency.trim().isEmpty ? effectiveCurrencyCode : sub.currency)),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: headerBgColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Tips to Save Money',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '• Review unused subscriptions regularly\n'
                    '• Consider annual plans for frequently used services\n'
                    '• Look for family or group plan discounts\n'
                    '• Set trial reminders to avoid unwanted charges',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      // Save PDF
      final output = await getTemporaryDirectory();
      final fileName =
          'subscription_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  /// Build a table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 11 : 10,
        ),
      ),
    );
  }

  /// Format billing cycle for display
  String _formatBillingCycle(String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      default:
        return cycle;
    }
  }

  /// Open the generated PDF file
  Future<void> openPDF(File file) async {
    await open_file.OpenFile.open(file.path);
  }

  /// Share the generated PDF file (uses platform share sheet)
  Future<void> sharePDF(File file) async {
    // This would be implemented with share_plus
    // For now, just open the file
    await openPDF(file);
  }
}
