import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_alert/models/timeline_entry.dart';
import 'package:subscription_alert/models/subscription.dart';
import 'package:subscription_alert/services/timeline_service.dart';

void main() {
  group('EntryType Enum', () {
    test('has all expected values', () {
      expect(EntryType.values.length, 3);
      expect(EntryType.values, contains(EntryType.past));
      expect(EntryType.values, contains(EntryType.today));
      expect(EntryType.values, contains(EntryType.future));
    });
  });

  group('TimelineEntry', () {
    late TimelineEntry entry;

    setUp(() {
      entry = TimelineEntry(
        subscriptionId: 'sub-123',
        name: 'Netflix',
        date: DateTime(2025, 12, 15),
        amount: 15.99,
        currency: 'USD',
        type: EntryType.future,
        brandId: 'netflix',
        cycle: 'monthly',
      );
    });

    test('creates entry with required fields', () {
      expect(entry.subscriptionId, 'sub-123');
      expect(entry.name, 'Netflix');
      expect(entry.amount, 15.99);
      expect(entry.currency, 'USD');
      expect(entry.type, EntryType.future);
      expect(entry.cycle, 'monthly');
    });

    test('optional fields can be null', () {
      final minimalEntry = TimelineEntry(
        subscriptionId: 'sub-456',
        name: 'Test',
        date: DateTime.now(),
        amount: 10.0,
        currency: 'USD',
        type: EntryType.past,
        cycle: 'monthly',
      );

      expect(minimalEntry.brandId, isNull);
      expect(minimalEntry.planName, isNull);
    });

    group('type checks', () {
      test('isToday returns true for today entries', () {
        final todayEntry = TimelineEntry(
          subscriptionId: '1',
          name: 'Test',
          date: DateTime.now(),
          amount: 10.0,
          currency: 'USD',
          type: EntryType.today,
          cycle: 'monthly',
        );

        expect(todayEntry.isToday, isTrue);
        expect(todayEntry.isPast, isFalse);
        expect(todayEntry.isFuture, isFalse);
      });

      test('isPast returns true for past entries', () {
        final pastEntry = TimelineEntry(
          subscriptionId: '2',
          name: 'Test',
          date: DateTime.now().subtract(const Duration(days: 30)),
          amount: 10.0,
          currency: 'USD',
          type: EntryType.past,
          cycle: 'monthly',
        );

        expect(pastEntry.isPast, isTrue);
        expect(pastEntry.isToday, isFalse);
        expect(pastEntry.isFuture, isFalse);
      });

      test('isFuture returns true for future entries', () {
        expect(entry.isFuture, isTrue);
        expect(entry.isToday, isFalse);
        expect(entry.isPast, isFalse);
      });
    });

    group('monthYear', () {
      test('returns formatted month and year', () {
        final janEntry = TimelineEntry(
          subscriptionId: '1',
          name: 'Test',
          date: DateTime(2025, 1, 15),
          amount: 10.0,
          currency: 'USD',
          type: EntryType.past,
          cycle: 'monthly',
        );

        expect(janEntry.monthYear, 'January 2025');
      });

      test('returns correct month names', () {
        final months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];

        for (var i = 0; i < 12; i++) {
          final entry = TimelineEntry(
            subscriptionId: '1',
            name: 'Test',
            date: DateTime(2025, i + 1, 15),
            amount: 10.0,
            currency: 'USD',
            type: EntryType.past,
            cycle: 'monthly',
          );

          expect(entry.monthYear, '${months[i]} 2025');
        }
      });
    });
  });

  group('TimelineMonth', () {
    late TimelineMonth month;
    late List<TimelineEntry> entries;

    setUp(() {
      entries = [
        TimelineEntry(
          subscriptionId: '1',
          name: 'Netflix',
          date: DateTime(2025, 12, 15),
          amount: 15.99,
          currency: 'USD',
          type: EntryType.future,
          cycle: 'monthly',
        ),
        TimelineEntry(
          subscriptionId: '2',
          name: 'Spotify',
          date: DateTime(2025, 12, 20),
          amount: 9.99,
          currency: 'USD',
          type: EntryType.future,
          cycle: 'monthly',
        ),
      ];

      month = TimelineMonth(
        monthYear: 'December 2025',
        month: 12,
        year: 2025,
        entries: entries,
        totalAmount: 25.98,
        isFuture: true,
      );
    });

    test('creates month with all fields', () {
      expect(month.monthYear, 'December 2025');
      expect(month.month, 12);
      expect(month.year, 2025);
      expect(month.entries.length, 2);
      expect(month.totalAmount, 25.98);
      expect(month.isFuture, isTrue);
    });

    test('isCurrentMonth returns true for current month', () {
      final now = DateTime.now();
      final currentMonth = TimelineMonth(
        monthYear: 'Current',
        month: now.month,
        year: now.year,
        entries: [],
        totalAmount: 0,
        isFuture: false,
      );

      expect(currentMonth.isCurrentMonth, isTrue);
    });

    test('isCurrentMonth returns false for other months', () {
      final now = DateTime.now();
      final otherMonth = TimelineMonth(
        monthYear: 'Other',
        month: now.month == 12 ? 1 : now.month + 1,
        year: now.year,
        entries: [],
        totalAmount: 0,
        isFuture: true,
      );

      expect(otherMonth.isCurrentMonth, isFalse);
    });
  });

  group('SubscriptionTimeline', () {
    test('creates timeline with all fields', () {
      final timeline = SubscriptionTimeline(
        pastMonths: [],
        futureMonths: [],
        currentMonth: null,
        totalPastSpend: 100.0,
        totalFutureSpend: 200.0,
      );

      expect(timeline.pastMonths, isEmpty);
      expect(timeline.futureMonths, isEmpty);
      expect(timeline.currentMonth, isNull);
      expect(timeline.totalPastSpend, 100.0);
      expect(timeline.totalFutureSpend, 200.0);
    });

    test('allMonths combines all months in order', () {
      final pastMonth = TimelineMonth(
        monthYear: 'November 2025',
        month: 11,
        year: 2025,
        entries: [],
        totalAmount: 50,
        isFuture: false,
      );

      final currentMonth = TimelineMonth(
        monthYear: 'December 2025',
        month: 12,
        year: 2025,
        entries: [],
        totalAmount: 75,
        isFuture: false,
      );

      final futureMonth = TimelineMonth(
        monthYear: 'January 2026',
        month: 1,
        year: 2026,
        entries: [],
        totalAmount: 100,
        isFuture: true,
      );

      final timeline = SubscriptionTimeline(
        pastMonths: [pastMonth],
        futureMonths: [futureMonth],
        currentMonth: currentMonth,
        totalPastSpend: 50,
        totalFutureSpend: 100,
      );

      expect(timeline.allMonths.length, 3);
      expect(timeline.allMonths[0].monthYear, 'November 2025');
      expect(timeline.allMonths[1].monthYear, 'December 2025');
      expect(timeline.allMonths[2].monthYear, 'January 2026');
    });

    test('allMonths works without current month', () {
      final timeline = SubscriptionTimeline(
        pastMonths: [
          TimelineMonth(
            monthYear: 'November 2025',
            month: 11,
            year: 2025,
            entries: [],
            totalAmount: 50,
            isFuture: false,
          ),
        ],
        futureMonths: [
          TimelineMonth(
            monthYear: 'January 2026',
            month: 1,
            year: 2026,
            entries: [],
            totalAmount: 100,
            isFuture: true,
          ),
        ],
        currentMonth: null,
        totalPastSpend: 50,
        totalFutureSpend: 100,
      );

      expect(timeline.allMonths.length, 2);
    });
  });

  group('TimelineService', () {
    late TimelineService service;
    late List<Subscription> subscriptions;

    setUp(() {
      service = TimelineService();
      
      final now = DateTime.now();
      subscriptions = [
        Subscription(
          id: 'netflix-123',
          name: 'Netflix',
          price: 15.99,
          currency: 'USD',
          cycle: 'monthly',
          nextPaymentDate: DateTime(now.year, now.month, 15),
          createdAt: now,
          updatedAt: now,
        ),
        Subscription(
          id: 'spotify-456',
          name: 'Spotify',
          price: 9.99,
          currency: 'USD',
          cycle: 'monthly',
          nextPaymentDate: DateTime(now.year, now.month, 20),
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    test('generates timeline for subscriptions', () {
      final timeline = service.generateTimeline(
        subscriptions: subscriptions,
        isPremium: true,
      );

      expect(timeline, isNotNull);
      expect(timeline.allMonths, isNotEmpty);
    });

    test('generates timeline with limited months for free users', () {
      final freeTimeline = service.generateTimeline(
        subscriptions: subscriptions,
        isPremium: false,
      );

      final premiumTimeline = service.generateTimeline(
        subscriptions: subscriptions,
        isPremium: true,
      );

      // Free users get fewer months
      expect(freeTimeline.allMonths.length, 
             lessThanOrEqualTo(premiumTimeline.allMonths.length));
    });

    test('excludes cancelled subscriptions', () {
      final cancelledSub = Subscription(
        id: 'cancelled-789',
        name: 'Cancelled',
        price: 20.0,
        currency: 'USD',
        cycle: 'monthly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCancelled: true,
        cancelledAt: DateTime.now(),
      );

      final timeline = service.generateTimeline(
        subscriptions: [...subscriptions, cancelledSub],
        isPremium: true,
      );

      // Check that cancelled subscription is not in entries
      for (final month in timeline.allMonths) {
        for (final entry in month.entries) {
          expect(entry.subscriptionId, isNot('cancelled-789'));
        }
      }
    });

    test('handles empty subscription list', () {
      final timeline = service.generateTimeline(
        subscriptions: [],
        isPremium: true,
      );

      expect(timeline.allMonths, isEmpty);
      expect(timeline.totalPastSpend, 0);
      expect(timeline.totalFutureSpend, 0);
    });
  });
}
