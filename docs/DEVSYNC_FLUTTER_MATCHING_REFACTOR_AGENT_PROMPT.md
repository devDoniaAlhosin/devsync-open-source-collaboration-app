# DevSync — Claude Code Prompt: Flutter Matching Only (Integration, Clean Architecture & Cleanup)

> **Read this instruction first.** This is a user-owned instruction document intended to be placed at `docs/DEVSYNC_FLUTTER_MATCHING_REFACTOR_AGENT_PROMPT.md` in the **Flutter repository**. **NEVER edit, stage, commit, push, rename, or delete THIS prompt file.** Work on the Flutter matching feature only. The Gemini backend has already been implemented separately; **DO NOT implement, rewrite, or commit changes to the backend**.
>
> Target branch: `feature/matching`. Desired milestone: Saturday, November 7, 2026. Work in small, verified commits and leave a durable handoff before context exhaustion.

## 1. Your exact mission (non-negotiable scope)

You are Claude Code acting as a senior Flutter engineer specializing in **feature-first Clean Architecture, SOLID, object-oriented design, Cubit, Firebase Auth, Firestore, and API integrations**.

**Your job is ONLY to finish, refactor, test, and clean up `matching` in the Flutter DevSync app**, integrating it with the **existing working** backend matching endpoint. This is not a backend implementation task, an app-wide refactor, or an opportunity to rebuild features owned by other developers.

Deliver a production-ready matching workflow:

`signed-in developer -> real profile/skills and eligible projects as defined by the actual contract -> authorized POST /matches/generate -> scores/reasons/fallback metadata -> ranked matching feed -> details / existing like-skip actions`

**Do not stop after providing a plan.** Inspect existing code, implement only remaining work, test, commit each finished logical task, update agent handoff, and continue safely.

### Hard boundaries

**Allowed code edits:**
- `lib/features/matching/**`
- `test/features/matching/**` (or the project's matching-specific test paths)
- Minimal, strictly matching-related wiring in `lib/core/di/injection.dart`, app routes, or the existing shell if necessary
- Minimal shared HTTP/auth code changes **only if essential** and proven not to affect other features; otherwise work inside matching or document the blocker
- Matching-specific `docs/matching/**` implementation notes, progress, and handoff

**Forbidden unless user explicitly authorizes a scope change:**
- Any changes in `devsync_backend` or its branches, routes, Gemini integration, Firestore Admin SDK, or Vercel configuration
- Rewriting authentication, profile, projects, requests, like/skip, theme, navigation shell, Firebase rules, or other team features
- App-wide cleanup, renaming, dependency upgrades, formatter sweeps, file moves, configuration rewrites, Android Gradle upgrades, and unrelated refactors
- Creating REST endpoints for Firestore CRUD, adding a Flutter Gemini SDK, or putting Gemini credentials in Flutter
- Changing the backend JSON contract just to make Flutter easier to implement

You **may read** nearby feature contracts and the backend's `docs/matching/CONTRACT.md`, README, and handoff for integration understanding; treat backend files as **read-only**. Never touch unrelated user work.

## 2. What is already complete — verify, then preserve

The Flutter team reports these are implemented:

- Real HTTP matching data source; Flutter posts to backend
- Matching request model and response parsing
- Error handling
- `get_it` dependency injection
- Repository and use cases
- Cubit loading/success/error states
- Existing match feed screens/widgets

Reported existing Flutter commits:
- `7b8c165` — `feat(matching): wire HTTP data source in dependency injection`
- `926f55d` — `feat(matching): upgrade Android deps and add HTTP data source`
- `a0b777c` — `fix(android): upgrade AGP from 9.0.1 to 9.1.1`

**Do not blindly implement these again.** Verify with source, recent Git history, and tests. Do not repeat Android upgrades or resurrect older mock implementations.

The backend team reports:

- Local API: `http://localhost:3000`
- Android emulator's host-machine API: `http://10.0.2.2:3000`
- Production API: `https://devsync-backend-two.vercel.app`
- `POST /matches/generate` implemented using Gemini scoring and deterministic fallback
- `GEMINI_API_KEY` is backend-only
- The matching endpoint requires a **Firebase ID token** in `Authorization: Bearer <idToken>`, with identity matching the request's UID
- Empty `matches` is an expected successful response if there are no eligible Firestore projects or the profile has no declared skills
- Reported response contains `matches` and `promptVersion`; match items may contain `isFallback`
- Backend may obtain candidate projects from Firestore or accept supplied candidate projects, depending on its actual current contract

**IMPORTANT:** The supplied test guide and backend documentation differ in how projects reach the backend. Do not assume either mechanism. Read the real backend `docs/matching/CONTRACT.md` (if accessible), Flutter models, backend implementation/read-only API documentation, and live behavior. Follow the *actual verified contract*; do not make Flutter fetch/submit projects unnecessarily if backend fetches them. Do not silently change semantics.

Do not interpret "backend locally working" as proof production has the same version/configuration. Test environments independently.

## 3. Inspect before touching any code

From the Flutter repository:

```bash
pwd
git status --short
git branch --show-current
git log --oneline -10
git fetch origin
# Only if it is safe and the branch exists:
git switch feature/matching
git pull --ff-only origin feature/matching
flutter pub get
```

Before switching/pulling, inspect any local changes. Never overwrite, stash, clean, reset, or commit another person's modifications without authorization. If the branch is absent or checkout is unsafe, preserve the workspace and document the problem.

Read selectively:

1. Root `README.md` and matching guidance
2. `lib/features/matching/**`
3. Matching models and contracts: `MatchRequestModel`, `MatchResponseModel`, `MatchItemModel` (actual names may vary)
4. `lib/core/di/injection.dart`, matching routes, shell integration
5. `lib/features/auth/` only as an architecture/auth-token reference
6. Existing profile and project interfaces, **read-only**
7. Matching tests and matching-only temporary/dummy files
8. Backend `README.md` and `docs/matching/CONTRACT.md` if available, **read-only**

Create a **short inventory** classifying each matching file as: production-required / test-only / temporary-or-obsolete / unknown. Confirm actual dependencies before deleting anything.

## 4. Architectural quality: Clean Architecture + SOLID + OOP

Follow existing DevSync patterns and keep code small, cohesive, typed, testable, and maintainable.

Suggested responsibility boundaries (adapt to the actual repository):

```text
lib/features/matching/
  domain/
    entities/                 # Flutter/Firebase/HTTP-independent domain objects
    repositories/             # abstract contracts
    usecases/                 # one coherent business operation per use case
  data/
    models/                   # JSON DTOs + strict parsing
    datasources/              # remote matching API; Firestore only if contract requires it
    repositories/             # domain interfaces implemented here
    mappers/                  # DTO/domain conversion if complexity justifies it
  presentation/
    cubit/                    # Cubit and immutable, explicit states
    screens/                  # screens and composition
    widgets/                  # small reusable matching widgets
```

**Do not create empty directories, unnecessary interfaces, duplicate DTOs, elaborate generics, or abstract classes without clear benefit.** Reuse and improve the present implementation.

**SOLID requirements:**
- **S**ingle Responsibility: API transport, mapping, business operations, state transitions, and rendering have distinct responsibilities.
- **O**pen/Closed: allow swapping a matching data source or repository implementation via interfaces/DI, not editing every caller.
- **L**iskov Substitution: mock/fake *test doubles* satisfy the same contracts and failure behavior as real implementations.
- **I**nterface Segregation: use focused contracts; no giant all-purpose repositories.
- **D**ependency Inversion: use cases depend on domain repository abstractions, not HTTP/Firebase classes.

**OOP and clean code:**
- Encapsulate mutable state; use meaningful names and immutable models/states where appropriate.
- No direct HTTP requests inside widgets or Cubits.
- No Firebase SDK imports into pure domain entities/use cases.
- No data parsing, sorting logic, or business calculations embedded in build methods.
- No `dynamic`/unsafe casts where typed validation is possible.
- Centralize configuration; follow existing `DEVSYNC_API_BASE` and `DEVSYNC_API_LOCAL` conventions.
- Respect existing `Result<T>` / typed `Failure`, `flutter_bloc` Cubit-first state management, and `get_it` dependency injection.
- Follow Dart style; avoid overly large classes and duplicated code, but do not overengineer.
- Follow current auth token refresh lifecycle and dispose HTTP clients/resources correctly.

## 5. Integrate with the EXISTING backend (do not modify it)

Only call:

`POST /matches/generate`

Production base URL: `https://devsync-backend-two.vercel.app`

Local run:

```bash
flutter run --dart-define=DEVSYNC_API_LOCAL=true
# or, for Android emulator:
flutter run --dart-define=DEVSYNC_API_BASE=http://10.0.2.2:3000
```

Production run:

```bash
flutter run
# or explicit:
flutter run --dart-define=DEVSYNC_API_BASE=https://devsync-backend-two.vercel.app
```

### Authentication — mandatory

- Obtain the currently signed-in Firebase user's **ID token**, using the existing auth/session pattern. Refresh when appropriate.
- Send `Authorization: Bearer <idToken>` with `Content-Type: application/json`.
- Use the actual authenticated `uid`, never hardcoded test user IDs or `test-user-123`.
- Do not confuse the Firebase ID token with the backend-only Gemini key.
- Handle missing session, expired/rejected token, `401`, and `403` without crashes; avoid leaking tokens into logs or UI.
- If the backend actually requires any additional documented headers, follow the verified contract.

### Request and response — mandatory

- Serialize actual user-declared skills and, where available and required, public GitHub language/activity data; no invented skills, contributions, or projects.
- Inspect exact required request fields in the contract. The backend guide supplies a *sample* with `uid`, `declaredSkills`, `githubLanguages`, `publicRepoCount`, `totalContributions`, `bio`, and `topRepositories`; not all fields may be required.
- Respect the backend's maximum number of candidate projects **if and only if** the verified contract requests candidates from Flutter (guide mentions up to 20).
- If the backend itself queries Firestore projects, do **not** duplicate that query or send unnecessary candidate projects.
- Parse the actual `matches` array and `promptVersion` without relying on test-only fields. Preserve stable project IDs, normalized 0–100 scores, reasons, match skills, and `isFallback` where supplied.
- Preserve the backend's own deterministic fallback (`isFallback: true`) rather than building conflicting fake AI calculations in Flutter.
- Display results sorted highest score first, with stable tie-breaking. Treat unknown/invalid scores and malformed responses as typed errors as appropriate.
- Do not substitute a hardcoded list when API results are empty.

### Failure and empty state behavior

- `200` with `matches: []` is **not** an error. Render the real empty state.
- No user skills: show a useful add-skills empty state if the product expects it.
- No eligible Firestore projects: show an honest no-projects empty state.
- Network failure/timeout: clear retryable state, not an infinite spinner.
- Invalid payload (`400`), auth errors (`401/403`), rate limit (`429`), backend/upstream errors (`5xx`): meaningful failures, no stack traces exposed to users.
- Preserve or implement retry/refresh only if consistent with existing architecture; never create uncontrolled retry loops.
- Prevent multiple API calls caused by widget rebuilds and avoid unnecessary token refreshes.

## 6. Match feed UI — real data only

Reuse the current DevSync design and routing:
- `AppColors`, `AppSpacing`, `AppTypography`, `AppAnimations`
- `AppIcons` and `DsIcon`
- `DsMatchCard`, `DsScoreMeter`/`DsScoreRing`, `DsChip`, `DsEmptyState`, and other existing shared widgets

Show real project information, score, reason, skill overlap, and fallback indicator when appropriate. Link to the existing project detail screen. Integrate current like/skip flows via their existing contracts without altering their implementation or recreating fake actions.

Use Cubit states that distinguish initial, loading, loaded, empty, failure and refresh as needed. Ensure lifecycle/disposal is correct.

Do not introduce demo cards, fake profile values, placeholder project scores, or sample lists into production runtime code. UI may display a visually useful empty state without invented results.

## 7. Remove temporary and dummy matching artifacts SAFELY

**The final running matching feature must use real authenticated data and the real matching endpoint, not demo data.**

Audit `lib/features/matching/**` and other files *owned solely by matching*. Find:
- `MockMatchingRemoteDataSource` or fake runtime data-source wiring
- Hardcoded developer IDs, skills, project cards, and match percentages
- In-memory sample matches used only to simulate production behavior
- Temporary screen/widget duplicates, debug-only logging, and obsolete experiments
- Temporary JSON used at runtime, temporary scripts, obsolete adapters/mappers and dead imports
- Deprecated feature-only flags that select fake matching by default

**Removal protocol:**
1. Identify each candidate artifact and its references first (imports, DI registrations, tests, routes).
2. Determine whether it is genuinely unused/obsolete or required for functioning tests.
3. Remove only confirmed obsolete **matching-owned** code, imports, dependencies and files.
4. Remove obsolete DI registrations/feature flags with minimal changes outside matching.
5. Re-run analyzer and matching tests after each removal batch.
6. Inspect the diff to verify no unrelated code or production dependencies were deleted.

**Preserve** valid unit-test fixtures, fake repositories used only inside tests, contract examples in documentation, and developer tools intentionally needed by the project. If tests still depend on a runtime mock, replace it with local test doubles under `test/features/matching/` before removing the production mock. Do not remove deterministic fallback behavior from the backend (it is production functionality, not dummy data).

**Never:**
- Execute broad `git clean -fd`, wildcard deletion, or a full-tree cleanup.
- Delete shared assets or files used by another feature.
- Drop legitimate backend contract fields or fallback metadata because they look unused.
- Seed fake Firestore projects into production to make the feed look populated.
- Delete data from Firestore without explicit user approval.

Keep the matching implementation lean and leave no unused imports, commented-out temporary implementations, or simulated production data.

## 8. Do not break existing work

Flutter ownership boundaries matter:
- Profile and GitHub data are owned by another feature.
- Projects list/create/edit/details are owned by another feature.
- Like/skip and requests belong to other teammates.
- Auth and shared app-shell are already in use.

Depend on those modules' existing contracts. If they are unfinished, implement a matching-owned adapter only when necessary and clearly document the dependency. Do not silently modify unrelated behavior.

Run available login smoke tests or report clearly why sign-in could not be verified.

## 9. Small-task execution plan

First create or update **separate progress files** (these may be committed):
- `docs/matching/IMPLEMENTATION_PLAN.md`
- `docs/matching/AGENT_HANDOFF.md`

Preserve existing progress and reconcile with current code; do not overwrite prior valid handoff.

Suggested task sequence — adjust based on verified code, and split large tasks into smaller increments:

| ID | Task | Acceptance criterion |
| --- | --- | --- |
| M01 | Audit current matching feature, branches, contract, and temporary artifacts | Real vs. mock paths and gaps documented |
| M02 | Verify authorization and live API request/response mapping | Valid Firebase ID token, exact contract, no fake fields |
| M03 | Refactor matching domain/data boundaries | Clean Architecture, SOLID, OOP, testability; no unnecessary layers |
| M04 | Connect actual profile/project inputs according to verified contract | No hardcoded UID/skills/projects; no duplicate Firestore logic |
| M05 | Complete Cubit, feed, empty/error/refresh flows | Correct ranked UI; stable states; no duplicate requests |
| M06 | Remove obsolete matching-only mocks, temporary files and debug paths | Production has no dummy data; tests preserved |
| M07 | Add/update matching tests | Contract, auth, success/empty/failure/fallback, Cubit/widget |
| M08 | Run local integration, regressions, document production verification | Verified or clearly blocked; handoff complete |

**Important:** If M02–M05 are already correct, mark them VERIFIED and make only necessary changes. Do not generate commits with meaningless refactors. Complete remaining work, especially safe cleanup and tests.

## 10. Commit after each completed logical task — prompt file excluded

Use only the Flutter matching branch `feature/matching` (unless actual repository instructions specify a sanctioned equivalent). Do not commit in the backend.

Each task:
1. Make a focused change.
2. Format changed Dart files; run focused tests, then analyzer as appropriate.
3. Review `git status` and `git diff`.
4. Stage **explicit matching-related files only**. Avoid `git add .`, `git add -A`, `git add docs/`.
5. Check `git diff --cached --name-only` and `git diff --cached --check`.
6. Verify this prompt path is **NOT staged** (and remove it from the index without altering its content if accidentally staged).
7. Commit a small working slice, e.g. `refactor(matching): isolate HTTP DTO mapping` or `fix(matching): attach Firebase ID token`.
8. Record the real commit hash and tests run in `AGENT_HANDOFF.md`.
9. Continue automatically.

**This prompt file is immutable and must NEVER be part of any commit**, even if it's located under `docs/`. Neither commit nor delete it. Existing tracked unrelated files, staged work, and local changes are not yours to reset. Do not force-push or merge into `develop`/`main`.

You may commit **progress/handoff** documents as part of normal tasks; those are distinct from the prompt file.

## 11. Tests and verifiable results

Automated matching-only tests should cover:

- Exact request JSON serialization against verified backend contract
- Firebase bearer token attached, missing/expired token, `401`/`403` behavior (mock dependencies, never print tokens)
- `200` with nonempty matches; scores ordered descending
- `200` with empty matches; honest empty feed, not an error
- `promptVersion` and `isFallback` handling, including fallback scores from backend
- Invalid/malformed JSON and missing required response fields
- Network timeout, offline, `400`, `429`, and `5xx` failures
- User with no skills, missing optional GitHub stats, no eligible projects
- Cubit transitions, refresh/retry, duplicate-request prevention
- Match card score, reason, project detail action, empty state
- No fake matching data source selected by DI in production
- No direct HTTP calls from UI/domain layers

**Use test-only fixtures/doubles; real paid Gemini requests are not part of Flutter unit tests.**

Typical commands (adjust paths to real repo):

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib/features/matching test/features/matching
flutter analyze
flutter test test/features/matching
flutter test
```

Only run `dart format` across files you own; don't reformat other team features. If a command or test directory does not exist, adapt and record the actual command.

Manual verification when possible:
1. Start backend in **read-only sibling repo** if available: `npm run dev` (do not edit backend files).
2. Use a *real authenticated test account* and existing legitimate Firestore data in an authorized test environment.
3. Run Flutter locally via `DEVSYNC_API_LOCAL=true` and open matching feed.
4. Confirm authorized request, sorted matches, reasons, empty state and no crashes.
5. Test production separately only if its Firebase auth, Gemini configuration and deployed API are available.
6. Check backend health if available; a healthy `/health` does **not** by itself prove end-to-end matching.

**Do not create sample projects in production Firestore or claim end-to-end success from an empty response alone.** If no real eligible projects exist, automated contract tests can prove the nonempty case, but mark real-data integration as unverified.

## 12. Mandatory persistent handoff (for the next Claude agent)

After every completed task, update:

`docs/matching/IMPLEMENTATION_PLAN.md`
- Task ID, status (`NOT_STARTED`, `IN_PROGRESS`, `VERIFIED`, `COMPLETED`, `BLOCKED`), acceptance criteria, exact validation.

`docs/matching/AGENT_HANDOFF.md`
- Current branch and `git status`
- Last completed task, exact task in progress
- Files changed and reason
- Backend contract discovered (auth headers, request/response JSON, candidate project ownership)
- Matching-only files removed and why
- Current DI path (real vs mock)
- Actual tests executed and results; blockers
- Commit hashes (only real commits)
- Exact next command/file/action for next agent
- Explicit note that **this prompt was not committed**

Save checkpoint **before** long edits, at each finished task, and whenever context usage approaches 70–80%, or before compaction. Do not rely on conversation memory. Finish a small safe unit, test and commit it, then leave an accurate handoff. A fresh agent must verify the state via Git and code, not trust notes blindly.

### Fresh agent continuation procedure

1. Read `docs/matching/AGENT_HANDOFF.md` and `docs/matching/IMPLEMENTATION_PLAN.md`.
2. Inspect `git status`, branch and latest commits.
3. Inspect actual matching code, tests and verified backend contract.
4. Resume the first incomplete task **without recreating finished work**.
5. Test, commit matching-related work only, update handoff, and continue.
6. **Never edit or commit this prompt file. Never modify the backend.**

## 13. Definition of done

- [ ] Only the **Flutter matching feature** was changed (plus minimal necessary matching DI/route wiring).
- [ ] Code follows existing feature-first **Clean Architecture, SOLID, OOP**, with Cubit, GetIt and typed failures.
- [ ] Production matching calls the existing backend `POST /matches/generate`.
- [ ] Firebase ID token is attached and current signed-in UID is used.
- [ ] Actual backend request/response contract is preserved and tested.
- [ ] Real profile and project information flows appropriately; no invented/hardcoded production data.
- [ ] Ranked matching cards show real scores, reasons and existing detail/like-skip integration.
- [ ] Backend-provided deterministic fallback data is displayed correctly.
- [ ] Empty/loading/auth/network/rate-limit/error states work and are tested.
- [ ] All confirmed obsolete matching-only mocks, temporary adapters/screens/data and dead code are removed.
- [ ] Relevant **test fixtures** and other features are preserved.
- [ ] Matching-focused tests pass; analyzer and available regression tests are run (or blockers documented).
- [ ] All completed logical tasks have small, focused Flutter branch commits.
- [ ] Progress and handoff allow another agent to resume.
- [ ] **THIS PROMPT FILE WAS NOT MODIFIED OR COMMITTED.**
- [ ] Backend repo and unrelated features were not modified.

## 14. Execution start — act now

1. Locate the Flutter repository and verify its branch/status; **do not disturb local changes**.
2. Read the current matching implementation, backend contract docs **read-only**, and existing handoff.
3. Inventory real implementation, unnecessary mocks and temporary files.
4. Write/reconcile the plan and handoff files (different from this prompt).
5. Verify actual API contract and Firebase bearer token behavior.
6. Refactor and clean only matching where needed; implement remaining real-data wiring.
7. Run focused verification; make a small commit; update handoff; continue.

**Do not reply with only a plan. Implement matching-specific work now and preserve a clean, resumable Git history.**

---

## Short prompt for the NEXT Claude Code session

> Continue the **Flutter-only** DevSync Matching feature in `feature/matching`. Read `docs/matching/IMPLEMENTATION_PLAN.md` and `docs/matching/AGENT_HANDOFF.md` first, then inspect Git status/history, matching source/tests, and the existing backend `docs/matching/CONTRACT.md` **read-only**. The backend already implements `POST /matches/generate`, Gemini scoring and deterministic fallback; **do not modify the backend**. Verify that Flutter sends the current Firebase ID token, uses real user profile data, parses actual backend results and displays ranking/empty/errors. Enforce feature-first Clean Architecture, SOLID, OOP, Cubit and GetIt. Safely delete obsolete matching-only mocks, temporary files, dummy runtime data, and dead code; keep test-only fixtures. Work only within matching, with minimal necessary DI/routes wiring. Test each focused task, commit only matching work and separate handoff docs, update progress and continue automatically. **NEVER modify/stage/commit `docs/DEVSYNC_FLUTTER_MATCHING_REFACTOR_AGENT_PROMPT.md`, and never modify other features or `devsync_backend`.** Checkpoint before context exhaustion and leave exact next steps.
