# smart_app_update_flutter

[![pub package](https://img.shields.io/pub/v/smart_app_update_flutter.svg)](https://pub.dev/packages/smart_app_update_flutter)
[![likes](https://img.shields.io/pub/likes/smart_app_update_flutter)](https://pub.dev/packages/smart_app_update_flutter/score)
[![popularity](https://img.shields.io/pub/popularity/smart_app_update_flutter)](https://pub.dev/packages/smart_app_update_flutter/score)
[![pub points](https://img.shields.io/pub/points/smart_app_update_flutter)](https://pub.dev/packages/smart_app_update_flutter/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A lightweight Flutter package to automatically check for app updates from **Google Play Store** and **Apple App Store**. Supports **force update**, **soft update**, **Android TV**, and customizable update dialogs — with zero boilerplate.

---

## Demo

| Mobile Bottom Sheet | Android TV Dialog |
|---|---|
| ![Mobile Update Dialog](https://github.com/akhileshgoswami/smart_app_update/raw/main/example/lib/assets/screenshots/Screenshot_1756387828.png) | ![TV Update Dialog](https://github.com/akhileshgoswami/smart_app_update/raw/main/example/lib/assets/screenshots/tv_app.png) |

---

## ✨ Features

- ✅ Automatic update checking from Play Store & App Store
- ✅ Force update — prevents user from dismissing
- ✅ Soft update — "Maybe Later" option with snooze interval
- ✅ Android TV support — D-pad navigable `AlertDialog`
- ✅ Repeat interval — control how often the dialog re-appears
- ✅ Debug test mode — preview dialog without a live store app
- ✅ Semantic version comparison (handles `1.0.0` vs `1.0.10` correctly)
- ✅ Minimal dependencies, easy drop-in integration

---

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_app_update_flutter: ^1.1.1
```

Then run:

```bash
flutter pub get
```

---

## 🔧 Usage

Call `AppUpdateManager.checkAndPrompt()` inside your app's `initState` or after navigation is ready (e.g., inside `GetMaterialApp`'s `builder` or on your home screen).

### Basic usage

```dart
import 'package:smart_app_update_flutter/smart_app_update_flutter.dart';

@override
void initState() {
  super.initState();
  AppUpdateManager.checkAndPrompt();
}
```

### With all options

```dart
AppUpdateManager.checkAndPrompt(
  forceUpdate: false,           // true = user cannot skip update
  repeat_totalminutes: 60,      // re-show dialog after 60 minutes if user taps "Maybe Later"
  notes: "Bug fixes and performance improvements.", // optional release notes
  isAndroidTV: false,           // set true for Android TV (shows AlertDialog)
  testDebuge: false,            // set true in debug to preview the dialog immediately
);
```

---

## ⚙️ Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `forceUpdate` | `bool` | `false` | If `true`, user cannot dismiss the dialog |
| `repeat_totalminutes` | `int?` | `60` | Minutes before showing the dialog again after "Maybe Later" |
| `notes` | `String?` | `null` | Optional release notes shown in the dialog |
| `isAndroidTV` | `bool` | `false` | Shows a TV-friendly `AlertDialog` instead of a bottom sheet |
| `testDebuge` | `bool` | `false` | Shows a test dialog in debug mode (bypasses store checks) |

---

## 📱 Platform Setup

### Android

No additional setup required. The package fetches version info directly from the Play Store listing.

### iOS

No additional setup required. The package uses the iTunes Lookup API.

### Android TV

Pass `isAndroidTV: true` to show a centered dialog with D-pad autofocus support. The update button opens the TV Play Store via `market://` URI with a web URL fallback.

---

## 🧪 Testing Without a Live Store App

Use `testDebuge: true` to preview the update dialog during development — no store listing needed:

```dart
AppUpdateManager.checkAndPrompt(testDebuge: true);
```

> This only works in **debug mode**. The flag is ignored in release builds.

---

## 📦 Model

```dart
CustomUpdateVersion({
  String? newVersion,    // latest version string e.g. "2.0.1"
  String? redirectLink,  // store URL to open on "Update now"
})
```

---

## 🗂 Project Structure

```
lib/
├── smart_app_update_flutter.dart   # barrel export
└── src/
    ├── app_update_manager.dart     # core logic: fetch + compare + show
    ├── models/
    │   └── custom_update_version.dart
    ├── ui/
    │   └── update_bottom_sheet.dart  # mobile bottom sheet + TV dialog
    └── utils/
        ├── utility.dart
        └── app_constants.dart
```

---

## 🤝 Contributing

Contributions, issues and feature requests are welcome!
Feel free to open an issue at [GitHub Issues](https://github.com/akhileshgoswami/smart_app_update_flutter/issues).

---

## 📄 License

MIT © [Akhilesh Goswami](https://github.com/akhileshgoswami)
