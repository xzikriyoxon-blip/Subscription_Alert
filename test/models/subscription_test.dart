import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_alert/models/subscription.dart';

void main() {
  group('Subscription Model', () {
    late Subscription subscription;

    setUp(() {
      subscription = Subscription(
        id: 'test-id-123',
        name: 'Netflix',
        price: 15.99,
        currency: 'USD',
        cycle: 'monthly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    group('Constructor', () {
      test('creates subscription with required fields', () {
        expect(subscription.id, 'test-id-123');
        expect(subscription.name, 'Netflix');
        expect(subscription.price, 15.99);
        expect(subscription.currency, 'USD');
        expect(subscription.cycle, 'monthly');
      });

      test('has correct default values', () {
        expect(subscription.isCancelled, false);
        expect(subscription.cancelledAt, null);
        expect(subscription.isTrial, false);
        expect(subscription.trialEndsAt, null);
        expect(subscription.brandId, null);
      });

      test('creates subscription with trial fields', () {
        final trialSub = Subscription(
          id: 'trial-123',
          name: 'Spotify',
          price: 9.99,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isTrial: true,
          trialEndsAt: DateTime.now().add(const Duration(days: 7)),
        );

        expect(trialSub.isTrial, true);
        expect(trialSub.trialEndsAt, isNotNull);
      });
    });

    group('Status', () {
      test('returns active for future payment date', () {
        final activeSub = Subscription(
          id: '1',
          name: 'Test',
          price: 10,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 10)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(activeSub.status, SubscriptionStatus.active);
      });

      test('returns soon for payment within 3 days', () {
        final soonSub = Subscription(
          id: '2',
          name: 'Test',
          price: 10,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(soonSub.status, SubscriptionStatus.soon);
      });

      test('returns overdue for past payment date', () {
        final overdueSub = Subscription(
          id: '3',
          name: 'Test',
          price: 10,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(overdueSub.status, SubscriptionStatus.overdue);
      });

      test('returns cancelled for cancelled subscription', () {
        final cancelledSub = Subscription(
          id: '4',
          name: 'Test',
          price: 10,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 10)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isCancelled: true,
          cancelledAt: DateTime.now(),
        );

        expect(cancelledSub.status, SubscriptionStatus.cancelled);
      });

      test('returns soon for today payment', () {
        final now = DateTime.now();
        final todaySub = Subscription(
          id: '5',
          name: 'Test',
          price: 10,
          cycle: 'monthly',
          nextPaymentDate: DateTime(now.year, now.month, now.day),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(todaySub.status, SubscriptionStatus.soon);
      });
    });

    group('Monthly Equivalent', () {
      test('returns same price for monthly subscription', () {
        final monthlySub = Subscription(
          id: '1',
          name: 'Test',
          price: 10.0,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(monthlySub.monthlyEquivalent, 10.0);
      });

      test('returns price/12 for yearly subscription', () {
        final yearlySub = Subscription(
          id: '2',
          name: 'Test',
          price: 120.0,
          cycle: 'yearly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(yearlySub.monthlyEquivalent, 10.0);
      });

      test('returns price/3 for quarterly subscription', () {
        final quarterlySub = Subscription(
          id: '3',
          name: 'Test',
          price: 30.0,
          cycle: 'quarterly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(quarterlySub.monthlyEquivalent, 10.0);
      });

      test('returns price*4.33 for weekly subscription', () {
        final weeklySub = Subscription(
          id: '4',
          name: 'Test',
          price: 10.0,
          cycle: 'weekly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(weeklySub.monthlyEquivalent, closeTo(43.3, 0.1));
      });

      test('returns 0 for active trial', () {
        final trialSub = Subscription(
          id: '5',
          name: 'Test',
          price: 10.0,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isTrial: true,
          trialEndsAt: DateTime.now().add(const Duration(days: 7)),
        );

        expect(trialSub.monthlyEquivalent, 0);
      });
    });

    group('Trial Methods', () {
      test('daysUntilTrialEnds returns correct days', () {
        final trialSub = Subscription(
          id: '1',
          name: 'Test',
          price: 10.0,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isTrial: true,
          trialEndsAt: DateTime.now().add(const Duration(days: 5)),
        );

        expect(trialSub.daysUntilTrialEnds, 5);
      });

      test('daysUntilTrialEnds returns null for non-trial', () {
        expect(subscription.daysUntilTrialEnds, null);
      });

      test('isTrialExpired returns false for active trial', () {
        final activeTrial = Subscription(
          id: '1',
          name: 'Test',
          price: 10.0,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isTrial: true,
          trialEndsAt: DateTime.now().add(const Duration(days: 5)),
        );

        expect(activeTrial.isTrialExpired, false);
      });

      test('isTrialExpired returns true for expired trial', () {
        final expiredTrial = Subscription(
          id: '2',
          name: 'Test',
          price: 10.0,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isTrial: true,
          trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(expiredTrial.isTrialExpired, true);
      });
    });

    group('CopyWith', () {
      test('creates copy with updated name', () {
        final copy = subscription.copyWith(name: 'Spotify');

        expect(copy.name, 'Spotify');
        expect(copy.price, subscription.price);
        expect(copy.id, subscription.id);
      });

      test('creates copy with updated price', () {
        final copy = subscription.copyWith(price: 19.99);

        expect(copy.price, 19.99);
        expect(copy.name, subscription.name);
      });

      test('clearCancelledAt sets cancelledAt to null', () {
        final cancelledSub = subscription.copyWith(
          isCancelled: true,
          cancelledAt: DateTime.now(),
        );
        final reactivated = cancelledSub.copyWith(
          isCancelled: false,
          clearCancelledAt: true,
        );

        expect(reactivated.isCancelled, false);
        expect(reactivated.cancelledAt, null);
      });

      test('clearTrialEndsAt sets trialEndsAt to null', () {
        final trialSub = subscription.copyWith(
          isTrial: true,
          trialEndsAt: DateTime.now().add(const Duration(days: 7)),
        );
        final noTrial = trialSub.copyWith(
          isTrial: false,
          clearTrialEndsAt: true,
        );

        expect(noTrial.isTrial, false);
        expect(noTrial.trialEndsAt, null);
      });
    });

    group('Equality', () {
      test('subscriptions with same id are equal', () {
        final sub1 = Subscription(
          id: 'same-id',
          name: 'Netflix',
          price: 15.99,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final sub2 = Subscription(
          id: 'same-id',
          name: 'Different Name',
          price: 99.99,
          cycle: 'yearly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(sub1, equals(sub2));
        expect(sub1.hashCode, equals(sub2.hashCode));
      });

      test('subscriptions with different ids are not equal', () {
        final sub1 = Subscription(
          id: 'id-1',
          name: 'Netflix',
          price: 15.99,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final sub2 = Subscription(
          id: 'id-2',
          name: 'Netflix',
          price: 15.99,
          cycle: 'monthly',
          nextPaymentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(sub1, isNot(equals(sub2)));
      });
    });

    group('ToString', () {
      test('returns formatted string', () {
        final str = subscription.toString();

        expect(str, contains('Netflix'));
        expect(str, contains('15.99'));
        expect(str, contains('USD'));
        expect(str, contains('monthly'));
      });
    });
  });

  group('SubscriptionStatus Enum', () {
    test('has all expected values', () {
      expect(SubscriptionStatus.values.length, 4);
      expect(SubscriptionStatus.values, contains(SubscriptionStatus.active));
      expect(SubscriptionStatus.values, contains(SubscriptionStatus.soon));
      expect(SubscriptionStatus.values, contains(SubscriptionStatus.overdue));
      expect(SubscriptionStatus.values, contains(SubscriptionStatus.cancelled));
    });
  });
}
