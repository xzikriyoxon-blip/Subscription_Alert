// Main test file for Subscription Alert app.
// Exports all test files for convenient test running.

import 'package:flutter_test/flutter_test.dart';

// Import model tests
import 'models/subscription_test.dart' as subscription_tests;
import 'models/currency_test.dart' as currency_tests;

// Import service tests
import 'services/timeline_service_test.dart' as timeline_tests;

void main() {
  group('All Tests', () {
    subscription_tests.main();
    currency_tests.main();
    timeline_tests.main();
  });
}
