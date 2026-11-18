# DevSync — missing work per feature (team guidance)

**This is the single doc for Claude / owners** on what still needs to be done on `main`.  
Do **not** put this content in `README.md`.

Related (schema only): [projects-firestore-schema.md](projects-firestore-schema.md)  
Architecture: follow auth’s Cubit → use case → repo → `Result` and [`.cursor/rules/devsync-conventions.mdc`](../.cursor/rules/devsync-conventions.mdc).

Task board (`tasks`) is **extra** — out of scope here.

---

## How to use this doc

1. Find your name / feature below.  
2. Do the **Guidance — what you need to do** checklist in order.  
3. Mark an item done only when the **Done when** criterion is true.  
4. Do not invent a second architecture or a second request-create path.

---

## Summary

| Owner | Feature | On main today | You still need to |
| --- | --- | --- | --- |
| Donia | Auth | OTP, session, delete account | Team Firebase access (json / API key / SHA-1); providers if demo needs them |
| Saga | Profile | `users.profile` + live GitHub scan | Rules, offline UI, onboarding path, optional `GITHUB_TOKEN` |
| Bishay | Projects | `projects` / `views` + Discover | Owner fields on all docs; one request path; tighten rules |
| Emad | Matching | Vercel `POST /matches/generate` + RAM | `Result` errors; decide persist vs RAM; hide/fix studio; GetIt |
| Mohey (Yousef) | Requests + FCM | Firestore `requests` + `fcmTokens` | Deploy rules; E2E; FCM UX; write `feedback` |

---

## 1. Auth — Donia

### Exists

- Email/password register & login  
- Vercel OTP: `/otp/send`, `/otp/verify`, `/email/verify`, `/password/reset`, `/auth/session`  
- Sign-out / delete account  
- Clean layers + `Result` / `Failure`

### Missing (detail)

Auth **product code is largely done**. Remaining work is **team/Firebase hygiene** so everyone can run the same app.

### Guidance — what you need to do

1. **Share `google-services.json`** privately with every teammate (same file as your working build).  
   - **Done when:** each member can `flutter run` without “API key not valid” from a missing/wrong config.
2. **Fix API key / SHA-1 for debug.** In Firebase Console: add each teammate’s debug SHA-1 (or document how they get it with `keytool` / Android Studio). Relax or document API key restrictions for team debug.  
   - **Done when:** OTP send/verify works on at least two machines.
3. **If the demo uses Google/GitHub buttons:** enable those providers in Firebase Console and finish OAuth client setup.  
   - **Done when:** button → real Firebase session (or buttons hidden if out of demo).
4. **Prefer Cubit for sign-out** — screens should not call `getIt<SignOut>()` directly.  
   - **Done when:** Settings/log-out goes through `AuthCubit` only.

### Do / Don’t

- **Do** keep OTP secrets on Vercel only.  
- **Don’t** reintroduce email-link as the primary path.  
- **Don’t** commit service-account JSON or SMTP passwords.

---

## 2. Profile + GitHub — Saga

### Exists

- Load/save `users/{uid}.profile`  
- Live GitHub scan (`ScanGithubProfile` → `api.github.com`)  
- `SaveGithubScan` onto the user doc  

### Missing (detail)

Rules, resilient UI, and onboarding flow polish — not a new fake scan.

### Guidance — what you need to do

1. **Firestore rules** — only `request.auth.uid == userId` may write that user’s `profile` (and related fields you own).  
   - **Done when:** another uid cannot overwrite your profile in rules tests / Console.
2. **Offline / error UI** — loading, retry, and clear snackbars when fetch/save fails.  
   - **Done when:** airplane mode → user sees a recoverable error, not a blank crash.
3. **Onboarding** — Connect GitHub → Edit profile/skills aligns with `AuthGate` / routes (steps 2–3).  
   - **Done when:** first-time user path reaches home with skills without a dead end.
4. **Optional rate limits:** document `flutter run --dart-define=GITHUB_TOKEN=ghp_…` for demos.  
   - **Done when:** README/docs note exists; scan still works without token at low volume.

### Do / Don’t

- **Do** keep GitHub HTTP in `GithubProfileRemoteDataSource` / use cases.  
- **Don’t** call Firestore or GitHub from widgets.  
- **Don’t** bring back `FakeGithubScanDataSource` on main.

---

## 3. Projects — Bishay

### Exists

- Create/edit projects; Discover + My projects  
- `views` + `viewsCount`  
- Upsert fills `ownerId` / `ownerName`  
- Join uses **RequestsCubit** (preferred)  

Schema: [projects-firestore-schema.md](projects-firestore-schema.md).

### Missing (detail)

Legacy empty `ownerId`, possible dual request writers, rules, indexes.

### Guidance — what you need to do

1. **Owner fields** — every project used in demo must have non-empty `ownerId` (and preferred `ownerName`). Guard create/edit; fix or delete bad seed docs.  
   - **Done when:** Discover → Request to join never hits “missing ownerId”.
2. **Single request-create path** — only Mohey’s `RequestsCubit` / `RequestModel` (`senderId`, …). Remove or hard-guard the old projects-remote writer (`requesterId` / `projectTitle` shape).  
   - **Done when:** one code path creates `requests` docs; shape matches rules.
3. **Tighten rules** — owner-only updates on `projects/{id}` where safe; viewers can read.  
   - **Done when:** non-owner update is denied in rules.
4. **Views index** — if sparkline/query fails, deploy composite index from `firestore.indexes.json`.  
   - **Done when:** weekly views query succeeds in Console/app.
5. **Later** — rename details screen to avoid clash with matching’s `ProjectDetailsScreen`.

### Do / Don’t

- **Do** keep `registerProjectsDependencies` as the only projects DI entry.  
- **Don’t** reintroduce a local-only projects data source for production path.  
- **Don’t** write a second `requests` schema from projects.

---

## 4. Matching — Emad

### Exists

- `POST https://devsync-backend-two.vercel.app/matches/generate`  
- Ranked list in **RAM** + Cubit feed  
- Likes in **`LikedMatchesStore` (RAM)**  

### Missing (detail) — read carefully

| Concept | Today | Not |
| --- | --- | --- |
| Ranked matches | HTTP JSON → RAM | Firestore `matches` table |
| `promptVersion` | Field on HTTP response | A Firestore collection |
| Like / skip | RAM store | Firestore `feedback` |

### Guidance — what you need to do

1. **`Result` / `Failure`** at repository boundary — do not swallow errors into `[]`.  
   - **Done when:** Cubit can show a real error when generate fails.
2. **Persistence decision**  
   - Either write cache docs to Firestore `matches`, **or** explicitly accept “HTTP + RAM only” for the demo and say so in PR/docs.  
   - **Done when:** team agrees and Console either shows `matches` after generate **or** docs say “no Firestore matches”.
3. **With Yousef (FR-15)** — persist like/skip to `feedback` (`userId`, `projectId`, `action`, timestamp), or agree RAM-only for demo.  
   - **Done when:** like creates a `feedback` doc **or** documented exception.
4. **Studio / analytics / prompt screens** — implement against real APIs or hide/disable until backend supports them (no `UnimplementedError` in the demo path).  
   - **Done when:** demo never opens a crashing stub.
5. **DI** — inject GetIt use cases into Cubit; stop reconstructing them.  
6. **Fallback** — if Gemini/HTTP fails, skills-overlap (or clear empty + retry) still works.

### Do / Don’t

- **Do** keep matching HTTP as **`POST /matches/generate` only**; `GEMINI_API_KEY` on Vercel.  
- **Don’t** claim Cloud Function `scoreMatches` is live.  
- **Don’t** claim Firestore `matches`/`feedback` are written until they are.

---

## 5. Requests + FCM (+ feedback) — Mohey (Yousef)

### Exists

- Firestore `requests` via `RequestModel`  
- Accept / decline  
- FCM token under `users/{uid}/fcmTokens/{token}`  
- Soft-ask permission screen  
- Discover/Details join when `projectId` + `ownerId` present  

### Missing (detail)

Deployed rules, real E2E, notification UX, and FR-15 feedback persistence.

### Guidance — what you need to do

1. **Deploy `firestore.rules`** that match `RequestModel` / `validRequestData`.  
   - **Done when:** create/update from two test accounts succeeds under rules (not only with open rules).
2. **E2E demo script** — Account A sends → Account B (owner) sees inbox → accept/decline.  
   - **Done when:** recorded once on device/emulator with current `main`.
3. **FCM UX** — foreground banner/snackbar, permission copy, deep link into Requests tab.  
   - **Done when:** a test notification opens the right place (or documented limitation).
4. **Rename** `fcm_scrvice.dart` → `fcm_service.dart` (and imports).  
5. **FR-15 `feedback`** — with Emad, write like/skip docs; don’t treat `LikedMatchesStore` as done.  
6. **Counters** — `projects.requestsCount` stays correct without duplicate request docs (coordinate Bishay).

### Do / Don’t

- **Do** keep one create path: `RequestsCubit` / remote DS.  
- **Don’t** fall back to `dummy_requests` on main.  
- **Don’t** store FCM as a single `users.fcmToken` field — use `fcmTokens` subcollection.

---

## Collections cheat sheet

### Written

| Path | Who | Purpose |
| --- | --- | --- |
| `users/{uid}` | Donia / Saga | Auth + `profile` |
| `users/{uid}/fcmTokens/{token}` | Mohey | Push tokens |
| `projects/{id}` | Bishay | Listings |
| `views/{…}` | Bishay | Daily views |
| `requests/{id}` | Mohey | Collab requests |

### Declared, not written

| Collection | Who should own write | Today |
| --- | --- | --- |
| `matches` | Emad | HTTP + RAM |
| `feedback` | Yousef / Emad | RAM likes |

Firestore Console shows a collection only after the **first successful write**.

---

## One-paragraph status (for reports)

On main, Auth (OTP), Profile (live GitHub scan), Projects (`projects`/`views`), and Requests (`requests` + FCM bootstrap) are implemented. Matching generate works over the external Vercel API with an in-memory cache; Firestore `matches` and `feedback` are still missing. Remaining work is mostly rules/E2E/FCM UX (Mohey), owner-field hygiene and a single request path (Bishay), Result mapping and optional match/feedback persistence (Emad), profile rules/offline (Saga), and team Firebase credentials (Donia).
