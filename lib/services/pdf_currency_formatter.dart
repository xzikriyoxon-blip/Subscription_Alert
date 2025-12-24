import 'package:intl/intl.dart';

/// PDF-safe currency formatting.
///
/// Rationale:
/// - PDF text rendering is font-dependent.
/// - Many currency symbols (and some scripts) can render as missing-glyph boxes
///   if the PDF font doesn't support them.
///
/// Therefore, we always format money values using the currency *code* (ASCII),
/// e.g. `USD 7.99`.
class PdfCurrencyFormatter {
  /// A fixed locale so formatting is stable across devices/tests.
  static const String pdfLocale = 'en_US';

  static final NumberFormat _amount = NumberFormat('#,##0.00', pdfLocale);

  /// Formats an amount for PDF display.
  ///
  /// Example: `format(7.99, 'usd') -> 'USD 7.99'`.
  static String format(double amount, String currencyCode) {
    final code = currencyCode.trim().toUpperCase();
    return '$code ${_amount.format(amount)}';
  }
}
