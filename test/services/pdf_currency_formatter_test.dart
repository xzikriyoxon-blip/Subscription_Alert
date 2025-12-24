import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_alert/services/pdf_currency_formatter.dart';

void main() {
  group('PdfCurrencyFormatter', () {
    test('formats using currency code (no symbol)', () {
      expect(PdfCurrencyFormatter.format(7.99, 'USD'), 'USD 7.99');
      expect(PdfCurrencyFormatter.format(7.99, 'usd'), 'USD 7.99');
    });

    test('adds thousands separators in a stable locale', () {
      expect(PdfCurrencyFormatter.format(1234.5, 'EUR'), 'EUR 1,234.50');
    });

    test('handles negatives', () {
      expect(PdfCurrencyFormatter.format(-50, 'GBP'), 'GBP -50.00');
    });
  });
}
