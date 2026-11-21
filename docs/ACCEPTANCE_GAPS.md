# DevSync acceptance criteria — gaps

Scorecard against **“DevSync: Secure AI Project Collaborator”** technical acceptance text.  
Updated after match-details polish, live inbox badges, and AI matching seed tooling (Vercel Gemini unchanged).

## Scorecard

| Criterion | Status | Gap |
|---|---|---|
| AI matching (GitHub activity + skills) | **PASS** | End-to-end: scan → skills → `/matches/generate` → ranked deck; diverse-skill seed script for E2E tests |
| Prompt engineering (search + evaluate + optimize) | **PARTIAL** | AI Studio + like/skip → `feedbacks` + quality charts exist; **no auto-optimize** of prompts from feedback |
| Authentication: Firebase UI Auth, Google + Email, multiplatform | **PARTIAL** | Custom Firebase Auth (Google + Email + GitHub) on **Android**; not `firebase_ui_auth`; iOS/web Firebase not configured |
| FCM alerts on collaboration request / project update | **PASS** (target) | Client token persist hardened; **send** via Vercel `POST /notify` for `request_received` / `request_accepted` / `project_updated`; inbox = `users/{uid}/notifications`; live unread + pending-request badges |
| Flavors free / pro | **MISSING** | Settings UI toggle only; no Gradle `productFlavors` / Flutter `--flavor` |
| Code obfuscation + Android App Bundle | **MISSING** | Release still debug-signed; no minify/R8 / documented `flutter build appbundle --obfuscate` |

## What shipped recently

- Match project details: **Preview** + **Request** side by side; removed unfinished “coming next” workspace preview toast
- Live inbox badges: watch unread notifications + pending received requests (`InboxBadgesCubit`)
- `scripts/seed_diverse_match_projects.mjs` — seed multi-stack projects for AI matching tests (owner UID)
- Stub / unfinished routes: quieter empty copy (no “stub / coming soon” chrome)

## What ships for FCM (earlier pass)

- `POST /notify` on DevSync API (Firebase Admin): verify ID token; request create/accept + project update; write inbox doc; multicast FCM to `users/{targetUid}/fcmTokens`
- Flutter calls notify after create request (owner), accept (contributor), and project edit (accepted collaborators); failures are best-effort with debug logs
- Notifications screen reads Firestore inbox (no `dummy_notifications` seed)
- Deploy sibling `devsync_backend` for `project_updated` support on the hosted API

## Still missing (next)

1. **Free / Pro flavors** — `productFlavors` + `--flavor` + optional Pro gating  
2. **Obfuscated AAB** — release signing, `minifyEnabled`, `flutter build appbundle --obfuscate --split-debug-info=...`  
3. **Prompt optimize loop** — suggest/apply best `promptVersion` from feedback quality metrics  
4. **Auth criterion** — adopt `firebase_ui_auth` or document custom Firebase Auth as accepted equivalent; optional iOS/web Firebase apps  

## Related docs

- Product / ownership: [README.md](../README.md)
