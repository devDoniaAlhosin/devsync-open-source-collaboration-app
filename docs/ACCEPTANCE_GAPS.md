# DevSync acceptance criteria — gaps

Scorecard against **“DevSync: Secure AI Project Collaborator”** technical acceptance text.  
Updated when FCM send + Firestore inbox landed (Vercel Admin `POST /notify`, no Cloud Functions).

## Scorecard

| Criterion | Status | Gap |
|---|---|---|
| AI matching (GitHub activity + skills) | **PASS** | End-to-end: scan → skills → `/matches/generate` → ranked deck |
| Prompt engineering (search + evaluate + optimize) | **PARTIAL** | AI Studio + like/skip → `feedbacks` + quality charts exist; **no auto-optimize** of prompts from feedback |
| Authentication: Firebase UI Auth, Google + Email, multiplatform | **PARTIAL** | Custom Firebase Auth (Google + Email + GitHub) on **Android**; not `firebase_ui_auth`; iOS/web Firebase not configured |
| FCM alerts on collaboration request / project update | **PASS** (target) | Client receive + tokens; **send** via Vercel Admin on request create/accept; inbox = `users/{uid}/notifications` |
| Animations (implicit + advanced: Tween, Transition, etc.) | **PARTIAL** | `AppAnimations`, Tween, AnimatedSwitcher, page fades present; **no Hero** |
| Flavors free / pro | **MISSING** | Settings UI toggle only; no Gradle `productFlavors` / Flutter `--flavor` |
| Code obfuscation + Android App Bundle | **MISSING** | Release still debug-signed; no minify/R8 / documented `flutter build appbundle --obfuscate` |

## What ships for FCM (this pass)

- `POST /notify` on DevSync API (Firebase Admin): verify ID token, validate `requests/{requestId}`, write inbox doc, multicast FCM to `users/{targetUid}/fcmTokens`
- Flutter calls notify after create request (owner) and accept (contributor); failures are best-effort
- Notifications screen reads Firestore inbox (no `dummy_notifications` seed)

## Still missing (next)

1. **Free / Pro flavors** — `productFlavors` + `--flavor` + optional Pro gating  
2. **Obfuscated AAB** — release signing, `minifyEnabled`, `flutter build appbundle --obfuscate --split-debug-info=...`  
3. **Hero animation** — e.g. match card → project details  
4. **Prompt optimize loop** — suggest/apply best `promptVersion` from feedback quality metrics  
5. **Auth criterion** — adopt `firebase_ui_auth` or document custom Firebase Auth as accepted equivalent; optional iOS/web Firebase apps  

## Related docs

- Product / ownership: [README.md](../README.md)
