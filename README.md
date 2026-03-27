# ፍኖተ ያሬድ - Finote Yared

An Ethiopian Orthodox Sunday school hymn application (Mezmur Application) built with Flutter.

## 🎵 App Description
A comprehensive digital hymnal for Sunday school at Finote Selam church, containing over 5,000 Ethiopian Orthodox hymns organized by categories.

## 🚀 Features
- Browse hymns by categories (የዐውደ ዓመት, ዋይነ ግብረ ሰም, ወዘተ)
- Search functionality for hymns
- Favorites system
- Audio playback support
- Dark/Light theme options
- Text size adjustment
- Admin dashboard for content management

## 🛠️ Prerequisites
- Flutter SDK (3.7.0 or higher)
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

## 📦 Installation

1. **Clone the repository:**
```bash
git clone <your-repo-url>
cd Finote-yared
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the application:**
```bash
flutter run
```

4. **Build for release:**
```bash
# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# Android APK
flutter build apk --release --split-per-abi
```

## 🏗️ Project Structure
```
lib/
├── constants/          # App constants
├── data/              # Static data files
├── models/            # Data models
├── providers/         # State management providers
├── screens/           # UI screens
├── services/          # App services
├── utils/             # Utility functions
├── widgets/           # Reusable widgets
├── main.dart          # App entry point
└── ...                # Other core files
```

## 🎨 Customization
- **Themes**: Adjust colors and themes via `AppSettingsProvider`
- **Content**: Add/modify hymns via the admin panel
- **Assets**: Images and audio files in `assets/` folder

## 📱 Production Notes
- Version: 2.1.1
- Package name: `org.finot.zema_finot`
- The app bundle includes native code for audio playback and SQLite database operations
- For Play Store, upload both the AAB and native debug symbols

## 🔐 Admin Access
- Default credentials: `finotit` / `sibhatefinot29`
- Access admin panel via Settings > Admin Login

## 📁 Assets
- Hymn lyrics in `assets/songs.json`
- Images in `assets/images/`
- Audio files in `assets/audios/`

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License
This project is open source and available under the MIT License.

## ⚠️ Notes
- This app is specifically designed for the Ethiopian Orthodox community
- Contains culturally and religiously significant content
- Designed with accessibility in mind for various user needs