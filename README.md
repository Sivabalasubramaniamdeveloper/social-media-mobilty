# MineAI — All-in-One Personal AI Productivity Hub 🚀

> **Version**: 1.0.0 (First Official Release)  
> **Platform**: Flutter (Android & iOS)  
> **Architecture**: BLoC / Cubit Pattern + Clean Architecture  
> **Backend**: Node.js, Express, Cheerio, RSS XML Parser, Supabase Auth & PostgreSQL  

---

## 🌟 Overview

**MineAI** is an advanced, privacy-first mobile productivity super-app designed to streamline your daily workflow. It brings together cutting-edge AI assistance, automated live price comparison, localized city news with real-time editorial photos, encrypted personal journaling, offline secure vault, intelligent expense tracking, and curated media streaming into a single, cohesive experience.

---

## ✨ Key Features

### 🎙️ 1. AI Voice & Speech Task Extraction
- Converts voice notes into structured, scheduled tasks with automatic priority, category, and date/time recognition.
- Quick save or AI analysis mode with real-time token tracking.
- Local offline task storage backed by SQLite with cloud sync capabilities.

### 📰 2. Curated City News Web Scraper
- Multi-provider live city RSS feeds from **The Hindu** and **Times of India**.
- Strict city-boundary filtering guaranteeing news only for the selected city (Chennai, Bengaluru, Mumbai, Delhi, Hyderabad, Kolkata, Coimbatore, Madurai).
- Editorial image extraction with topic-matched high-definition photography.
- Instant article sharing, in-app browser launching, and publisher filter chips.

### 🛍️ 3. Real-Time Multi-Store Price Comparison
- Scrapes and aggregates product prices across **Amazon**, **Flipkart**, and **Meesho**.
- Automatic best deal detection with savings difference calculations and direct affiliate/store deep links.
- Interactive deal cards, availability indicators, and ratings.

### ✉️ 4. AI Email Assistant
- Drafts polished, tone-adjusted emails (Professional, Casual, Friendly, Urgent).
- Save generated templates under custom labels.
- Integrated direct mail dispatch via custom Gmail App Passwords and SMTP.

### 🔒 5. Encrypted Private Vault
- Secure biometric-protected storage for passwords, confidential documents, and photos.
- AES-256 and platform Secure Storage encryption.
- One-tap password copy and credential reveal toggles.

### 📖 6. Personal Diary & Mood Celebrator
- Daily multimedia journal entries with mood scores, photo attachments, and audio recordings.
- Dynamic "Mood Vibe" poster generator with social sharing capabilities.

### 💰 7. Expense & Budget Tracker
- Categorized spending logs with monthly budget limit bars and savings goals.
- Offline SQLite transaction storage with Excel (.xlsx) and PDF export capabilities.

### 🎬 8. MineAI Streams (OTT Video Hub)
- Curated video player supporting HLS adaptive multi-bitrate streaming (Auto, 720p, 480p, 360p).
- Playback speed adjustment (0.5x to 2.0x), aspect ratio toggles, and gesture-driven seeking.

---

## 🌍 Localization & Accessibility

- **Languages Supported**: English (`en`) and Tamil (`ta`).
- **Standard Fixed Typography**: Configured with a clamped text scaler (`TextScaler.linear(1.0)`) guaranteeing zero layout overflow across all accessibility display settings.
- **Dynamic Theming**: Multiple color modes (Deep Dark, Pure Light, Natural, Orange, White-Blue).

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology |
| :--- | :--- |
| **Framework** | Flutter 3.29+ / Dart 3.8+ |
| **State Management** | `flutter_bloc` / Cubit |
| **Routing** | `go_router` with custom cubic page transitions |
| **Networking** | `dio` with Alice HTTP inspector & interceptors |
| **Localization** | `easy_localization` |
| **Authentication** | Supabase Auth (`supabase_flutter`) |
| **Local Databases** | SQLite (`sqflite`), `flutter_secure_storage` |
| **Media & Audio** | `video_player`, `speech_to_text`, `image_picker` |
| **UI Polish** | `shimmer`, `flutter_screenutil`, `share_plus` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.8.0`
- Android Studio / Xcode
- Node.js `18+` (for Backend services)

### 1. Environment Setup
Create a `.env` file in `flutter frontend/`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
BACKEND_BASE_URL=https://your-backend-api.app/api/v1
```

### 2. Install Dependencies & Run
```bash
# In flutter frontend
flutter pub get
flutter run --flavor dev -t lib/main.dart
```

### 3. Build for Google Play Store (Production)
```bash
flutter clean
flutter pub get
flutter build appbundle --flavor prod -t lib/main.dart --release
```

---

## 📄 License & Compliance
This software is distributed under the proprietary license of MineAI.  
For privacy practices and user terms, see [PRIVACY_POLICY.md](file:///Users/priyajayakumar/Documents/test_images/flutter%20frontend/PRIVACY_POLICY.md) and [TERMS_AND_CONDITIONS.md](file:///Users/priyajayakumar/Documents/test_images/flutter%20frontend/TERMS_AND_CONDITIONS.md).
