import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_alert/models/currency.dart';

void main() {
  group('Currency Model', () {
    test('creates currency with all fields', () {
      const currency = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        flag: '🇺🇸',
      );

      expect(currency.code, 'USD');
      expect(currency.name, 'US Dollar');
      expect(currency.symbol, '\$');
      expect(currency.flag, '🇺🇸');
    });

    test('toString returns correct format', () {
      const currency = Currency(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        flag: '🇪🇺',
      );

      expect(currency.toString(), 'EUR - Euro');
    });
  });

  group('Currencies', () {
    group('all', () {
      test('contains major currencies', () {
        final codes = Currencies.all.map((c) => c.code).toList();

        expect(codes, contains('USD'));
        expect(codes, contains('EUR'));
        expect(codes, contains('GBP'));
        expect(codes, contains('JPY'));
        expect(codes, contains('UZS'));
      });

      test('has more than 50 currencies', () {
        expect(Currencies.all.length, greaterThan(50));
      });

      test('all currencies have required fields', () {
        for (final currency in Currencies.all) {
          expect(currency.code, isNotEmpty);
          expect(currency.name, isNotEmpty);
          expect(currency.symbol, isNotEmpty);
          expect(currency.flag, isNotEmpty);
        }
      });

      test('all currency codes are unique', () {
        final codes = Currencies.all.map((c) => c.code).toList();
        final uniqueCodes = codes.toSet();

        expect(codes.length, equals(uniqueCodes.length));
      });
    });

    group('sorted', () {
      test('returns currencies sorted by code', () {
        final sorted = Currencies.sorted;

        for (var i = 0; i < sorted.length - 1; i++) {
          expect(
            sorted[i].code.compareTo(sorted[i + 1].code),
            lessThanOrEqualTo(0),
          );
        }
      });

      test('contains same currencies as all', () {
        expect(Currencies.sorted.length, equals(Currencies.all.length));
      });
    });

    group('getByCode', () {
      test('returns currency for valid code', () {
        final usd = Currencies.getByCode('USD');

        expect(usd, isNotNull);
        expect(usd!.code, 'USD');
        expect(usd.name, 'US Dollar');
        expect(usd.symbol, '\$');
      });

      test('returns null for invalid code', () {
        final invalid = Currencies.getByCode('INVALID');

        expect(invalid, isNull);
      });

      test('is case sensitive', () {
        final lowercase = Currencies.getByCode('usd');

        expect(lowercase, isNull);
      });

      test('finds UZS (Uzbek Som)', () {
        final uzs = Currencies.getByCode('UZS');

        expect(uzs, isNotNull);
        expect(uzs!.name, 'Uzbek Som');
        expect(uzs.flag, '🇺🇿');
      });
    });

    group('search', () {
      test('finds currency by code', () {
        final results = Currencies.search('USD');

        expect(results.length, greaterThanOrEqualTo(1));
        expect(results.any((c) => c.code == 'USD'), isTrue);
      });

      test('finds currency by partial code', () {
        final results = Currencies.search('US');

        expect(results.length, greaterThanOrEqualTo(1));
        expect(results.any((c) => c.code == 'USD'), isTrue);
      });

      test('finds currency by name', () {
        final results = Currencies.search('Dollar');

        expect(results.length, greaterThan(1));
        expect(results.any((c) => c.code == 'USD'), isTrue);
        expect(results.any((c) => c.code == 'CAD'), isTrue);
        expect(results.any((c) => c.code == 'AUD'), isTrue);
      });

      test('is case insensitive', () {
        final upperResults = Currencies.search('EURO');
        final lowerResults = Currencies.search('euro');
        final mixedResults = Currencies.search('EuRo');

        expect(upperResults.length, equals(lowerResults.length));
        expect(lowerResults.length, equals(mixedResults.length));
      });

      test('returns empty list for no matches', () {
        final results = Currencies.search('ZZZZZ');

        expect(results, isEmpty);
      });

      test('finds Uzbek Som', () {
        final results = Currencies.search('Uzbek');

        expect(results.length, 1);
        expect(results.first.code, 'UZS');
      });
    });

    group('getSymbol', () {
      test('returns symbol for valid code', () {
        expect(Currencies.getSymbol('USD'), '\$');
        expect(Currencies.getSymbol('EUR'), '€');
        expect(Currencies.getSymbol('GBP'), '£');
        expect(Currencies.getSymbol('JPY'), '¥');
      });

      test('returns code for invalid currency', () {
        expect(Currencies.getSymbol('INVALID'), 'INVALID');
      });

      test('returns UZS symbol', () {
        expect(Currencies.getSymbol('UZS'), "so'm");
      });
    });

    group('format', () {
      test('formats amount with currency symbol', () {
        expect(Currencies.format(100.00, 'USD'), '\$100.00');
        expect(Currencies.format(50.50, 'EUR'), '€50.50');
      });

      test('formats with two decimal places', () {
        expect(Currencies.format(100, 'USD'), '\$100.00');
        expect(Currencies.format(99.999, 'USD'), '\$100.00');
      });

      test('formats unknown currency with code prefix', () {
        expect(Currencies.format(100.00, 'UNKNOWN'), 'UNKNOWN 100.00');
      });

      test('handles negative amounts', () {
        expect(Currencies.format(-50.00, 'USD'), '\$-50.00');
      });
    });
  });

  group('Regional Currency Groups', () {
    test('contains CIS currencies', () {
      final codes = Currencies.all.map((c) => c.code).toList();

      expect(codes, contains('UZS'));
      expect(codes, contains('RUB'));
      expect(codes, contains('KZT'));
      expect(codes, contains('UAH'));
      expect(codes, contains('GEL'));
      expect(codes, contains('AMD'));
      expect(codes, contains('AZN'));
    });

    test('contains Asian currencies', () {
      final codes = Currencies.all.map((c) => c.code).toList();

      expect(codes, contains('INR'));
      expect(codes, contains('KRW'));
      expect(codes, contains('SGD'));
      expect(codes, contains('THB'));
    });

    test('contains Middle East currencies', () {
      final codes = Currencies.all.map((c) => c.code).toList();

      expect(codes, contains('AED'));
      expect(codes, contains('SAR'));
      expect(codes, contains('TRY'));
      expect(codes, contains('ILS'));
    });
  });
}
