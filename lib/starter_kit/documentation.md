# StarterKit Documentation 📘

This document provides a comprehensive reference for all parameters and configurations in the `StarterKit` plugin.

---

## 🚀 Initialization

**Method**: `StarterKit.initialize()`

Must be called in `main.dart` before `runApp`.

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `iapDataSource` | `IapRemoteDataSource?` | No | `null` | Custom In-App Purchase logic. If null, uses RevenueCat implementation. |
| `adsDataSource` | `AdsRemoteDataSource?` | No | `null` | Custom Ads logic. If null, uses AdMob implementation. |
| `analyticsDataSources` | `List<AnalyticsRemoteDataSource>?` | No | `null` | List of analytics providers (e.g., Firebase, Mixpanel). Default: Firebase. |
| `posthogDataSource` | `PostHogRemoteDataSource?` | No | `null` | Custom PostHog wrapper. Default: Standard PostHog implementation. |
| `supportEmail` | `String?` | No | `'support@example.com'` | Email used for the Feedback service. |

**Example:**
```dart
await StarterKit.initialize(
  supportEmail: 'contact@myapp.com',
  // Optional: Swap Ad Provider
  adsDataSource: MyAppLovinDataSource(),
);
```

---

## 🎨 Onboarding

**Method**: `StarterKit.onboarding()`

Returns a `Widget` representing your onboarding flow.

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `pages` | `List<OnboardingPageModel>` | **Yes** | - | list of pages to display. |
| `template` | `OnboardingTemplateType` | No | `standard` | Layout style: `standard`, `minimal`, or `custom`. |
| `onComplete` | `VoidCallback?` | No | `null` | Called when user finishes the last page (e.g., tap "Start"). |
| `onSkip` | `VoidCallback?` | No | `null` | Called when "Skip" button is tapped. Only shows Skip if provided. |
| `onPageChange` | `Function(int)?` | No | `null` | Callback for page swipe events. |
| `activeDotColor` | `Color` | No | `Colors.blue` | Color of the active pagination dot. |
| `nextText` | `String` | No | `'Next'` | Text for the "Next" button. |
| `completeText` | `String` | No | `'Start'` | Text for the "Start" button (last page). |

### `OnboardingPageModel`
| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | Headline text. |
| `description` | `String` | Body text. |
| `imagePath` | `String?` | Asset path for the main image (Standard template). |
| `customWidget` | `Widget?` | Any widget to render in the center (overrides image). |
| `titleColor` | `Color?` | Custom color for title. |
| `descriptionColor` | `Color?` | Custom color for description. |

---

## ⚙️ Settings

**Method**: `StarterKit.settings()`

Returns a `Widget` representing a generated settings page.

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `sections` | `List<SettingsSection>` | - | Data model defining the list content. |
| `template` | `SettingsTemplateType` | `list` | `list` (flat) or `grouped` (iOS style). |
| `title` | `String` | `'Settings'` | AppBar title. |
| `backgroundColor` | `Color?` | `null` | Custom scaffold background color. |

### `SettingsSection` & `SettingsTile`
*   **`SettingsSection`**: Has a `String? title` and `List<SettingsTile> tiles`.
*   **`SettingsTile`**:
    *   `title` (String): Main text.
    *   `subtitle` (String?): Secondary text.
    *   `icon` (IconData?): Leading icon.
    *   `onTap` (VoidCallback?): Action when tapped.
    *   `trailing` (Widget?): Custom right-side widget (e.g., Switch).

---

## 💸 Ad Revenue & Analytics

**Logic**: The matching of Ads to Analytics is **automated**.

1.  **Events**: When `AdsBloc` detects a paid event (money earned), it emits an internal signal.
2.  **Wiring**: `StarterKit` listens to this and automatically calls `AnalyticsBloc.add(AnalyticsLogAdRevenue(...))`.
3.  **Destinations**:
    *   **Firebase**: Logs `logAdImpression` (Official Google format).
    *   **PostHog**: Logs `ad_revenue` event with properties: `value`, `currency`, `ad_network`, `ad_unit_id`.

**You do not need to manually log ad revenue.**

---

## 📦 Dependency Injection (Advanced)

Access internal blocs if you need to trigger events manually:

*   `StarterKit.iapBloc` -> `IapBloc`
*   `StarterKit.adsBloc` -> `AdsBloc`
*   `StarterKit.analyticsBloc` -> `AnalyticsBloc`
*   `StarterKit.postHog` -> `PostHogRemoteDataSource?`

**Example: Restore Purchases**
```dart
StarterKit.iapBloc.add(const IapRestorePurchases());
```
