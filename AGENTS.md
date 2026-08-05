# Myanmar Bible Audio App — Agent Instructions

## Project Overview

Build a **production-ready Myanmar Bible Audio app** where users can:

- **Listen** to Bible audio (streamed from Firebase Storage)
- **Read** Bible text alongside audio playback
- **Switch** between multiple Bible languages
- **Navigate** by Book → Chapter → Verse
- **Bookmark** and **highlight** favourite passages
- **Download** audio for offline listening
- **Search** across the entire Bible text

The app targets **Myanmar's diverse language communities**. It supports **multiple Bible languages** including but not limited to:

| Language         | Script         | Example Font       |
| ---------------- | -------------- | ------------------ |
| Burmese (မြန်မာ)   | Myanmar script | Padauk, Myanmar3   |
| Kachin (Jinghpaw) | Latin script   | System default     |
| Chin (various)   | Latin script   | System default     |
| Shan             | Shan script    | Shan, Panglong     |
| Kayin (Karen)    | Karen script   | Karen Unicode      |
| Kayah (Red Karen)| Kayah Li script| Kayah Li           |
| English          | Latin script   | Inter, Roboto      |

Each language has its own set of Bible text and audio narration. Users can switch languages at any time.

---

## Technology Stack

| Layer          | Technology                                    |
| -------------- | --------------------------------------------- |
| Framework      | Flutter (latest stable)                       |
| Language       | Dart                                          |
| UI System      | Material 3 (Material You)                     |
| State Mgmt    | flutter_bloc (Bloc/Cubit)                     |
| DI             | get_it + injectable                           |
| Navigation     | go_router                                     |
| Backend        | Firebase (Auth, Firestore, Storage, Analytics, Crashlytics)|
| Audio          | just_audio + audio_service (Background + Lock Screen) |
| Local DB       | Hive / Isar (offline cache)                   |
| Networking     | dio (for any REST calls)                      |
| Localization   | flutter_localizations + intl                  |
| Sharing        | share_plus + path_provider (Verse Images)     |
| Testing        | bloc_test, mockito, integration_test          |

---

## Architecture — Clean Architecture + SOLID

Follow **Clean Architecture** with three distinct layers. Every layer communicates only through **abstractions (interfaces)**, never concrete implementations.

```
lib/
├── core/                          # Shared utilities, constants, theme
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── firebase_constants.dart
│   │   └── bible_constants.dart
│   ├── error/
│   │   ├── failures.dart          # Failure sealed class
│   │   └── exceptions.dart        # Custom exceptions
│   ├── network/
│   │   └── network_info.dart      # Connectivity checker interface + impl
│   ├── theme/
│   │   ├── app_theme.dart         # M3 ThemeData (light + dark)
│   │   ├── app_colors.dart        # Seed color & custom ColorScheme
│   │   ├── app_typography.dart    # Multi-script font styles
│   │   └── app_spacing.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   └── script_utils.dart      # Script detection & font resolver
│   └── di/
│       └── injection.dart         # get_it service locator setup
│
├── features/
│   ├── auth/                      # Firebase Auth (optional, for sync)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart       # Abstract
│   │   │   └── usecases/
│   │   │       ├── sign_in.dart
│   │   │       ├── sign_out.dart
│   │   │       └── get_current_user.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── language/                  # Multi-language Bible management
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── language_remote_datasource.dart
│   │   │   │   └── language_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── language_model.dart
│   │   │   └── repositories/
│   │   │       └── language_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── language.dart
│   │   │   ├── repositories/
│   │   │   │   └── language_repository.dart         # Abstract
│   │   │   └── usecases/
│   │   │       ├── get_languages.dart
│   │   │       ├── get_active_language.dart
│   │   │       └── set_active_language.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── language_cubit.dart
│   │       ├── pages/
│   │       │   └── language_picker_page.dart
│   │       └── widgets/
│   │           └── language_tile.dart
│   │
│   ├── bible/                     # Core Bible text reading
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── bible_remote_datasource.dart    # Firestore
│   │   │   │   └── bible_local_datasource.dart     # Hive/Isar cache
│   │   │   ├── models/
│   │   │   │   ├── book_model.dart
│   │   │   │   ├── chapter_model.dart
│   │   │   │   └── verse_model.dart
│   │   │   └── repositories/
│   │   │       └── bible_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── book.dart
│   │   │   │   ├── chapter.dart
│   │   │   │   └── verse.dart
│   │   │   ├── repositories/
│   │   │   │   └── bible_repository.dart           # Abstract
│   │   │   └── usecases/
│   │   │       ├── get_books.dart
│   │   │       ├── get_chapters.dart
│   │   │       ├── get_verses.dart
│   │   │       └── search_bible.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── bible_bloc.dart
│   │       │   ├── bible_event.dart
│   │       │   └── bible_state.dart
│   │       ├── pages/
│   │       │   ├── book_list_page.dart
│   │       │   ├── chapter_list_page.dart
│   │       │   └── verse_reader_page.dart
│   │       └── widgets/
│   │           ├── book_card.dart
│   │           ├── chapter_grid.dart
│   │           └── verse_text.dart
│   │
│   ├── audio/                     # Audio playback feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── audio_remote_datasource.dart    # Firebase Storage URLs
│   │   │   │   └── audio_local_datasource.dart     # Downloaded files
│   │   │   ├── models/
│   │   │   │   └── audio_track_model.dart
│   │   │   └── repositories/
│   │   │       └── audio_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── audio_track.dart
│   │   │   ├── repositories/
│   │   │   │   └── audio_repository.dart           # Abstract
│   │   │   └── usecases/
│   │   │       ├── get_audio_url.dart
│   │   │       ├── download_audio.dart
│   │   │       ├── get_downloaded_audios.dart
│   │   │       └── delete_downloaded_audio.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── audio_player_bloc.dart
│   │       │   ├── audio_player_event.dart
│   │       │   ├── audio_player_state.dart
│   │       │   ├── download_bloc.dart
│   │       │   ├── download_event.dart
│   │       │   └── download_state.dart
│   │       ├── pages/
│   │       │   └── audio_player_page.dart
│   │       └── widgets/
│   │           ├── audio_controls.dart
│   │           ├── progress_slider.dart
│   │           ├── playback_speed_selector.dart
│   │           └── mini_player.dart
│   │
│   ├── study/                     # Bookmarks, Highlights & Notes
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── study_remote_datasource.dart
│   │   │   │   └── study_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── bookmark_model.dart
│   │   │   │   ├── highlight_model.dart
│   │   │   │   └── note_model.dart
│   │   │   └── repositories/
│   │   │       └── study_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── bookmark.dart
│   │   │   │   ├── highlight.dart
│   │   │   │   └── note.dart
│   │   │   ├── repositories/
│   │   │   │   └── study_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_bookmark.dart
│   │   │       ├── save_highlight.dart
│   │   │       ├── save_note.dart
│   │   │       └── get_study_items.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── study_cubit.dart
│   │       ├── pages/
│   │       │   └── study_items_page.dart
│   │       └── widgets/
│   │           ├── bookmark_tile.dart
│   │           └── color_picker_sheet.dart
│   │
│   ├── share/                     # Verse sharing & image generation
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       ├── share_verse_text.dart
│   │   │       └── generate_verse_image.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── share_cubit.dart
│   │       └── widgets/
│   │           └── verse_image_editor.dart
│   │
│   └── settings/                  # App settings (font size, theme, etc.)
│       ├── data/
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── app_settings.dart
│       │   ├── repositories/
│       │   │   └── settings_repository.dart
│       │   └── usecases/
│       │       ├── get_settings.dart
│       │       └── update_settings.dart
│       └── presentation/
│           ├── bloc/
│           │   └── settings_cubit.dart
│           └── pages/
│               └── settings_page.dart
│
├── app.dart                       # MaterialApp.router with M3 theme
└── main.dart                      # Entry point, DI init, Firebase init
```

---

## Material 3 Theme Setup

Use **Material 3** (`useMaterial3: true`) with `ColorScheme.fromSeed()` for consistent, modern styling across iOS and Android.

### Theme Configuration

```dart
// app_colors.dart
class AppColors {
  // Primary seed color — warm amber/gold for a Bible app feel
  static const Color seedColor = Color(0xFFB8860B); // Dark Goldenrod

  static ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  static ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
}
```

```dart
// app_theme.dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightScheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 2,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    sliderTheme: const SliderThemeData(
      showValueIndicator: ShowValueIndicator.always,
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.darkScheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 2,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    sliderTheme: const SliderThemeData(
      showValueIndicator: ShowValueIndicator.always,
    ),
  );
}
```

### App Root Widget

```dart
// app.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp.router(
          title: 'Myanmar Bible Audio',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,  // ThemeMode.system / light / dark
          routerConfig: appRouter,
        );
      },
    );
  }
}
```

### Key M3 Widgets to Use

| Widget               | Use For                                    |
| -------------------- | ------------------------------------------ |
| `NavigationBar`      | Bottom nav (Books, Search, Bookmarks, Settings) |
| `SearchBar`          | Bible text search                          |
| `Card.filled`        | Book cards, chapter cards                  |
| `ListTile`           | Verse rows, bookmark rows, language list   |
| `Slider`             | Audio progress bar                         |
| `IconButton.filled`  | Play/pause button                          |
| `BottomSheet`        | Mini player, audio controls                |
| `SegmentedButton`    | Old/New Testament toggle                   |
| `FilterChip`         | Language filter, search filters            |
| `CircularProgressIndicator` | Download progress                   |

---

## SOLID Principles — How to Apply

### S — Single Responsibility

Every class has **one reason to change**.

```dart
// ✅ GOOD — UseCase does ONE thing
class GetVerses {
  final BibleRepository repository;
  const GetVerses(this.repository);

  Future<Either<Failure, List<Verse>>> call(GetVersesParams params) {
    return repository.getVerses(
      bookId: params.bookId,
      chapter: params.chapter,
    );
  }
}

// ❌ BAD — A God class that fetches, caches, AND formats
class BibleManager {
  Future<List<Verse>> getVerses() { /* fetch from Firebase */ }
  void cacheLocally() { /* write to Hive */ }
  String formatForDisplay() { /* UI formatting */ }
}
```

### O — Open/Closed

Classes are **open for extension, closed for modification**. Use abstract classes/interfaces.

```dart
// Abstract repository — open for extension
abstract class BibleRepository {
  Future<Either<Failure, List<Book>>> getBooks({required String languageId});
  Future<Either<Failure, List<Verse>>> getVerses({
    required String languageId,
    required String bookId,
    required int chapter,
  });
}

// Concrete impl can be swapped without changing domain
class BibleRepositoryImpl implements BibleRepository {
  final BibleRemoteDatasource remoteDatasource;
  final BibleLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  // ...implementation
}
```

### L — Liskov Substitution

Any subtype must be substitutable for its base type. Models extend entities seamlessly.

```dart
class Book {
  final String id;
  final String languageId;     // Which language this belongs to
  final String name;           // Localized name (e.g., "ကမ္ဘာဦးကျမ်း", "Jatsan Laika")
  final String nameEn;         // English name (canonical key)
  final int totalChapters;
  final BibleTestament testament;

  const Book({
    required this.id,
    required this.languageId,
    required this.name,
    required this.nameEn,
    required this.totalChapters,
    required this.testament,
  });
}

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.languageId,
    required super.name,
    required super.nameEn,
    required super.totalChapters,
    required super.testament,
  });

  factory BookModel.fromFirestore(DocumentSnapshot doc, String languageId) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      languageId: languageId,
      name: data['name'] as String,
      nameEn: data['name_en'] as String,
      totalChapters: data['total_chapters'] as int,
      testament: BibleTestament.values.byName(data['testament']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'name_en': nameEn,
    'total_chapters': totalChapters,
    'testament': testament.name,
  };
}
```

### I — Interface Segregation

Split large interfaces into focused ones.

```dart
// ✅ GOOD — focused interfaces
abstract class AudioPlayback {
  Future<void> play(String url);
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
}

abstract class AudioDownload {
  Future<String> downloadAudio(String url, String fileName);
  Future<void> deleteDownload(String fileName);
  Future<List<String>> getDownloadedFiles();
}

// ❌ BAD — one massive interface
abstract class AudioService {
  Future<void> play(String url);
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<String> downloadAudio(String url, String fileName);
  Future<void> deleteDownload(String fileName);
  Future<List<String>> getDownloadedFiles();
  Future<void> setPlaybackSpeed(double speed);
  Future<void> setVolume(double volume);
  // ... 20 more methods
}
```

### D — Dependency Inversion

High-level modules depend on **abstractions**, not concrete classes. Wire everything via `get_it`.

```dart
// injection.dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ──
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // ── Core ──
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: Connectivity()),
  );

  // ── Bible Feature ──
  // Datasources
  sl.registerLazySingleton<BibleRemoteDatasource>(
    () => BibleRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<BibleLocalDatasource>(
    () => BibleLocalDatasourceImpl(),
  );

  // Repository (depends on abstractions)
  sl.registerLazySingleton<BibleRepository>(
    () => BibleRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetBooks(sl()));
  sl.registerLazySingleton(() => GetVerses(sl()));
  sl.registerLazySingleton(() => SearchBible(sl()));

  // Bloc
  sl.registerFactory(
    () => BibleBloc(
      getBooks: sl(),
      getVerses: sl(),
      searchBible: sl(),
    ),
  );
}
```

---

## Feature-Based Modularity

The app is built using **Feature-Based Clean Architecture**. This means the codebase is highly modular, allowing you to **add, swap, or remove features easily without breaking the whole app**.

### How Modularity is Achieved

1. **Isolated Feature Folders**: Every feature (e.g., `bible`, `audio`, `bookmark`, `language`) lives in its own folder inside `lib/features/`. They do not reach into each other's inner workings.
2. **Interface Abstraction**: Features interact with each other (and with external services) only through Domain interfaces (Repositories). If you want to change how Audio is fetched, you only replace `audio_repository_impl.dart`. The rest of the app doesn't know or care.
3. **Dependency Injection**: The `sl` (Service Locator) in `injection.dart` wires everything together. To swap a feature out, you just change which implementation is registered in `injection.dart`.
4. **State Isolation**: Each feature has its own state management (e.g., `BibleBloc`, `AudioPlayerBloc`). They can communicate by listening to each other's states (e.g., `BibleBloc` updates when `LanguageCubit` state changes) without being tightly coupled.

---

## Firebase Backend Setup

### Firestore Data Schema

```
firestore/
├── languages/                       # Collection: one doc per language
│   ├── {languageId}/                # e.g., "my_burmese", "kachin_jinghpaw"
│   │   ├── name: "မြန်မာ သမ္မာကျမ်းစာ"  # Display name in own script
│   │   ├── name_en: "Burmese Bible"
│   │   ├── language_code: "my"       # ISO 639-1 code
│   │   ├── script: "myanmar"         # "myanmar" | "latin" | "shan" | "karen" | "kayah_li"
│   │   ├── font_family: "Padauk"     # Recommended font for this language
│   │   ├── has_audio: true           # Whether audio is available
│   │   ├── is_active: true           # Show/hide in app
│   │   └── order: 1                  # Sort order in picker
│
├── languages/{languageId}/books/         # Sub-collection: 66 documents
│   ├── {bookId}/
│   │   ├── name: "ကမ္ဘာဦးကျမ်း"      # Localized book name
│   │   ├── name_en: "Genesis"        # English canonical name
│   │   ├── abbreviation: "Gen"
│   │   ├── testament: "old"          # "old" | "new"
│   │   ├── order: 1                  # Sort order
│   │   ├── total_chapters: 50
│   │   └── chapters/                 # Sub-collection
│   │       └── {chapterNumber}/
│   │           ├── chapter: 1
│   │           ├── audio_path: "audio/my_burmese/genesis/chapter_01.mp3"
│   │           ├── audio_duration_ms: 360000
│   │           └── verses/            # Sub-collection
│   │               └── {verseNumber}/
│   │                   ├── verse: 1
│   │                   └── text: "အစအဦး၌ ဘုရားသခင်သည် ..."
│
├── users/                           # Collection (if auth is used)
│   └── {userId}/
│       ├── display_name: "..."
│       ├── active_language: "my_burmese"     # Currently selected
│       ├── study/                   # Sub-collection (Bookmarks, Highlights, Notes)
│       │   └── {itemId}/
│       │       ├── type: "bookmark"          # "bookmark" | "highlight" | "note"
│       │       ├── language_id: "my_burmese"
│       │       ├── book_id: "genesis"
│       │       ├── chapter: 1
│       │       ├── verse: 1
│       │       ├── color_code: "#FFFF00"     # For highlights
│       │       ├── text: "..."               # For notes
│       │       └── created_at: Timestamp
│       └── settings/
│           └── preferences/
│               ├── font_size: 18
│               ├── theme: "dark"
│               ├── playback_speed: 1.0
│               └── last_read:                # Last read persistence
│                   ├── language_id: "my_burmese"
│                   ├── book_id: "genesis"
│                   └── chapter: 1
```

> [!IMPORTANT]
> **Language ID convention**: Use `{languageCode}_{variant}` format, e.g., `my_burmese`, `kachin_jinghpaw`, `chin_hakha`, `shan_shan`, `kayin_sgaw`. This keeps IDs human-readable and unique.

### Firebase Storage Structure

```
firebase-storage/
└── audio/
    ├── my_burmese/                 # Grouped by language ID
    │   ├── genesis/
    │   │   ├── chapter_01.mp3
    │   │   ├── chapter_02.mp3
    │   │   └── ...
    │   ├── exodus/
    │   │   ├── chapter_01.mp3
    │   │   └── ...
    │   └── revelation/
    │       ├── chapter_01.mp3
    │       └── ...
    ├── kachin_jinghpaw/
    │   ├── genesis/
    │   │   ├── chapter_01.mp3
    │   │   └── ...
    │   └── ...
    └── chin_hakha/
        ├── genesis/
        │   ├── chapter_01.mp3
        │   └── ...
        └── ...
```

> [!IMPORTANT]
> **Audio file naming convention**: Use `audio/{languageId}/{bookNameEn}/chapter_XX.mp3` with lowercase English book names and zero-padded chapter numbers. Store the full path in Firestore so the app never constructs paths manually.

### Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Language metadata — read-only
    match /languages/{languageId} {
      allow read: if true;
      allow write: if false;

      // Bible content — read-only for all
      match /books/{bookId} {
        allow read: if true;
        allow write: if false;

        match /chapters/{chapterId} {
          allow read: if true;
          allow write: if false;

          match /verses/{verseId} {
            allow read: if true;
            allow write: if false;
          }
        }
      }
    }

    // User data — only the owner can read/write
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      match /bookmarks/{bookmarkId} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

### Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Audio files — read-only for all (or authenticated users)
    match /audio/{allPaths=**} {
      allow read: if true;
      allow write: if false;  // Upload via Admin SDK / Console only
    }
  }
}
```

---

## Key Implementation Patterns

### 1. Either Pattern for Error Handling

Use `dartz` or `fpdart` for functional error handling — never throw exceptions across layers.

```dart
// failures.dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
```

```dart
// bible_repository_impl.dart
class BibleRepositoryImpl implements BibleRepository {
  final BibleRemoteDatasource remoteDatasource;
  final BibleLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  const BibleRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    if (await networkInfo.isConnected) {
      try {
        final books = await remoteDatasource.getBooks();
        await localDatasource.cacheBooks(books);
        return Right(books);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cachedBooks = await localDatasource.getCachedBooks();
        return Right(cachedBooks);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }
}
```

### 2. Audio Player Service

```dart
// audio_player_service.dart
abstract class AudioPlayerService {
  Stream<AudioPlayerState> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  Future<void> play({required String url, bool isLocal = false});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> dispose();
}

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _player;

  AudioPlayerServiceImpl() : _player = AudioPlayer();

  @override
  Future<void> play({required String url, bool isLocal = false}) async {
    if (isLocal) {
      await _player.setFilePath(url);
    } else {
      await _player.setUrl(url);
    }
    await _player.play();
  }

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  // ... remaining implementation
}
```

### 3. Bloc Pattern

```dart
// bible_bloc.dart
class BibleBloc extends Bloc<BibleEvent, BibleState> {
  final GetBooks getBooks;
  final GetVerses getVerses;
  final SearchBible searchBible;

  BibleBloc({
    required this.getBooks,
    required this.getVerses,
    required this.searchBible,
  }) : super(BibleInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<LoadVersesEvent>(_onLoadVerses);
    on<SearchBibleEvent>(_onSearchBible);
  }

  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BibleState> emit,
  ) async {
    emit(BibleLoading());
    final result = await getBooks(NoParams());
    result.fold(
      (failure) => emit(BibleError(failure.message)),
      (books) => emit(BooksLoaded(books)),
    );
  }

  Future<void> _onLoadVerses(
    LoadVersesEvent event,
    Emitter<BibleState> emit,
  ) async {
    emit(BibleLoading());
    final result = await getVerses(
      GetVersesParams(bookId: event.bookId, chapter: event.chapter),
    );
    result.fold(
      (failure) => emit(BibleError(failure.message)),
      (verses) => emit(VersesLoaded(verses)),
    );
  }
}
```

### 4. Language Switcher

```dart
// language.dart (entity)
class Language {
  final String id;              // e.g., "my_burmese", "kachin_jinghpaw"
  final String name;            // Display name in own script
  final String nameEn;          // English display name
  final String languageCode;    // ISO 639-1
  final String script;          // "myanmar" | "latin" | "shan" | "karen" | "kayah_li"
  final String fontFamily;      // Recommended font
  final bool hasAudio;

  const Language({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.languageCode,
    required this.script,
    required this.fontFamily,
    required this.hasAudio,
  });
}
```

```dart
// language_cubit.dart
class LanguageCubit extends Cubit<LanguageState> {
  final GetLanguages getLanguages;
  final GetActiveLanguage getActiveLanguage;
  final SetActiveLanguage setActiveLanguage;

  LanguageCubit({
    required this.getLanguages,
    required this.getActiveLanguage,
    required this.setActiveLanguage,
  }) : super(LanguageInitial());

  Future<void> loadLanguages() async {
    emit(LanguageLoading());
    final result = await getLanguages(NoParams());
    final active = await getActiveLanguage(NoParams());
    result.fold(
      (failure) => emit(LanguageError(failure.message)),
      (languages) => emit(LanguagesLoaded(
        languages: languages,
        active: active.getOrElse(() => languages.first),
      )),
    );
  }

  Future<void> switchLanguage(Language language) async {
    await setActiveLanguage(SetActiveParams(languageId: language.id));
    // Re-emit with new active language — BibleBloc listens and reloads
    final currentState = state;
    if (currentState is LanguagesLoaded) {
      emit(currentState.copyWith(active: language));
    }
  }
}
```

---

## Multi-Script Font & Text Handling

> [!IMPORTANT]
> The app supports multiple scripts. Each language specifies its required `fontFamily` in Firestore. The app must resolve the correct font at runtime based on the active language's `script` field.

### Supported Scripts & Fonts

| Script       | Font Family   | Line Height | Notes                              |
| ------------ | ------------- | ----------- | ---------------------------------- |
| Myanmar      | Padauk        | 1.8         | Burmese — needs generous spacing   |
| Latin        | Inter         | 1.5         | Kachin, Chin — standard Latin      |
| Shan         | Panglong      | 1.7         | Shan script variant                |
| Karen        | Karen Unicode | 1.7         | Sgaw/Pwo Karen                     |
| Kayah Li     | Kayah Li      | 1.6         | Red Karen                          |

```dart
// app_typography.dart
class AppTypography {
  /// Returns the correct TextStyle based on the active language's script.
  static TextStyle verseText({
    required String script,
    required String fontFamily,
    double fontSize = 18,
  }) {
    final height = _lineHeightForScript(script);
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: height,
      letterSpacing: script == 'latin' ? 0.0 : 0.3,
    );
  }

  static TextStyle bookTitle({
    required String script,
    required String fontFamily,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: _lineHeightForScript(script) - 0.2,
  );

  static double _lineHeightForScript(String script) => switch (script) {
    'myanmar' => 1.8,
    'shan'    => 1.7,
    'karen'   => 1.7,
    'kayah_li' => 1.6,
    _         => 1.5,  // latin and others
  };
}
```

**In `pubspec.yaml`:**

```yaml
flutter:
  fonts:
    - family: Padauk
      fonts:
        - asset: assets/fonts/Padauk-Regular.ttf
        - asset: assets/fonts/Padauk-Bold.ttf
          weight: 700
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
    - family: Panglong
      fonts:
        - asset: assets/fonts/Panglong-Regular.ttf
    - family: KarenUnicode
      fonts:
        - asset: assets/fonts/KarenUnicode-Regular.ttf
    - family: KayahLi
      fonts:
        - asset: assets/fonts/KayahLi-Regular.ttf
```

> [!TIP]
> When a language's `fontFamily` from Firestore doesn't match any bundled font, fall back to the system default. This allows adding new languages without an app update if the device already has the font.

---

## Testing Strategy

### Unit Tests

Test **every UseCase** and **Repository** in isolation.

```dart
// get_books_test.dart
void main() {
  late GetBooks usecase;
  late MockBibleRepository mockRepository;

  setUp(() {
    mockRepository = MockBibleRepository();
    usecase = GetBooks(mockRepository);
  });

  test('should get list of books from repository', () async {
    // Arrange
    final books = [
      const Book(
        id: 'genesis',
        name: 'ကမ္ဘာဦးကျမ်း',
        nameEn: 'Genesis',
        totalChapters: 50,
        testament: BibleTestament.old,
      ),
    ];
    when(mockRepository.getBooks())
        .thenAnswer((_) async => Right(books));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, Right(books));
    verify(mockRepository.getBooks());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### Bloc Tests

```dart
// bible_bloc_test.dart
void main() {
  late BibleBloc bloc;
  late MockGetBooks mockGetBooks;

  setUp(() {
    mockGetBooks = MockGetBooks();
    bloc = BibleBloc(getBooks: mockGetBooks, /* ... */);
  });

  blocTest<BibleBloc, BibleState>(
    'emits [BibleLoading, BooksLoaded] when LoadBooksEvent succeeds',
    build: () {
      when(mockGetBooks(any))
          .thenAnswer((_) async => Right(testBooks));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadBooksEvent()),
    expect: () => [BibleLoading(), BooksLoaded(testBooks)],
  );
}
```

### Integration Tests

```dart
// app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigate from book list to chapter to verses', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap on Genesis
    await tester.tap(find.text('ကမ္ဘာဦးကျမ်း'));
    await tester.pumpAndSettle();

    // Tap on Chapter 1
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    // Verify verse text is visible
    expect(find.textContaining('အစအဦး၌'), findsOneWidget);
  });
}
```

---

## Production Readiness Checklist

### Performance
- [ ] Paginate Firestore queries (load 1 chapter at a time, not all verses)
- [ ] Cache Bible text locally after first load (offline-first)
- [ ] Use `const` constructors everywhere possible
- [ ] Lazy-load audio URLs (fetch only when user taps play)
- [ ] Compress audio files to 64kbps AAC/MP3 for efficient streaming
- [ ] Use `CachedNetworkImage` for any images

### Offline Support
- [ ] Cache all Bible text in Hive/Isar after first sync
- [ ] Allow downloading audio chapters for offline playback
- [ ] Track download progress with `StreamController`
- [ ] Show clear online/offline indicator in UI

### Security
- [ ] Firestore security rules reviewed and tested
- [ ] Storage security rules reviewed and tested
- [ ] No API keys in source code (use `--dart-define` or `.env`)
- [ ] Enable Firebase App Check for production

### Accessibility
- [ ] Support dynamic font sizes (user preference + system)
- [ ] Ensure contrast ratios meet WCAG AA for Myanmar text
- [ ] Add `Semantics` widgets for screen readers
- [ ] Test with TalkBack (Android) and VoiceOver (iOS)

### Analytics & Monitoring
- [ ] Firebase Analytics for screen views and events
- [ ] Firebase Crashlytics for crash reporting
- [ ] Firebase Performance Monitoring
- [ ] Log audio playback events (book, chapter, duration listened)

### CI/CD
- [ ] GitHub Actions / Codemagic pipeline
- [ ] Run `dart analyze` on every PR
- [ ] Run unit + widget tests on every PR
- [ ] Build APK/IPA on merge to main
- [ ] Automated deployment to Firebase App Distribution (beta)
- [ ] Automated deployment to Play Store / App Store (release)

### Code Quality
- [ ] `analysis_options.yaml` with strict lints enabled
- [ ] No `print()` statements — use `Logger` package
- [ ] All public APIs documented with `///` doc comments
- [ ] Consistent naming: `snake_case` files, `PascalCase` classes, `camelCase` methods

---

## Key Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^9.0.0
  equatable: ^2.0.7

  # Dependency Injection
  get_it: ^8.0.0
  injectable: ^2.5.0

  # Navigation
  go_router: ^15.0.0

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0
  firebase_app_check: ^0.3.0

  # Audio
  just_audio: ^0.9.40
  audio_service: ^0.18.15

  # Local Storage
  hive_flutter: ^1.1.0

  # Functional Programming
  dartz: ^0.10.1

  # Network
  connectivity_plus: ^6.0.0

  # Localization
  intl: ^0.18.1
  flutter_localizations:
    sdk: flutter

  # Sharing & Images
  share_plus: ^7.1.0
  path_provider: ^2.1.1
  screenshot: ^2.1.1              # For verse image generation

  # UI
  shimmer: ^3.0.0             # Loading skeletons
  cached_network_image: ^3.4.0
  dynamic_color: ^1.7.0           # M3 dynamic color (Android 12+)

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^10.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
  injectable_generator: ^2.6.0
  flutter_lints: ^5.0.0
  integration_test:
    sdk: flutter
```

---

## Step-by-Step Build Order

> [!TIP]
> Follow this order to build incrementally, testing each layer before moving on.

1. **Project setup** — `flutter create`, add dependencies, configure Firebase (Crashlytics, Analytics), l10n setup
2. **Core layer** — Theme, constants, error types, DI container, network info
3. **Language & UI Localization** — Language entity, active language management, App UI translation (`intl`)
4. **Bible domain** — Entities (with `languageId`), repository interfaces, use cases
5. **Bible data** — Firestore datasource, models, repository impl
6. **Bible presentation** — Bloc, book list page, chapter grid, verse reader, last read persistence
7. **Audio domain** — Audio track entity, repository interface, `audio_service` (background/lock screen)
8. **Audio data** — Firebase Storage datasource, download manager
9. **Audio presentation** — Player bloc, controls widget, mini player
10. **Study (Bookmarks/Highlights/Notes)** — Full CRUD with Firestore sync (includes color codes & text)
11. **Share Feature** — Verse text sharing and image generation (`screenshot`, `share_plus`)
12. **Search** — Full-text search across verses (within active language)
13. **Settings** — Font size, theme, playback speed, active language persistence
14. **Offline mode** — Local caching, download management
15. **Auth** — Optional sign-in for cross-device sync
16. **Polish** — Animations, loading skeletons, error states
17. **Testing** — Unit, widget, integration, and manual QA
18. **CI/CD** — Automated build, test, deploy pipeline
19. **Release** — Play Store & App Store submission

---

## Naming Conventions

| Element         | Convention     | Example                        |
| --------------- | -------------- | ------------------------------ |
| Files           | `snake_case`   | `bible_repository_impl.dart`   |
| Classes         | `PascalCase`   | `BibleRepositoryImpl`          |
| Methods/Vars    | `camelCase`    | `getVerses`, `bookList`        |
| Constants       | `camelCase`    | `defaultFontSize`              |
| Enums           | `PascalCase`   | `BibleTestament.old`           |
| BLoC Events     | `PascalCase`   | `LoadBooksEvent`               |
| BLoC States     | `PascalCase`   | `BooksLoaded`                  |
| Private members | `_camelCase`   | `_player`, `_cacheBooks`       |
| Test files      | `*_test.dart`  | `get_books_test.dart`          |

---

## Summary

This guide ensures the Myanmar Bible Audio app is:

- **Multi-language** — Supports Burmese, Kachin, Chin, Shan, Karen, and more via a language-first architecture
- **Maintainable** — Clean Architecture separates concerns across layers
- **Scalable** — Add new languages by uploading data to Firestore + Storage — no code changes needed
- **Testable** — Every layer is independently testable via dependency injection
- **Production-ready** — Offline support, analytics, crash reporting, CI/CD
- **Performant** — Lazy loading, caching, efficient audio streaming
- **Accessible** — Multi-script font support, dynamic sizing, screen reader ready
