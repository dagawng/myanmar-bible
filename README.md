# 🇲🇲 Myanmar Bible Audio App

A production-ready, cross-platform **Myanmar Bible Audio App** built with **Flutter**, **Clean Architecture**, and **Material 3**. 

Designed to serve Myanmar’s diverse linguistic and cultural communities, the app allows users to **read Bible text**, **stream synced audio narration**, **navigate by Book → Chapter → Verse**, and **switch seamlessly between multiple regional languages**.

---

## 🌟 Key Features

- 🎧 **Audio Playback Engine**:
  - Continuous audio streaming powered by `just_audio` & `audio_service`.
  - Full background playback support with lock-screen media controls.
  - Controls for 10-second rewind/forward, seeking, and variable playback speeds ($0.75x$ to $2.0x$).
  - **Marquee Text Animation**: Automatically scrolls long book and chapter titles smoothly.

- 📖 **Multi-Language Bible Support**:
  - **Burmese (မြန်မာ)**: Judson Translation (*Jud*) with native Myanmar typography (`Padauk`).
  - **Kachin (Jinghpaw)**: Jinghpaw Common Language Bible (*JCLB*, 2009).
  - **Chin (Hakha)**: Hakha Baibal (*cnh*).
  - **Shan (လိၵ်ႈႁူမ်ႈၵိၼ် ၽြႃး)**: Shan script script support (`Panglong`).
  - **Sgaw Karen (စှီ်ဆ်ါလံာ်ကဲးဒိ)**: Sgaw Karen script support.
  - **Kayah Li (ꤊꤤ꤬ꤛꤢꤩ꤬)**: Kayah Li script support.
  - **English**: King James Version (*KJV*).

- 🎵 **Mini-Player & Customization**:
  - Persistent bottom mini-player accessible across all primary tabs.
  - **1-Tap Quick Dismiss**: Tapping the `X` button on the mini-player immediately stops playback and hides the player.
  - **User Settings Toggle**: Enable/disable the floating mini-player via **Settings → Show Audio Mini-Player** (persisted locally).

- 🎨 **Material Design 3 (Material You)**:
  - Full support for Light and Dark modes.
  - M3 NavigationBar, Card, SegmentedButton, and HSL-based dynamic color tokens.
  - Multi-script typography handler (`ScriptUtils`) for line height and letter spacing adjustments across scripts.

---

## 🏗️ Architecture — Clean Architecture + SOLID

The codebase strictly adheres to **Feature-Based Clean Architecture** and **SOLID Principles**, maintaining total separation of concerns into distinct layers:

```
lib/
├── core/                                # Cross-cutting utilities, theme, DI, constants
│   ├── constants/                       # App, Firebase, and Bible constants
│   ├── di/                              # Dependency Injection (GetIt service locator)
│   ├── error/                           # Domain Failure & Exception definitions
│   ├── network/                         # Connectivity checker interface & impl
│   ├── presentation/
│   │   ├── pages/                       # MainNavigationPage (IndexedStack tabs)
│   │   └── widgets/                     # MarqueeText, shared UI components
│   ├── theme/                           # AppTheme, ColorScheme (M3 seed colors)
│   └── utils/                           # ScriptUtils (Typography & Myanmar numerals)
│
├── features/                            # Modular feature folders
│   ├── audio/                           # Audio player, streaming & BLoC state
│   ├── bible/                           # Book/Chapter/Verse navigation & JSON parser
│   ├── language/                        # Language picker & multi-script switcher
│   └── settings/                        # User preferences & theme cubit
│
├── app.dart                             # MaterialApp configuration with M3 themes
└── main.dart                            # App entry point, DI & Firebase init
```

### Architectural Highlights
- **Single Responsibility (SRP)**: Use Cases execute individual atomic operations (`GetBooks`, `GetVerses`, `SeekAudioEvent`).
- **Dependency Inversion (DIP)**: High-level modules depend exclusively on abstract repository interfaces (`BibleRepository`, `AudioRepository`).
- **BLoC State Management**: State transitions are handled cleanly via `flutter_bloc` v9+ with non-blocking stream event handlers.

---

## 🛠️ Technology Stack

| Layer | Technology |
| --- | --- |
| **Framework** | Flutter (Dart SDK ^3.12) |
| **UI System** | Material 3 (Material You) |
| **State Mgmt** | `flutter_bloc` / `cubit` |
| **Dependency Injection** | `get_it` + `injectable` |
| **Routing** | `go_router` |
| **Audio Engine** | `just_audio` + `audio_service` |
| **Local Storage** | `shared_preferences` + `hive_flutter` |
| **Networking** | `dio` + `connectivity_plus` |
| **Testing** | `flutter_test`, `bloc_test`, `mockito` |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.12 or newer)
- Xcode (for iOS Simulator execution) or Android Studio (for Android Emulator)
- CocoaPods (`pod install` for iOS target)

### Setup & Installation

1. **Clone the repository**:
   ```bash
   git clone https.github.com/dagawng/myanmar-bible.git
   cd myanmar-bible
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run unit & widget tests**:
   ```bash
   flutter test
   ```

4. **Launch application on target device**:
   ```bash
   # Run on iOS Simulator
   flutter run -d ios

   # Run on Android Emulator
   flutter run -d android
   ```

---

## 🧪 Testing

All unit tests for network connectivity, script typography resolvers, and language Cubits are verified passing:

```bash
flutter test
```

Expected output:
```text
00:00 +9: All tests passed!
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
