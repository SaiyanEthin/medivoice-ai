# MediVoice AI - Flutter App

## This milestone: Home Screen only

What's actually implemented:
- `lib/main.dart` - app entry point, wires Provider + theme + routes
- `lib/core/theme/app_theme.dart` - centralized colors/text styles/button styles
- `lib/core/config.dart` - API URL, confidence threshold, follow-up round cap (matches backend)
- `lib/core/routes/app_routes.dart` - route table (only 'home' registered so far)
- `lib/screens/home_screen.dart` - the actual Home Screen UI
- `lib/screens/placeholder_screen.dart` - generic "coming soon" screen so Home's
  navigation buttons don't crash before Voice Input / About are built

What's a SKELETON only (folders exist, not yet implemented):
- `widgets/`, `models/`, `services/`, `repositories/` - empty except `.gitkeep`
- `lib/providers/consultation_provider.dart` - bare class, real fields/methods
  come with the Voice Input + Symptom Confirmation screens (next milestones)

## Running this

You'll need the Flutter SDK installed (this code was NOT compiled/tested in
this environment - verify it builds in your own Android Studio/VS Code setup).

```bash
cd mobile
flutter pub get
flutter run
```

Make sure your FastAPI backend (`../backend`) is running locally first:
```bash
cd ../backend
uvicorn main:app --reload
```
The app points to `http://10.0.2.2:8000` by default (Android emulator's alias
for your machine's localhost) - see `lib/core/config.dart` to change this.

## Honest note on the "works fully offline" text on Home Screen

The Home Screen currently says the app works offline and never sends data
to the internet - that's the FINAL product's design goal, but during this
development phase it's calling your local FastAPI backend over HTTP, which
is NOT actually offline. Keep this in mind for any live demo before the
offline conversion milestone is done - don't let a professor test it with
WiFi off yet.

## Next milestones (build one at a time, review each before continuing)
1. Voice Input Screen
2. Symptom Confirmation Screen (Yes/No follow-ups)
3. Prediction Result Screen
4. Advice Screen
5. Doctor List Screen
6. About Screen
7. Wire up `ApiService` + `ConsultationRepository` + real `ConsultationProvider` state
8. Whisper-Tiny integration
9. Offline conversion
