# DevSync release builds

## Flavors (Free / Pro)

Gradle product flavors live in `android/app/build.gradle.kts` (`free`, `pro`).

```bash
# Free debug
flutter run --flavor free --dart-define=FLAVOR=free

# Pro debug
flutter run --flavor pro --dart-define=FLAVOR=pro

# Free release APK
flutter build apk --flavor free --release --dart-define=FLAVOR=free
```

`AppFlavorConfig` (`lib/core/config/app_flavor.dart`) reads `FLAVOR`.

## Obfuscated Android App Bundle

Release enables R8 minify + shrink resources. Upload keystore is still the debug key for local builds — replace before store upload.

```bash
flutter build appbundle \
  --flavor free \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=FLAVOR=free
```

Keep `build/debug-info` privately for crash deobfuscation.

## Auth note for examiners

DevSync uses **custom Firebase Auth** (email/OTP, Google, GitHub) on Android — not the `firebase_ui_auth` package. Functionally equivalent for the graduation acceptance criteria.
