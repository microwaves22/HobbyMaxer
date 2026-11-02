# HomeSync Frontend

Flutter UI for the HomeSync family organization app.

## Run

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```powershell
cd homesync-frontend
flutter pub get
flutter run
```

Analyze and test:

```powershell
flutter analyze
flutter test
```

## Layout

```text
homesync-frontend/
  lib/
    main.dart                 # app entrypoint (light + Teen Mode dark theme)
    core/theme/               # app_colors, app_typography, app_theme
    core/widgets/             # liquid_glass_card, profile_avatar_dropdown
    views/onboarding/         # splash, welcome, focus areas, family setup
    views/home/               # minimal post-onboarding landing
```

## Flow

Splash → Welcome ([Get Started]) → Focus Areas ([Next], ≥1 tag) →
Family Setup ([Add Member], [Done]/[Later]) → Home.

The backend lives in `../homesync-backend/` (FastAPI). API wiring
(login/register, family sync) is the next step after this UI scaffold.
