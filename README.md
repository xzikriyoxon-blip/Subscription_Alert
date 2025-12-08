# Subscription Alert

A Flutter mobile app to track subscriptions and receive payment reminders.

## Features

- 🔐 **Google Sign-In** - Secure authentication with Firebase Auth
- 📋 **Subscription Management** - Add, edit, and delete subscriptions
- 💰 **Cost Tracking** - View total monthly costs across all subscriptions
- 🔔 **Smart Notifications** - Get reminders 3 days before and on payment dates
- 📊 **Status Indicators** - Visual indicators for overdue, upcoming, and active subscriptions
- ☁️ **Cloud Sync** - All data synced via Firebase Firestore

## Tech Stack

- Flutter (Dart)
- Firebase Authentication (Google Sign-In)
- Cloud Firestore
- Riverpod (State Management)
- flutter_local_notifications

## Setup Instructions

### Prerequisites

1. Flutter SDK (>=3.0.0)
2. Android Studio / VS Code
3. Firebase account
4. Node.js (for Firebase CLI)

### Step 1: Clone and Install Dependencies

```bash
cd subscription_alert
flutter pub get
```

### Step 2: Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "Subscription Alert"
   - Enable Google Analytics (optional)

2. **Add Android App**
   - Package name: `com.example.subscription_alert`
   - Download `google-services.json`
   - Place it in `android/app/`

3. **Add iOS App** (if building for iOS)
   - Bundle ID: `com.example.subscriptionAlert`
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`

4. **Enable Firebase Services**
   
   **Authentication:**
   - Go to Authentication > Sign-in method
   - Enable "Google" provider
   - Add your SHA-1 fingerprint for Android
   
   **Firestore:**
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (see below)

5. **Configure FlutterFire** (Recommended)
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   This will update `lib/firebase_options.dart` with your configuration.

### Step 3: Get SHA-1 Fingerprint (Android)

For Google Sign-In to work on Android:

```bash
# Debug key
cd android
./gradlew signingReport
```

Copy the SHA-1 fingerprint and add it to Firebase Console:
- Project Settings > Your Apps > Android app > Add fingerprint

### Step 4: Firestore Security Rules

In Firebase Console > Firestore > Rules, add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subscriptions subcollection
      match /subscriptions/{subscriptionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Step 5: Run the App

```bash
# Android
flutter run

# iOS (macOS only)
cd ios && pod install && cd ..
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   └── subscription.dart     # Subscription data model
├── services/
│   ├── auth_service.dart     # Firebase Auth service
│   ├── firestore_service.dart # Firestore CRUD operations
│   └── notification_service.dart # Local notifications
├── providers/
│   ├── auth_provider.dart    # Auth state providers
│   └── subscription_providers.dart # Subscription providers
├── screens/
│   ├── login_screen.dart     # Google Sign-In screen
│   ├── home_screen.dart      # Main subscription list
│   └── add_edit_subscription_screen.dart # Add/Edit form
└── widgets/
    └── subscription_list_item.dart # Subscription card widget
```

## Firestore Data Model

```
users/
└── {userId}/
    └── subscriptions/
        └── {subscriptionId}/
            ├── name: String
            ├── price: Number
            ├── currency: String
            ├── cycle: String ("monthly" | "yearly")
            ├── nextPaymentDate: Timestamp
            ├── createdAt: Timestamp
            └── updatedAt: Timestamp
```

## Notifications

The app schedules two notifications per subscription:
1. **3 days before** payment date (9:00 AM)
2. **On** the payment date (9:00 AM)

Notifications persist after:
- App restart
- Device reboot
- App updates

## Customization

### Change Default Currency

In `lib/screens/add_edit_subscription_screen.dart`:
```dart
static const List<String> _currencies = ['UZS', 'USD', 'EUR', 'RUB'];
```

### Add More Billing Cycles

In `lib/screens/add_edit_subscription_screen.dart`:
```dart
static const List<String> _cycles = ['monthly', 'yearly', 'weekly'];
```

Don't forget to update `monthlyEquivalent` in the model.

## Troubleshooting

### Google Sign-In Not Working (Android)

1. Verify SHA-1 fingerprint is added to Firebase
2. Check `google-services.json` is in `android/app/`
3. Ensure Google Sign-In is enabled in Firebase Console

### Notifications Not Showing

1. Check notification permissions in device settings
2. Verify the app has `SCHEDULE_EXACT_ALARM` permission
3. On Android 13+, ensure `POST_NOTIFICATIONS` permission is granted

### Build Errors

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

## License

MIT License - feel free to use this for your own projects!
