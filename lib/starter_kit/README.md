# Starter Kit Plugin

A strictly architected, modular Clean Architecture plugin for Flutter apps.

## Features at a Glance

| Feature | Description | Stack | Swappable? |
| :--- | :--- | :--- | :--- |
| **IAP** | Subscriptions & One-Time Purchases | Bloc + Clean Arch | ✅ (RevenueCat default) |
| **Ads** | Interstitial, Reward, Banner | Bloc + Clean Arch | ✅ (AdMob default) |
| **Analytics** | Unified Event Logging | Bloc (Retention) | ✅ (Firebase default) |
| **Services** | Config, Rating, GDPR, Feedback | Repositories | ✅ |

---

## 🚀 Getting Started

### 1. Installation

Ensure `pubspec.yaml` includes:
```yaml
dependencies:
  starter_kit:
    path: ./lib/starter_kit
  flutter_bloc: ^8.1.0
  get_it: ^7.6.0
  # ... provider specific packages (purchases_flutter, google_mobile_ads, firebase_core)
```

### 2. Initialization

In your `main.dart`, initialize the kit before `runApp`. You can inject custom configurations here.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Required for default providers

  // Initialize Starter Kit with default providers
  await StarterKit.initialize();

  // OR: Initialize with CUSTOM providers (e.g. Adapty for IAP)
  /*
  await StarterKit.initialize(
    iapDataSource: MyAdaptyDataSource(), 
    adsDataSource: MyAppLovinDataSource(),
    supportEmail: 'contact@myapp.com',
  );
  */

  runApp(const MyApp());
}
```

---

## 📦 Features & Examples

### 1. In-App Purchases (IAP)

**Goal:** Check subscription status and lock/unlock content.

**Usage Example:**

```dart
// 1. Access the Bloc
final iapBloc = StarterKit.iapBloc;

// 2. Wrap your widget
BlocProvider.value(
  value: iapBloc..add(const IapInitialize(apiKey: 'appl_12345...')), // Initialize with your key
  child: BlocBuilder<IapBloc, IapState>(
    builder: (context, state) {
      // HANDLE LOADING
      if (state is IapLoading) {
        return const CircularProgressIndicator();
      }
      
      // CHECK PREMIUM STATUS
      if (state is IapInitialized) {
        if (state.status.isPremium) {
           return const PremiumContentView();
        }
        return const LockedView(
          onPurchaseTap: () {
             // TRIGGER PURCHASE
             iapBloc.add(const IapPurchaseProduct(productId: 'monthly_sub'));
          }
        );
      }
      
      // HANDLE ERROR
      if (state is IapError) {
        return Text('Error: ${state.message}');
      }
      
      return const SizedBox.shrink();
    },
  ),
);
```

### 2. Ads

**Goal:** Show an interstitial ad before a sensitive action.

**Usage Example:**

```dart
// 1. Access the Bloc
final adsBloc = StarterKit.adsBloc;

// 2. Initialize
adsBloc.add(AdsInitialize(
  config: AdsConfig(
    interstitialAdUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
    rewardedAdUnitId: 'ca-app-pub-3940256099942544/5224354917',     // Test ID
  ),
));

// 3. Load Ad
adsBloc.add(const AdsLoadInterstitial(adUnitId: '...'));

// 4. Listen and Show
BlocListener<AdsBloc, AdsState>(
  listener: (context, state) {
    if (state is AdsReady && state.isInterstitialReady) {
      // Ad is ready, show it
      adsBloc.add(const AdsShowInterstitial());
    }
    
    if (state is AdsShowSuccess) {
       // Navigate to next screen after ad
       Navigator.of(context).pushNamed('/next_screen');
    }
  },
  child: MyWidget(),
)
```

### 3. Analytics

**Goal:** Log a custom event.

**Usage Example:**

```dart
// Log simple event
StarterKit.analyticsBloc.add(
  const AnalyticsLogEvent(
    name: 'video_downloaded',
    parameters: {'video_id': '123', 'quality': 'HD'},
  ),
);
```

### 4. Services (Remote Config, GDPR, Rating)

**Goal:** Fetch a feature flag or request review.

```dart
// REMOTE CONFIG
final configRepo = StarterKit.sl<RemoteConfigRepository>();
final showNewUI = configRepo.getBool('show_new_ui');

// APP RATING
final ratingRepo = StarterKit.sl<AppRatingRepository>();
// Check eligibility (logic: installed > 3 days & launched > 5 times)
final result = await ratingRepo.checkEligibility();
if (result.getOrElse(() => false)) {
  await ratingRepo.requestReview();
}

// GDPR
final gdprRepo = StarterKit.sl<GdprRepository>();
await gdprRepo.requestConsent();
```

---

## 🛠 Swapping Providers (The "Clean" Part)

Want to switch from **RevenueCat** to **Adapty**? You don't need to rewrite your UI logic.

1.  **Create a Data Source**: Implement the `IapRemoteDataSource` interface.

```dart
import 'package:starter_kit/features/iap/data/datasources/iap_remote_data_source.dart';

class MyAdaptyDataSource implements IapRemoteDataSource {
  @override
  Future<void> initialize(String apiKey) async {
    // Call Adapty.activate()
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    // Call Adapty.getPurchaserInfo() and map to SubscriptionStatus
  }
  
  // Implement other methods...
}
```

2.  **Inject it**:

```dart
await StarterKit.initialize(
  iapDataSource: MyAdaptyDataSource(), // <--- Swapped!
);
```

Everything else (`IapBloc`, UI widgets) works exactly the same.
