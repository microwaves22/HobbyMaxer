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
    core/network/             # api_client, auth_session, token_store
    core/widgets/             # liquid_glass_card, profile_avatar_dropdown,
                            # home_title (tap-to-home AppBar title)
    core/state/               # focus_areas provider (dashboard visibility)
    views/auth/               # backend login (POST /auth/login + /auth/me)
    views/onboarding/         # splash, welcome, profile setup,
                            # choose mode, family setup, focus areas
    views/home/               # dashboard (feature cards, parent review queue)
    views/tasks/              # task list, submission sheet, review queue
    views/rewards/            # reward store, redemption, perk requests
```

## Flow

Splash → Welcome ([Get Started] / [Login]) →
Profile Setup (email, password, name, birthday, Parent/Kid, Kids/Teens/Parent mode) →
Home.

The focus-area picker lives in the family-setup flow (`choose_mode_screen`
→ `family_setup_screen` → `focus_areas_screen`); Welcome [Get Started] and
login skip it and enable all areas by default via `FocusAreasScope`.
Switching to a parent profile asks for the Parent PIN (demo default `1234`;
wire to `POST /auth/switch-profile` later).

## Tasks & photo evidence

Children open the Chores card → tap a task → attach a photo (camera or
gallery via `image_picker`) → preview → Submit for review. Parents see a
review queue on the dashboard with zoomable photo previews, per-task
[Approve & Award Points] / [Request Changes] per task (Request Changes opens
a feedback popup for points/detail/photo edits plus a note the child sees on retry), and an [Approve All Simple Tasks] batch action for no-photo tasks. Points chips and parent task rows open the same chore editor.

Tasks live in an in-memory `TasksController` seeded per profile; wire to
the backend (`POST /tasks/{id}/submit`, `PUT /tasks/{id}/approve`) later.

`image_picker` platform setup (when building for devices):

- Android: add `<uses-permission android:name="android.permission.CAMERA"/>`
  to `android/app/src/main/AndroidManifest.xml` for camera capture.
- iOS: add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`
  to `ios/Runner/Info.plist`.

## Reward store

The Rewards dashboard card opens a store with Digital Rewards and Parent
Perks tabs, a live points balance header, and per-reward redeem buttons
(disabled with a "Need N more" label when funds are short). Redemption
deducts via `TasksController` (one shared balance), logs a
`RedemptionRecord`, and raises a `PerkRequest` card on the parent
dashboard for real-world fulfillment. Parents add perks from the Perks
tab. Wire to the backend (`/rewards/...`, `/rewards/ledger/me`) later.

## Backend sync

`lib/core/network/` holds the API layer against `http://localhost:8000`
(`ApiClient` with JWT injection, `AuthSession` + secure token store,
`TasksApi`). Login posts the OAuth2 form to `/auth/login`, fetches
`/auth/me`, and persists the JWT in the OS keychain; the dashboard then
syncs tasks/balances and submit/review hit the API (`POST
/tasks/{id}/submit` multipart, `PUT /tasks/{id}/approve`). Without a
login the app runs fully local on demo seeds. Android emulators must use
`http://10.0.2.2:8000` (see `kDefaultBaseUrl`). Server evidence photos
are not downloadable (the API serves no photo route), so synced review
cards show an "Evidence stored on server" placeholder.

## Navigation, Parent PIN & parent to-dos

- Tapping any AppBar title (`HomeTitle`) pops back to the dashboard root.
- The profile switcher PIN-gates moves from a child/teen profile to a
  parent one (demo PIN `1234`, storable via `AuthSession.setParentPin`).
- The profile menu's Account settings page (all roles) shows account
  info plus Customization, Link your kids (share the invite code),
  Join a family circle (link with a code), and Sign out. Circle
  joining is local-only until the backend adds invite codes.
- Parents get a "Parent To-Do" dashboard section (add, edit, complete,
  delete, reorder) backed by `ChoreTask.isParentTodo`. To-dos are
  local-only for now; syncing them to the backend is a future step
  (like rewards redemption, which still uses the local ledger).

The backend lives in `../homesync-backend/` (FastAPI). API wiring
(login/register, family sync) is the next step after this UI scaffold.
