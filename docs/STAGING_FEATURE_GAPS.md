# Staging feature gaps (for Claude / team notes)

Use this after each staging merge + smoke test. Fill **Test notes** and keep **Missing / blockers** honest so each owner gets a short “what’s left” note.

Staging tip at last update: merge order auth → profile → projects → matching → requests.

Expected Firestore collections (from `lib/core/constants/firestore_collections.dart`):

`users` · `projects` · `views` · `matches` · `feedback` · `requests` · `tasks`

---

## Auth — Donia — `feature/auth`

| Field | Value |
|---|---|
| **Merged into staging?** | Yes (fast-forward onto old staging; base for later merges) |
| **Firestore collections used** | `users` (`UserRemoteDataSource.ensureUserDoc`) |
| **Still local/dummy?** | No for identity — Firebase Auth + Firestore user doc |
| **Vercel / HTTP?** | Yes — OTP: `POST /otp/send`, `/otp/verify`, `/email/verify`, `/password/reset`, `/auth/session` |
| **Expected result** | Register → email OTP verify; login; forgot password; sign-in with code (`customToken`); session persists; delete account works |
| **Missing / blockers** | Team devices need shared `google-services.json`; API key restrictions can break OTP on other machines; Google/GitHub Console enablement |
| **Test notes from staging** | `flutter analyze` on auth/DI clean after auth merge. Device smoke: register / OTP / login / code sign-in |

---

## Profile — Saga — `feature/profile-ui`

| Field | Value |
|---|---|
| **Merged into staging?** | Yes |
| **Firestore collections used** | `users` (profile fields + GitHub scan via `ProfileRemoteDataSource`) |
| **Still local/dummy?** | No — local DS removed; remote Firestore |
| **Vercel / HTTP?** | No (GitHub scan data stored on user doc; live GitHub API may still be sample/onboarding path) |
| **Expected result** | Edit bio/skills persist after relaunch; Connect GitHub onboarding writes scan; profile screen shows languages |
| **Missing / blockers** | Confirm rules allow user to update own profile fields; empty-state / flex issues were fixed on branch — re-check UI on device |
| **Test notes from staging** | Analyze: info-only `prefer_initializing_formals`. Device: edit profile + connect GitHub after auth |

---

## Projects — Bishay — `feature/projects`

| Field | Value |
|---|---|
| **Merged into staging?** | Yes (conflicts resolved in DI + profile cubit — kept `SaveGithubScan`) |
| **Firestore collections used** | `projects`, `views` (plus GitHub helper / DevSync API DS for stats/collab helpers) |
| **Still local/dummy?** | No — `ProjectsLocalDataSource` removed; `ProjectsRemoteDataSource` + `registerProjectsDependencies` |
| **Vercel / HTTP?** | Thin `DevSyncApiDataSource` in feature (not matching). Core matching stays separate |
| **Expected result** | Discover / my projects list from Firestore; add/edit upsert; stats; request-to-collaborate helper; project views recorded |
| **Missing / blockers** | Firestore rules for `projects` / `views`; schema doc `docs/projects-firestore-schema.md` — validate against live data; DI must keep calling `registerProjectsDependencies` |
| **Test notes from staging** | Conflict resolution kept profile + projects. Device: list / add / edit / detail |

---

## Matching — Emad — `feature/matching`

| Field | Value |
|---|---|
| **Merged into staging?** | Yes (DI: `createMatchingRepository` = HTTP remote; profile SaveGithubScan kept) |
| **Firestore collections used** | Expected: `matches`, `feedback` — **confirm** whether HTTP path writes cache yet or only in-memory local DS |
| **Still local/dummy?** | Partial — `MatchingHttpRemoteDataSource` + `InMemoryMatchingLocalDataSource`; mock factory still available as `createDemoMatchingRepository` |
| **Vercel / HTTP?** | **`POST /matches/generate` only** — base `https://devsync-backend-two.vercel.app` |
| **Expected result** | Feed ranks projects with score + reason; fallback if Gemini slow; like/skip feedback path if wired |
| **Missing / blockers** | Live Gemini on Vercel; Firestore `matches` / `feedback` persistence if still in-memory; never put `GEMINI_API_KEY` in Flutter |
| **Test notes from staging** | Do **not** push to `feature/matching` from staging work. Device: open match feed after projects exist |

---

## Requests — Yousef — `feature/requests`

| Field | Value |
|---|---|
| **Merged into staging?** | Yes (`CreateRequest` + cubit; constructor adjusted to public named params for current SDK) |
| **Firestore collections used** | Expected: `requests` — **still on `RequestsLocalDataSource` (dummy/local list)** |
| **Still local/dummy?** | **Yes** — local DS |
| **Vercel / HTTP?** | No (FCM later — not required for local list) |
| **Expected result** | Create request from project; list tabs; accept/decline updates status; eventually FCM on new/status |
| **Missing / blockers** | Firestore remote DS + rules for `requests`; FCM; ensure create flow uses staging projects/profile users |
| **Test notes from staging** | Analyze fixed after constructor union. Device: create + accept/decline on local data |

---

## Tasks (if-time) — Donia

| Field | Value |
|---|---|
| **Merged into staging?** | No |
| **Firestore collections used** | Expected: `tasks` — unused |
| **Still local/dummy?** | N/A |
| **Missing / blockers** | Out of core path until after staging integration |

---

## How to generate per-person WhatsApp notes (Claude)

For each section above, write 5–8 bullets:

1. What already works on **staging**
2. Collections done vs missing
3. Local vs remote
4. One expected user-visible result to demo
5. Top blocker before merge to `master`
