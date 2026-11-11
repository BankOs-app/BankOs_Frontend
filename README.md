# BankOS Frontend

A modern, responsive, and secure digital banking mobile and web application built with **Flutter** and **Material 3**.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Step-by-Step Execution Guide](#step-by-step-execution-guide)
  - [1. Web (Google Chrome)](#1-web-google-chrome)
  - [2. Android Emulator](#2-android-emulator)
  - [3. Physical Android Device](#3-physical-android-device)
- [Testing & Code Quality](#testing--code-quality)
- [Building for Production](#building-for-production)
- [Project Directory Structure](#project-directory-structure)
- [Common Troubleshooting](#common-troubleshooting)
- [License](#license)

---

## Overview

**BankOS Frontend** is the client application for the BankOS financial ecosystem. It provides users with a clean, intuitive banking experience to manage accounts, monitor balances, perform transfers, and review transaction histories with real-time feedback.

---

## Key Features

- **Modern Material 3 Interface:** Premium slate and navy blue color scheme designed specifically for financial applications.
- **Interactive Balance Card:** View total balance with a privacy toggle (`••••••••` / `\$12,450,000 COP`).
- **Quick Action Hub:** Instant access to core banking operations:
  - **Transfer:** P2P and interbank transfers.
  - **Receive:** Display account details and payment requests.
  - **Bills:** Public and private utility payments.
  - **More:** Extended banking services and configuration.
- **Recent Activity Feed:** Color-coded transaction statements with real-time amounts and status indicators.
- **Cross-Platform:** Single codebase running natively on Android and Modern Web browsers.

---

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Channel stable, >= 3.13)
- **Language:** [Dart](https://dart.dev/)
- **Design System:** Material Design 3
- **Testing:** `flutter_test` (Unit and Widget smoke tests)

---

## Prerequisites

Before running the project, verify that your development environment is properly set up:

1. **Flutter SDK:** Version `3.13` or higher.
   ```bash
   flutter --version
   ```
2. **Android Development:**
   - **Android Studio** (or VS Code with Flutter extension).
   - **Android SDK** (API Level 34+ recommended).
   - **Android SDK Command-line Tools** (installed via *Android Studio > Settings > Languages & Frameworks > Android SDK > SDK Tools*).
3. **Web Development:**
   - **Google Chrome** browser.
4. **Environment Health Check:**
   Run `flutter doctor` to ensure all necessary tools are detected:
   ```bash
   flutter doctor
   ```

---

## Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/BankOs_Frontend.git
   cd BankOs_Frontend
   ```

2. **Configure environment variables:**
   Copy the example environment configuration to create your local `.env`:
   ```bash
   # On Windows PowerShell
   Copy-Item .env.example .env

   # On Linux/macOS
   cp .env.example .env
   ```
   Edit `.env` to configure your backend API endpoint:
   ```env
   API_BASE_URL=http://localhost:3000/api/v1
   APP_ENVIRONMENT=development
   ```

3. **Install dependencies:**
   Fetch all Dart packages specified in `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

---

## Step-by-Step Execution Guide

### 1. Web (Google Chrome)
Running in Chrome is the fastest way to preview and debug the application without starting a mobile emulator:

```bash
flutter run -d chrome
```

For hot reload, press `r` in the terminal after saving changes. Press `R` for a hot restart.

---

### 2. Android Emulator

1. **List available emulators:**
   ```bash
   flutter emulators
   ```

2. **Launch your emulator:**
   Replace `<emulator_id>` with the name of your configured AVD (e.g., `Medium_Phone_API_37.0`):
   ```bash
   flutter emulators --launch Medium_Phone_API_37.0
   ```

3. **Run the app on the emulator:**
   ```bash
   flutter run
   ```

---

### 3. Physical Android Device

1. Connect your Android device via USB.
2. Enable **Developer Options** and **USB Debugging** on the device.
3. Verify Flutter detects the device:
   ```bash
   flutter devices
   ```
4. Run the app:
   ```bash
   flutter run -d <device_id>
   ```

---

## Testing & Code Quality

### Run Unit and Widget Tests
Execute all automated test suites:
```bash
flutter test
```

### Static Analysis
Analyze Dart source code for syntax warnings and best practice adherence:
```bash
flutter analyze
```

---

## Building for Production

### Android APK
Generates a standalone release APK file:
```bash
flutter build apk --release
```
*Output location:* `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (AAB)
Generates an optimized App Bundle ready for Google Play Store upload:
```bash
flutter build appbundle --release
```
*Output location:* `build/app/outputs/bundle/release/app-release.aab`

### Web Release
Compiles optimized static assets for hosting on any web server:
```bash
flutter build web --release
```
*Output location:* `build/web/`

---

## Project Directory Structure

```text
BankOs_Frontend/
├── .env.example              # Sample environment configuration
├── analysis_options.yaml      # Static analysis lint rules
├── android/                   # Native Android host configuration
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   └── build.gradle.kts
├── lib/
│   └── main.dart              # Main application entry point & BankOS home screen
├── pubspec.yaml               # Flutter package definitions & dependencies
├── test/
│   └── widget_test.dart       # Widget and smoke tests
└── web/                       # Web entry files (index.html, manifest, icons)
```

---

## Common Troubleshooting

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| `cmdline-tools component is missing` | Android SDK Command-line Tools not installed | Open **Android Studio > Settings > Android SDK > SDK Tools**, check **Android SDK Command-line Tools (latest)** and click **Apply**. |
| `Visual Studio not installed` warning | Flutter checking for C++ desktop compiler | If only developing for Mobile/Web, disable Windows desktop target via: <br>`flutter config --no-enable-windows-desktop` |
| `Waiting for another flutter command to release the lock` | Stale Flutter process running | Terminate hanging Dart processes or delete `bin/cache/lockfile` inside your Flutter SDK folder. |
| Build fails after dependency upgrade | Stale build artifacts or Gradle cache | Run: <br>`flutter clean`<br>`flutter pub get` |

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.
