# 📔 Flutter Journal App

A modern, secure, and elegant Flutter-based journal application that allows users to write, manage, and reflect on their daily thoughts. The app supports offline storage, favorites, inspirational quotes, authentication, and customizable settings.

---

## ✨ Features

* 📝 **Create, Edit & Delete Journal Entries** - Full CRUD operations with validation
* ⭐ **Mark Entries as Favorites** - Quick access to your most important thoughts
* 🔍 **View Entries with Smooth Animations** - Beautiful transitions and engaging UX
* 💬 **Inspirational Quotes System** - Daily motivational quotes from ZenQuotes API
* ❤️ **Favorite Quotes** - Save and revisit your favorite inspirational quotes
* 🔐 **Local User Authentication** - Secure login dialog with password hashing
* ⚙️ **Customizable Settings** - Dark mode, data management, and preferences
* 🌙 **Persistent Preferences** - Your settings are saved across sessions
* 📦 **Offline Data Storage** - Full offline support with local database
* 🚀 **Splash Screen & Login Flow** - Smooth onboarding experience

---

## 📱 Screens Overview

| Screen | Description |
|--------|-------------|
| **Splash Screen** | App launch animation and initialization |
| **Main Screen** | Bottom navigation with 3 tabs (Home, Favorites, Quotes) |
| **Home Screen** | Displays journal entries and quote of the day |
| **Add/Edit Entry** | Create or update journal entries with login dialog |
| **View Entry** | Read, edit, or delete a journal entry |
| **Favorite Entries** | View all starred journal entries |
| **Favorite Quotes** | View saved inspirational quotes |
| **Settings** | Manage app preferences and theme |

---

## 🧱 Project Structure

```
lib/
├── models/
│   ├── journal_entry.dart      # Journal entry data model
│   ├── quote.dart              # Quote data model
│   └── user.dart               # User profile model
│
├── helpers/
│   ├── database_helper.dart    # SQLite database manager
│   ├── hive_helper.dart        # Hive cache manager
│   ├── preferences_helper.dart # SharedPreferences manager
│   └── user_helper.dart        # User authentication helper
│
├── services/
│   └── quote_service.dart      # API integration for quotes
│
├── screens/
│   ├── splash_screen.dart              # Animated splash screen
│   ├── main_screen.dart                # Bottom navigation container
│   ├── home_screen.dart                # Main dashboard
│   ├── add_edit_entry_screen.dart      # Entry editor
│   ├── view_entry_screen.dart          # Entry viewer
│   ├── favorites_entries_screen.dart   # Favorite entries tab
│   ├── favorites_quotes_screen.dart    # Favorite quotes tab
│   └── settings_screen.dart            # Settings page
│
├── widgets/
│   └── login_dialog.dart       # Reusable login/register dialog
│
└── main.dart                   # App entry point
```

---

## 🗄️ Data & Storage

### Storage Layers
* **SQLite** - Persistent storage for journal entries and user profiles
* **Hive** - Lightweight local storage for quote caching
* **Shared Preferences** - User settings and theme preferences
* **Fully offline-first architecture** - Works without internet connection

### Database Schema

#### `journal_entries` Table
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key, auto-increment |
| title | TEXT | Entry title |
| content | TEXT | Entry content |
| date | TEXT | Entry date (ISO format) |
| isFavorite | INTEGER | Favorite flag (0 or 1) |

#### `users` Table
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key, auto-increment |
| email | TEXT | User email (unique) |
| password | TEXT | Hashed password (SHA256) |
| name | TEXT | User display name |
| createdAt | TEXT | Account creation timestamp |

---

## 🔐 Authentication

* **Local user authentication** - No backend required
* **Password hashing** - SHA256 encryption for security
* **Login dialog** - Appears when creating new entries
* **User profiles** - Multiple users can use the same device
* **Session persistence** - Email saved for quick login
* **Email validation** - Proper format checking
* **Password validation** - Minimum 6 characters

---

## 🎨 UI & UX

* **Material Design 3** - Modern, clean interface
* **Smooth transitions** - Using `flutter_animate` package
* **Gradient backgrounds** - Vibrant and engaging visuals
* **Dark mode support** - Complete light/dark theme system
* **Google Fonts** - Poppins typography for readability
* **Responsive layouts** - Works on all screen sizes
* **Bottom navigation** - Easy access to key features
* **Empty states** - Helpful guidance when no data exists
* **Loading indicators** - Clear feedback during operations
* **Snackbar notifications** - Non-intrusive status messages

---

## 🛠️ Tech Stack

### Core Framework
* **Flutter** - Cross-platform UI framework
* **Dart** - Programming language

### Storage & Database
* **SQLite** (`sqflite: ^2.3.3+1`) - Local relational database
* **Hive** (`hive: ^2.2.3`) - Lightweight key-value storage
* **Shared Preferences** (`shared_preferences: ^2.2.3`) - Simple data persistence

### Networking & API
* **HTTP** (`http: ^1.2.1`) - API calls for quotes
* **ZenQuotes API** - Inspirational quotes provider

### UI & Animation
* **Google Fonts** (`google_fonts: ^6.2.1`) - Beautiful typography
* **Flutter Animate** (`flutter_animate: ^4.5.0`) - Smooth animations

### Utilities
* **Intl** (`intl: ^0.19.0`) - Date formatting
* **Crypto** (`crypto: ^3.0.3`) - Password hashing
* **Path** (`path: ^1.9.0`) - File path utilities

---

## 🚀 Getting Started

### Prerequisites
* **Flutter SDK** (3.0.0 or higher)
* **Dart SDK** (3.0.0 or higher)
* **Android Studio** or **VS Code** with Flutter plugins
* **Android Emulator** or **iOS Simulator**

### Platform Setup

#### Android
Add internet permission to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Update minimum SDK in `android/app/build.gradle`:
```gradle
minSdkVersion 21
```

#### iOS
Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

Then run:
```bash
cd ios && pod install
```

---

## 📖 Usage Guide

### Creating Your First Entry
1. Launch the app (splash screen appears)
2. Tap the **+** floating action button
3. **Login dialog appears** - Register or login
4. Fill in your journal entry details
5. Tap **Save** to create the entry

### Marking Favorites
* Tap the **heart icon** on any entry to mark as favorite
* Access favorites from the **Favorite Entries** tab
* Mark quotes as favorites from the quote card

### Viewing Quotes
* Daily inspirational quote appears on home screen
* Tap **refresh icon** to get a new quote
* Mark quotes as favorites for later viewing
* View all favorite quotes in **Favorite Quotes** tab

### Managing Settings
* Tap the **settings icon** in the app bar
* Toggle **dark mode** on/off
* Clear all entries (with confirmation)
* Clear quote cache
* Logout from your account

---

## 🧪 Testing

### Manual Testing Checklist
- [ ] App launches with splash screen
- [ ] Login dialog appears when creating entry
- [ ] User registration works
- [ ] User login works
- [ ] Email validation works
- [ ] Password validation works
- [ ] Entry creation works
- [ ] Entry editing works
- [ ] Entry deletion works
- [ ] Entry favoriting works
- [ ] Quote refreshing works
- [ ] Quote favoriting works
- [ ] Search functionality works
- [ ] Dark mode toggle works
- [ ] Bottom navigation works
- [ ] Favorites tabs show correct data
- [ ] Offline mode works
- [ ] Data persists after app restart

## 📂 Key Files Explained

### `lib/main.dart`
* App entry point
* Theme configuration
* Route setup
* Database initialization

### `lib/models/`
* **journal_entry.dart** - Entry data structure
* **quote.dart** - Quote data structure
* **user.dart** - User profile structure

### `lib/helpers/`
* **database_helper.dart** - SQLite operations (CRUD)
* **user_helper.dart** - User authentication logic
* **hive_helper.dart** - Quote caching logic
* **preferences_helper.dart** - Settings management

### `lib/services/`
* **quote_service.dart** - API integration for quotes

### `lib/widgets/`
* **login_dialog.dart** - Reusable authentication dialog

### `lib/screens/`
* All UI screens and their logic

---

## 🎯 Architecture

### Design Patterns Used
* **Singleton** - Database and helper instances
* **Factory** - Model object creation
* **Repository** - Data access abstraction
* **Service** - Business logic separation

### Data Flow
```
UI Layer (Screens)
    ↓
Business Logic Layer (Helpers/Services)
    ↓
Data Layer (SQLite/Hive/SharedPreferences)
```

---

## 🔧 Configuration

### API Configuration
The app uses the ZenQuotes API for inspirational quotes:
* **Endpoint**: `https://zenquotes.io/api/random`
* **Rate Limiting**: Handled by 7-day cache
* **Offline Support**: Cached quotes available

### Storage Configuration
* **SQLite Database**: `journal_entries.db` and `users.db`
* **Hive Boxes**: `quotes` and `settings`
* **Cache Duration**: 7 days for quotes

---

## 📌 Future Enhancements

### Planned Features
* ☁️ **Cloud synchronization** - Backup and sync across devices
* 🔒 **Biometric authentication** - Fingerprint/Face ID login
* 📊 **Mood analytics** - Track emotional patterns over time
* 🗓️ **Calendar-based entry view** - Visual timeline of entries
* 🌍 **Multi-language support** - Internationalization
* 🖼️ **Image attachments** - Add photos to entries
* 🏷️ **Tags and categories** - Organize entries by topics
* 📤 **Export to PDF** - Share or backup entries
* 🔔 **Reminders** - Daily journaling notifications
* 🎨 **Custom themes** - User-defined color schemes
* 📈 **Statistics** - Writing streaks and insights
* 🔍 **Advanced search** - Filter by date, tags, mood

---

## 🐛 Troubleshooting

### Common Issues

#### Issue: Dependencies not installing
```bash
flutter clean
flutter pub get
```

#### Issue: Database not initializing
Ensure initialization in `main.dart`:
```dart
await DatabaseHelper.instance.database;
await UserHelper.instance.database;
```

#### Issue: API calls failing
Check internet permission in `AndroidManifest.xml`

#### Issue: Dark theme not applying
Verify `SharedPreferences` is saving correctly

---

## 👨‍💻 Author

**Zeyad Hisham**
* Email: ziad2112008@miuegypt.edu.eg

Project Created: January 2026

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

You are free to:
* ✅ Use this project for personal or commercial purposes
* ✅ Modify and adapt the code
* ✅ Distribute copies of the software
* ✅ Include in proprietary software

Under the condition that you include the original copyright notice and license.

---

## 🙏 Acknowledgments

* **ZenQuotes.io** - For providing the inspirational quotes API
* **Flutter Team** - For the amazing framework
* **Material Design** - For design guidelines
* **Google Fonts** - For beautiful typography
* **Open Source Community** - For inspiration and support

---


## 🔗 Links

* [Flutter Documentation](https://flutter.dev/docs)
* [Dart Documentation](https://dart.dev/guides)
* [Material Design Guidelines](https://material.io/design)
* [ZenQuotes API](https://zenquotes.io/)

---

<div align="center">

**Made with ❤️ using Flutter**

</div>

---

**Last Updated:** January 2026  
**Version:** 1.0.0  
**Status:** Active Development