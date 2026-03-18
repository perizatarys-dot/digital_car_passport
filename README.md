# Digital Car Passport 🚗

> **One app. Every data source. Instant trust.**
> Kazakhstan's trusted used-car history app — Flutter · 2026

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on device / emulator
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## Project Structure

```
digital_car_passport/
├── lib/
│   ├── main.dart                         ← Entry point
│   ├── router/
│   │   └── app_router.dart               ← GoRouter (all routes)
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── main_shell.dart               ← ★ Bottom nav (single source of truth)
│   │   ├── home_screen.dart
│   │   ├── search_screen.dart
│   │   ├── saved_reports_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── vin_search_screen.dart
│   │   ├── report_screen.dart            ← Full tabbed report
│   │   ├── price_estimate_screen.dart
│   │   ├── fines_check_screen.dart
│   │   ├── history_screen.dart
│   │   ├── pricing_screen.dart
│   │   ├── settings_screen.dart
│   │   └── b2b_partner_screen.dart
│   ├── widgets/
│   │   ├── cards/
│   │   │   └── report_card.dart
│   │   └── common/
│   │       ├── score_pill.dart
│   │       └── section_label.dart
│   ├── models/
│   │   └── car_report.dart               ← All domain models
│   ├── services/
│   │   ├── car_service.dart              ← API + VIN validation
│   │   └── mock_data.dart                ← Realistic KZ mock data
│   ├── theme/
│   │   ├── app_colors.dart               ← Brand palette
│   │   ├── app_text_styles.dart          ← Syne + DM Sans
│   │   ├── app_spacing.dart              ← Spacing + radius constants
│   │   └── app_theme.dart                ← MaterialApp theme
│   └── utils/
│       └── formatters.dart               ← KZT, km, date helpers
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

---

## Navigation

The bottom navigation bar is defined **once** in `main_shell.dart` using a `ShellRoute` in GoRouter. All 4 tabs share identical styling. Stack screens (Report, Fines, Price, etc.) are outside the shell — they have no bottom nav bar, only a back button.

## Pricing (KZT)

| Plan             | Price         |
|------------------|---------------|
| Single Report    | 2,000 ₸       |
| Dealership Basic | 20,000 ₸/month |
| Dealership Pro   | 50,000 ₸/month |
| B2B API          | Custom        |

## Languages
Kazakh · Russian (default) · English

## Privacy First
All personal data of previous owners is intentionally hidden. Only vehicle facts are shown.
