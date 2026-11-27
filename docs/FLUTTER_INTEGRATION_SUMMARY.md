# DevSync Matching System — Architecture, Testing & Flutter Integration Guide

> **Target Audience:** Frontend/Flutter AI agents & engineers integrating with the DevSync Matching Backend.  
> **Backend Version:** `feature/matching-gemini`  
> **Current Test Status:** 158/158 tests passing (`npm test`)  
> **Production Base URL:** `https://devsync-backend-two.vercel.app`  
> **Local Base URL:** `http://10.0.2.2:3000` (Android Emulator) / `http://127.0.0.1:3000` (iOS Simulator, Desktop, Web)

---

## 1. Executive Summary

DevSync Matching provides AI-driven and deterministic developer-to-open-source-project recommendation scoring.
It accepts a developer profile (declared skills, GitHub language metrics, contribution statistics, optional bio/preferences) and candidate projects, analyzes technical compatibility, and returns ranked matches sorted in descending order of compatibility score ($0 - 100$) along with human-readable justifications.

### Key Highlights
- **Dual Scoring Engine:**
  1. **Primary AI Engine:** Google Gemini (`gemini-3.1-flash-lite`, configurable via `GEMINI_MODEL`) using structured JSON schema output and prompt injection defenses.
  2. **Deterministic Fallback Engine:** Pure functional skill-overlap scorer with GitHub language evidence and activity bonuses. Guaranteed zero downtime: if Gemini times out (>4s), rate-limits (429), or is unconfigured, fallback responds seamlessly with `isFallback: true`.
- **Authentication & Security:** Protected by Firebase ID token verification. The caller's authenticated Firebase UID must match the payload `uid`.
- **Hybrid Candidate Sourcing:** Accepts up to 20 candidate projects directly in the request body (client-sourced from Firestore), or automatically queries Firestore `projects` if candidates are omitted.

---

## 2. API Contract Specification

### `POST /matches/generate`

#### HTTP Headers
```http
Content-Type: application/json
Authorization: Bearer <Firebase_ID_Token>
```

> **Important:** The `Authorization` header is mandatory. The backend verifies the token with Firebase Admin SDK and validates that `decodedToken.uid === req.body.uid`.

---

### Request Payload (`MatchRequestModel`)

```json
{
  "uid": "firebase_user_uid_123",
  "declaredSkills": ["Dart", "Flutter", "Firebase"],
  "githubLanguages": {
    "Dart": 45000,
    "JavaScript": 12000
  },
  "publicRepoCount": 15,
  "totalContributions": 450,
  "bio": "Mobile engineer passionate about open source and cross-platform apps.",
  "topRepositories": ["username/awesome_flutter_app", "username/cli_tool"],
  "projects": [
    {
      "projectId": "proj_abc_1",
      "projectName": "Flutter Riverpod Architecture",
      "description": "Clean architecture template using Riverpod state management.",
      "githubUrl": "https://github.com/devsync/flutter-riverpod",
      "neededSkills": ["Flutter", "Dart", "Riverpod"],
      "maintainerId": "other_user_uid_456"
    }
  ],
  "prompt": "I want beginner-friendly Flutter projects with good documentation.",
  "tags": ["mobile", "frontend"]
}
```

#### Field Specifications & Constraints

| Field | Type | Required | Limits / Rules | Description |
|---|---|---|---|---|
| `uid` | `string` | **Yes** | Max 128 chars | Firebase UID. Must match Bearer token UID. |
| `declaredSkills` | `string[]` | **Yes** | Max 100 items, max 100 chars/item | User's self-declared skills. **If empty (`[]`), backend immediately returns zero matches.** |
| `githubLanguages` | `Map<string, int>` | **Yes** | Max 100 languages, non-negative ints | Byte counts per language from GitHub scan. |
| `publicRepoCount` | `int` | **Yes** | $\ge 0$ | Number of public GitHub repositories. |
| `totalContributions` | `int` | **Yes** | $\ge 0$ | Total GitHub contributions (commits, PRs). |
| `bio` | `string?` | Optional | Max 5000 chars | Developer's bio. Sanitized as untrusted data. |
| `topRepositories` | `string[]` | Optional | Max 50 items, max 200 chars/item | User's top repository names (`owner/repo`). |
| `projects` | `object[]?` | Optional | Max 20 candidates | Client-provided project candidates. If omitted, backend queries Firestore `projects`. |
| `prompt` | `string?` | Optional | Max 1000 chars | User custom matching preference (not treated as claimed skills). |
| `tags` | `string[]?` | Optional | Max 30 items, max 100 chars/item | User preference filter tags. |

---

### Response Payload (`MatchResponseModel`)

```json
{
  "matches": [
    {
      "projectId": "proj_abc_1",
      "projectName": "Flutter Riverpod Architecture",
      "description": "Clean architecture template using Riverpod state management.",
      "githubUrl": "https://github.com/devsync/flutter-riverpod",
      "neededSkills": ["Flutter", "Dart", "Riverpod"],
      "score": 92,
      "reason": "Strong match: you have Flutter and Dart, missing Riverpod. Significant GitHub Dart activity detected.",
      "maintainerId": "other_user_uid_456",
      "isFallback": false
    }
  ],
  "promptVersion": "v1.1"
}
```

#### Field Specifications

| Field | Type | Description |
|---|---|---|
| `matches` | `MatchItemModel[]` | Sorted list of matched projects (**descending by `score`**, with deterministic tie-breaking by `projectId`). |
| `matches[].projectId` | `string` | Firestore document ID of the project. |
| `matches[].projectName` | `string` | Project display name. |
| `matches[].description` | `string` | Project description. |
| `matches[].githubUrl` | `string` | Project repository URL. |
| `matches[].neededSkills` | `string[]` | Required project skills (preserves original project casing). |
| `matches[].score` | `number` | Integer/double between $0$ and $100$. |
| `matches[].reason` | `string` | Explanation for the match score. |
| `matches[].maintainerId` | `string?` | UID of the project owner (null if missing). Self-maintained projects are filtered out. |
| `matches[].isFallback` | `bool` | `false` if scored by Gemini; `true` if generated by deterministic fallback engine. |
| `promptVersion` | `string` | Version of prompt/algorithm (e.g. `"v1.1"`). |

---

### HTTP Status Codes & Error Contract

All error responses strictly return `{ "error": "Human-readable message" }`.

| Status Code | Reason | Example Response | Client Handling Recommendation |
|---|---|---|---|
| `200 OK` | Matches successfully generated | `{ "matches": [...], "promptVersion": "v1.1" }` | Render match cards. |
| `400 Bad Request` | Missing required fields, invalid JSON, or exceeding limits | `{ "error": "declaredSkills must be an array" }` | Check request builder. |
| `401 Unauthorized` | Missing token, malformed token, or expired session | `{ "error": "Sign in to generate matches" }` | Refresh Firebase token; if still 401, redirect to Sign In. |
| `403 Forbidden` | Bearer token UID does not match request body `uid` | `{ "error": "Profile does not belong to this session" }` | Ensure `userProfile.uid` matches `FirebaseAuth.instance.currentUser.uid`. |
| `429 Too Many Requests` | Burst rate limit hit (>6 req/min per user or >4 concurrent) | `{ "error": "Please wait before generating more matches" }` | Read `Retry-After` header (default 60s); notify user. |
| `502 Bad Gateway` | Upstream network or serialization issue | `{ "error": "The matching server returned an invalid response" }` | Retry after brief backoff. |
| `503 Service Unavailable`| Firebase Admin SDK not configured on server | `{ "error": "Authentication is unavailable" }` | Server config issue; report to backend ops. |

---

## 3. How the Matching Engine Works

```mermaid
flowchart TD
    A[Flutter App POST /matches/generate] --> B[access.js: Bearer Token Auth]
    B -->|Invalid/Missing Token| B1[401 Unauthorized]
    B -->|Token UID != Body UID| B2[403 Forbidden]
    B -->|Rate limit >6/min or >4 active| B3[429 Too Many Requests]
    B -->|Authorized| C[validation.js: Schema & Bounds Check]
    C -->|Invalid Field/Limit| C1[400 Bad Request]
    C -->|Valid| D{declaredSkills.length == 0?}
    D -->|Yes| D1[Return matches: [], promptVersion: v1.1]
    D -->|No| E[Obtain Candidate Projects]
    E -->|body.projects present| F[Validate & sanitize max 20 candidates]
    E -->|body.projects omitted| G[Fetch from Firestore 'projects' collection, max 20]
    F --> H[Filter out maintainerId == profile.uid]
    G --> H
    H --> I{GEMINI_API_KEY Configured?}
    I -->|Yes| J[Call Gemini Flash-Lite with 4s timeout & Structured Schema]
    I -->|No| K[Deterministic Fallback Scorer scoring.js]
    J -->|Success| L[Validate & Sanitize AI Output]
    J -->|Timeout / 429 / 5xx / Bad JSON| K
    L --> M[completeMatches: fill omitted candidates via fallback]
    K --> N[Sort descending by score, tie-break by projectId]
    M --> N
    N --> O[HTTP 200 JSON Response]
```

### 1. Token Verification & Rate Limiting (`access.js`)
- Validates the Firebase ID token in the `Authorization: Bearer <token>` header.
- Asserts `identity.uid === req.body.uid`.
- Enforces per-instance burst limits:
  - Max **6 requests per minute** per user UID.
  - Max **4 active concurrent requests**.
  - Returns `Retry-After: 60` on 429.

### 2. Request Validation & Normalization (`validation.js`)
- Validates payload against the 32KB Express limit.
- Skill normalization: whitespace trimmed, case-insensitive, canonical alias mapping:
  - `js` $\rightarrow$ `javascript`, `ts` $\rightarrow$ `typescript`, `py` $\rightarrow$ `python`, `golang` $\rightarrow$ `go`
  - `c++` $\rightarrow$ `cpp`, `c#` $\rightarrow$ `csharp`, `reactjs`/`react.js` $\rightarrow$ `react`, `nodejs`/`node.js` $\rightarrow$ `nodejs`
- **Zero-skill rule:** If `declaredSkills` is empty, returns `matches: []` immediately without querying AI or Firestore.

### 3. Candidate Acquisition & Ownership Filtering (`projectFetcher.js` / `controller.js`)
- If `req.body.projects` is supplied, it takes precedence (max 20 candidates, verified unique `projectId`s).
- If not supplied, backend queries Firestore `projects` collection (max 20 candidates).
- **Self-maintenance exclusion:** Any project where `project.maintainerId === profile.uid` is filtered out so developers are not matched with their own projects.

### 4. Primary AI Scoring (`geminiClient.js` + `prompt.js`)
- Model: `gemini-3.1-flash-lite` (default, overridable by `GEMINI_MODEL`).
- Generation parameters: `temperature: 0.3`, `maxOutputTokens: 2048`, `responseMimeType: "application/json"`.
- Timeout: Bound at **4000ms** to prevent client timeouts.
- Structured response schema enforced via Gemini API:
  ```json
  [
    {
      "projectId": "string",
      "score": "integer",
      "reason": "string"
    }
  ]
  ```
- **Prompt Injection Defense:** Bio, descriptions, prompts, and tags are wrapped as untrusted DATA; newlines and instruction delimiters are stripped. Output validation rejects any project IDs not in the candidate list.
- **Candidate Completion (`completeMatches`):** If Gemini drops any project candidate from its response, the backend automatically fills the missing projects using the deterministic fallback engine instead of dropping them.

### 5. Deterministic Fallback Engine (`scoring.js`)
Used when `GEMINI_API_KEY` is missing, or when Gemini times out (>4s), fails, or produces malformed JSON:
- **Skill Overlap Score ($0 - 70$ pts base):** Ratio of project's `neededSkills` covered by user's declared skills (plus supporting GitHub languages).
- **GitHub Activity Bonus ($0 - 10$ pts):**
  - Public repos: $+1$ pt per 5 repos (up to $+5$).
  - Contributions: $+1$ pt per 200 contributions (up to $+5$).
- **No-skills Project Rule:** Projects with no needed skills receive a baseline score of $50$.
- **Reason Generation:** Grounded template strings based on exact matched vs. missing skills (e.g. `"Perfect match: you have Flutter and Dart"`, `"Strong match: you have ... missing ..."`).
- Sets `isFallback: true`.

---

## 4. Test Suite & Verification

The backend test suite is located in `/test` and uses Node's native test runner (`node:test`).
**All 158 tests pass with 0 failures.** All external network calls (Gemini API, Firebase Admin, Firestore, SMTP) are fully mocked.

### Running Backend Tests
```bash
# In devsync_backend directory:
npm test
```

### Test Coverage Breakdown

| Test File | Test Count | Focus Areas Covered |
|---|---|---|
| `test/matching.validation.test.js` | 44 | Request body validation, required/optional fields, bounds checks, skill aliases, string trimming, negative numbers, payload limits. |
| `test/matching.scoring.test.js` | 26 | Fallback scoring formula, 100% matches, partial matches, zero matches, activity bonuses, deterministic tie-breaking, casing preservation. |
| `test/matching.gemini.test.js` | 36 | Gemini client init, prompt building, response validation, score clamping ($0-100$), duplicate ID removal, unknown ID filtering, reason sanitization, `completeMatches`. |
| `test/matching.security.test.js` | 6 | Bearer token auth, expired token handling (401), UID mismatch protection (403), per-user rate limiting (429), concurrency limit release. |
| `test/matching.integration.test.js` | 7 | Full Express HTTP route integration, Firestore fallback query, controller error paths, empty skill handling. |
| `test/regression.test.js` | 39 | Verifies existing `/otp/send`, `/otp/verify`, `/password/reset`, `/email/verify`, `/auth/session`, and `/health` endpoints continue working without regression. |

---

## 5. Flutter App Integration Guide

The Flutter application (`devsync-open-source-collaboration-app`) contains the matching clean architecture feature under `lib/features/matching/`.

### Flutter Architecture Mapping

```
lib/features/matching/
├── data/
│   ├── datasources/
│   │   ├── matching_http_remote_data_source.dart   <-- Calls POST /matches/generate
│   │   ├── auth_token_provider.dart                <-- Supplies Firebase ID token
│   │   └── matching_local_data_source.dart         <-- Caches results locally
│   ├── models/
│   │   ├── match_request_model.dart                <-- Serializes request JSON
│   │   ├── match_response_model.dart               <-- Deserializes { matches, promptVersion }
│   │   └── match_item_model.dart                   <-- Deserializes each match card
│   └── repositories/
│       └── matching_repository_impl.dart           <-- Maps API errors to Domain Failures
├── domain/
│   ├── entities/
│   │   └── match_item.dart                         <-- Domain match entity
│   └── failures/
│       └── matching_failures.dart                  <-- AuthFailure, RateLimitFailure, etc.
└── presentation/
    ├── cubit/matching_cubit.dart                   <-- UI state management
    └── screens/match_feed_screen.dart              <-- Swipeable card feed
```

### 1. Environment & Base URL Configuration

The Flutter app automatically selects the API base:

| Platform / Mode | Command | Resolved Base URL |
|---|---|---|
| **Android Emulator (Local Backend)** | `flutter run --dart-define=DEVSYNC_API_LOCAL=true` | `http://10.0.2.2:3000` |
| **iOS / Desktop / Web (Local Backend)** | `flutter run --dart-define=DEVSYNC_API_LOCAL=true` | `http://127.0.0.1:3000` |
| **Custom Local IP (Physical Device)** | `flutter run --dart-define=DEVSYNC_API_BASE=http://192.168.1.X:3000` | `http://192.168.1.X:3000` |
| **Production (Default)** | `flutter run` | `https://devsync-backend-two.vercel.app` |

### 2. Ensuring Auth Token Propagation
In `MatchingHttpRemoteDataSource`, ensure `AuthTokenProvider` is backed by FirebaseAuth:
```dart
class FirebaseAuthTokenProvider implements AuthTokenProvider {
  final FirebaseAuth _auth;
  FirebaseAuthTokenProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }
}
```

### 3. Candidate Projects Strategy (Client vs Server Sourcing)
There are two supported workflows for candidate projects:

#### Option A: Client-Sourced Candidates (Recommended for customized filtering)
Flutter queries Firestore `projects` collection (e.g. latest 20 active projects), converts them into project maps, and attaches them to `MatchRequestModel`:
```dart
final projects = await firestore.collection('projects').limit(20).get();
// Flutter passes candidate projects in MatchRequestModel
```
**Benefits:** Client controls which projects are considered (e.g. filter by tag, exclude previously rejected projects).

#### Option B: Server-Sourced Candidates (Lightweight Client Request)
Flutter omits the `projects` field in `MatchRequestModel.toJson()`.
```dart
// Flutter sends only user profile:
final request = MatchRequestModel.fromProfile(profile);
```
**Benefits:** Smallest request payload over mobile network; backend loads projects directly from Firestore.

### 4. Handling Empty Matches (`NoMatchesFailure`)
When a user has no declared skills or no projects match:
- Backend returns `{"matches": [], "promptVersion": "v1.1"}`.
- `MatchingRepositoryImpl` converts empty list to `NoMatchesFailure()`.
- Presentation layer (`MatchingCubit` / `MatchFeedScreen`) displays `MatchFeedEmptyState` directing the user to edit their profile and declare skills.

---

## 6. Verification Checklist for the Flutter Agent

- [ ] **Auth Token Check:** Confirm `Authorization: Bearer <token>` is sent on every request.
- [ ] **UID Match:** Confirm `profile.uid` matches the authenticated `currentUser.uid` (avoids 403).
- [ ] **Skills Guard:** Verify user has at least 1 declared skill before making the API call (prevents unnecessary 0-match roundtrip).
- [ ] **Error Handling:** Verify UI handles:
  - `AuthFailure` (401/403) $\rightarrow$ Re-authenticates or prompts sign-in.
  - `RateLimitFailure` (429) $\rightarrow$ Displays friendly "Please wait a moment before finding more matches" message.
  - `ServerFailure` (500/503) $\rightarrow$ Offers a retry button.
- [ ] **Local Testing:** Run backend locally (`npm run dev`) and test with `flutter run --dart-define=DEVSYNC_API_LOCAL=true`.
- [ ] **Card Rendering:** Confirm match card UI displays `projectName`, `score` (0-100), `neededSkills` chips, and `reason` text. Check `isFallback` indicator if telemetry or debug badges are shown.
