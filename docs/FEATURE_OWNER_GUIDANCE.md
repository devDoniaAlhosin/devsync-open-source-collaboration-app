# Feature owner guidance (staging)

Claude / team notes source. Staging tip after Mohey requests merge: use `git log -1 --oneline origin/staging`.

**Goal of this file:** what already runs on staging vs what each owner still owes. Do **not** invent a second architecture — follow auth’s Cubit → use case → repo → `Result` pattern and [`.cursor/rules/devsync-conventions.mdc`](../.cursor/rules/devsync-conventions.mdc).

## Staging truth table

| Feature | Owner | Runs on staging? | Data | Top gap |
|---|---|---|---|---|
| Auth | Donia | Yes | Firebase Auth + `users` + Vercel OTP | Console/SHA-1 / `google-services.json` for teammates |
| Profile | Saga | Yes | Firestore `users` | Live GitHub API (still fake scan in matching UI) |
| Projects | Bishay | Yes | Firestore `projects` / `views` | Tighten rules; keep Discover wired to RequestsCubit only |
| Matching | Emad | Partial | Vercel `POST /matches/generate` + in-memory cache | `Result` mapping; Firestore `matches`/`feedback`; analytics/prompt HTTP |
| Requests | Mohey | Yes (Firestore) | Firestore `requests` + FCM init | Deploy rules; end-to-end accept/decline + notifications UX |
| Tasks / Shell | Donia / Yousef | Shell yes; tasks stub | — | Task board not started |

Expected collections (`lib/core/constants/firestore_collections.dart`):  
`users` · `projects` · `views` · `matches` · `feedback` · `requests` · `tasks`

## Firestore Console checklist (why you only see some collections)

Firestore **does not create empty collections**. A name in `FirestoreCollections` is not enough — the collection appears in Firebase Console only after the **first successful document write**.

| Collection | In code? | App writes it? | Why Console may be empty |
|---|---|---|---|
| `users` | Yes | Yes (auth + profile; FCM under `users/{uid}/fcmTokens`) | Usually visible after first sign-in |
| `projects` | Yes | Yes (create/edit project) | Visible after first project upsert |
| `views` | Yes | Yes (`recordView` on project open) | Empty until someone opens project detail that records a view |
| `requests` | Yes | Yes (Mohey remote DS + join flow) | Empty until a send succeeds — project needs non-empty `ownerId` + rules deployed |
| `matches` | Declared | **No** — matching uses Vercel HTTP + RAM cache | Stays invisible until Emad persists match cache |
| `feedback` | Declared | **No** | Unused — stays invisible |
| `tasks` | Declared | **No** — feature not built | Unused — stays invisible |

**Per-owner actions to populate Console**

- **Bishay:** open a project detail (view recorded) → expect `views`
- **Mohey:** send a collaboration request (project must have `ownerId`) + deploy `firestore.rules` → expect `requests`
- **Emad:** persist to `matches` / `feedback`, or accept they stay invisible while HTTP-only
- **Donia:** `tasks` only when task board ships; keep `users` healthy via auth

Seeing only `users` + `projects` today is **normal** if no one has successfully written views/requests yet and matching/tasks never write.

---

## Auth — Donia — `feature/auth`

### Staging status
Merged earlier; base for other features.

### Architecture
**Strong.** Clean layers; screens → Cubit → use cases → `AuthRepository` → Firebase / `AuthEmailApi`. Domain has no Flutter/Firebase/GetIt. Errors via `mapAuthError` → `Result`/`Failure`.

### Collections / HTTP
- Firestore: `users`
- Vercel: `POST /otp/send`, `/otp/verify`, `/email/verify`, `/password/reset`, `/auth/session`

### Works now (demo)
Register → email OTP verify; login; forgot password; code sign-in (`customToken`); session; settings sign-out / delete.

### Missing checklist
1. Ensure every teammate has current `google-services.json` (private share).
2. Keep API key usable for team debug builds (or document SHA-1 process).
3. Google / GitHub providers fully enabled in Console if demo needs them.
4. Optional: avoid calling `getIt<SignOut>()` from screens — go through Cubit only.

### Do / Don’t
- Do: keep OTP on Vercel; never put Admin / SMTP secrets in Flutter.
- Don’t: reintroduce email-link auth.

---

## Profile — Saga — `feature/profile-ui`

### Staging status
Merged; Firestore profile + `SaveGithubScan`.

### Architecture
**Strong.** Cubit → use cases → remote DS on `users`. Mild smell: matching’s Connect GitHub UI still builds `FakeGithubScanDataSource` in the widget.

### Collections
- Firestore: `users` (bio, skills, GitHub scan fields)

### Works now (demo)
Edit bio/skills persist; Connect GitHub entry can save scan onto user doc; profile languages UI.

### Missing checklist
1. Replace fake GitHub scan with real GitHub API (or shared profile data source) — don’t leave fake construction in presentation.
2. Confirm Firestore rules allow only the signed-in user to write their profile fields.
3. Empty / loading / error states on profile after offline failure.
4. Onboarding steps 2–3 aligned with AuthGate / routes.

### Do / Don’t
- Do: keep persistence in `ProfileRemoteDataSource` / repository.
- Don’t: write Firestore from profile screens directly.

---

## Projects — Bishay — `feature/projects`

### Staging status
Firestore remote + DI helper `registerProjectsDependencies`. Discover/details send collab requests via **RequestsCubit** (Mohey flow), not a second local list.

### Architecture
**Strong.** Cubit + use cases + remote. Slightly fat Cubit (list/stats/upsert/views/collab helpers) but still use-case backed. Duplicate screen name: matching also has `ProjectDetailsScreen` (routed by arg type).

### Collections
- Live: `projects`, `views` (and previously could write `requests` — prefer Mohey’s requests path for create)
- Schema notes: `docs/projects-firestore-schema.md`

### Works now (demo)
Discover / my projects from Firestore; add/edit; detail + stats; request to join opens sheet and persists through requests feature when `ownerId` is set.

### Missing checklist
1. Ensure every project document has non-empty `ownerId` (requests flow blocks empty IDs).
2. Align project counter bumps with Mohey’s request creates (avoid double-write to `requests`).
3. Tighten Firestore rules (owner-only updates where safe).
4. Longer term: rename details screen to avoid clash with matching’s `ProjectDetailsScreen`.

### Do / Don’t
- Do: keep `registerProjectsDependencies` as the only projects DI entry.
- Don’t: reintroduce `ProjectsLocalDataSource` on staging.

---

## Matching — Emad — `feature/matching`

### Staging status
Already on staging before this pass (`MatchingHttpRemoteDataSource` + in-memory local). **Do not push matching from this work.**

### Architecture
**Medium.** Layers exist; Cubit rebuilds use cases instead of injecting registered ones; repo does **not** return `Result` (swallows errors → empty list). Domain clean of Flutter/Firebase.

### Collections / HTTP
- HTTP only: **`POST https://devsync-backend-two.vercel.app/matches/generate`**
- Firestore `matches` / `feedback`: **unused** (cache is RAM)
- Analytics / prompt generate methods: unimplemented on HTTP DS

### Works now (demo)
Feed can call generate when API responds; mock/demo factories still available.

### Missing checklist
1. Map failures to `Result` / `Failure` at repository boundary (match auth/projects).
2. Persist match cache / likes to Firestore `matches` and `feedback` if product requires it.
3. Implement or hide studio/analytics until backend supports them.
4. Inject GetIt use cases into Cubit (stop reconstructing).
5. Move fake GitHub scan out of presentation (coordinate with Saga).
6. Skills fallback when Gemini/API fails (client or server).

### Do / Don’t
- Do: only **`POST /matches/generate`** for matching HTTP; keep `GEMINI_API_KEY` on Vercel.
- Don’t: add Flutter REST create/get for projects/users; don’t push secrets.

---

## Requests — Mohey (Yousef) — `feature/requests`

### Staging status
**Merged into staging** this pass (Firestore remote, accept/decline, FCM bootstrap, owner-aware rules).

### Architecture
**Good shape.** Cubit → use cases → `RequestsRemoteDataSource`. Private-named constructors adjusted for current SDK. FCM service filename typo `fcm_scrvice.dart` (rename later). Closing a factory Cubit after the join sheet is OK but brittle — prefer a scoped BlocProvider later.

### Collections / FCM
- Firestore: `requests` (strict rules from Mohey)
- FCM: token registration on bootstrap (failures swallowed so app still launches)

### Works now (demo)
Inbox should load from Firestore for sender/owner; send request from Discover/Details when `projectId` + `ownerId` present; accept/decline updates; notification soft-ask screen.

### Missing checklist
1. Deploy / verify `firestore.rules` on the Firebase project (create/update must match `validRequestData`).
2. End-to-end test: two accounts — send → appear in owner inbox → accept/decline.
3. FCM: foreground UI, permission UX, and token field on `users` confirmed in Console.
4. Rename `fcm_scrvice.dart` → `fcm_service.dart`.
5. Wire notification deep links to Requests tab.
6. Coordinate with Bishay so project request counters stay in sync without double docs.

### Do / Don’t
- Do: keep one create path (`RequestsCubit` / remote DS).
- Don’t: fall back to `dummy_requests` on staging.

---

## Tasks / Shell

### Shell
Navigation host only — OK without domain. Optional later: `shell/presentation/screens/`.

### Tasks (Donia, if-time)
`.gitkeep` only. Collection `tasks` unused. Start only after core freeze if capacity allows.

---

## Clean code / SOLID / clean architecture (staging snapshot)

| Principle | Status |
|---|---|
| Feature folders presentation / domain / data | Mostly yes (shell/notifications flatter) |
| Domain free of Flutter / Firebase / GetIt | Yes under `features/*/domain` |
| Screens don’t call Firebase | Yes (FCM only in bootstrap) |
| `Result` at repo boundary | Auth, profile, projects, requests — **yes**; matching — **no** |
| One composition root | `injection.dart` + feature DI helpers |
| Duplications | Two `ProjectDetailsScreen`s; request create was dual-path — staging now prefers Mohey’s Firestore create |

---

## How Claude should write WhatsApp notes

For each owner, 5–8 bullets:

1. Staging status (merged / partial)
2. What works in a demo
3. Collections done vs missing
4. Top 2–3 checklist items
5. One Do / Don’t

---

## Tiny fixes already done on staging this pass

- AGP 9 Kotlin bypass so Android builds with `app_links`
- Mohey requests merge + DI union (profile SaveGithubScan + projects remote + matching HTTP + requests Firestore)
- Requests remote constructor SDK-safe
- Discover/Details pass `projectId` / `ownerId` into Mohey’s flow (no second local create)
- FCM init wrapped so launch isn’t blocked
