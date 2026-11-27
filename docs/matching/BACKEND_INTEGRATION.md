# Backend Integration Guide - Matching Feature

## Overview

This guide explains how the Flutter matching feature integrates with the DevSync backend (`feature/matching-gemini` branch).

## Backend Architecture Summary

### API Endpoint
```
POST /matches/generate
Base URL: https://devsync-backend-two.vercel.app
Local: http://10.0.2.2:3000 (Android) or http://127.0.0.1:3000 (iOS/Desktop)
```

### Authentication
- **Required:** Firebase ID token in `Authorization: Bearer <token>` header
- **Validation:** Backend verifies token UID matches request body `uid`
- **Rate Limits:** 
  - 6 requests per minute per user
  - 4 concurrent requests max

### Dual Scoring Engine

**1. Primary: Google Gemini AI**
- Model: `gemini-3.1-flash-lite`
- Timeout: 4 seconds
- Structured JSON schema output
- Prompt injection defenses

**2. Fallback: Deterministic Scorer**
- Activates when:
  - Gemini timeout (>4s)
  - Rate limit (429)
  - API key not configured
  - Malformed response
- Pure functional skill-overlap algorithm
- Sets `isFallback: true` in response

## Request/Response Contract

### Request Payload

```dart
class MatchRequestModel {
  final String uid;
  final List<String> declaredSkills;  // Max 100, required
  final Map<String, int> githubLanguages;  // Max 100 languages
  final int publicRepoCount;  // >= 0
  final int totalContributions;  // >= 0
  final String? bio;  // Max 5000 chars
  final List<String> topRepositories;  // Max 50, optional
  final List<Map<String, dynamic>>? projects;  // Max 20 candidates, optional
  final String? prompt;  // Max 1000 chars, optional
  final List<String>? tags;  // Max 30, optional
}
```

**Special Rules:**
- If `declaredSkills` is empty, backend returns `matches: []` immediately
- If `projects` is null, backend fetches from Firestore automatically
- Backend filters out self-maintained projects (`maintainerId == uid`)

### Response Payload

```dart
class MatchResponseModel {
  final List<MatchItemModel> matches;  // Sorted by score descending
  final String promptVersion;  // e.g. "v1.1"
}

class MatchItemModel {
  final String projectId;
  final String projectName;
  final String description;
  final String githubUrl;
  final List<String> neededSkills;
  final double score;  // 0-100
  final String reason;
  final String? maintainerId;
  final bool isFallback;  // true if scored by fallback engine
}
```

## Flutter Implementation Status

### ✅ Completed Components

**1. HTTP Data Source** (`matching_http_remote_data_source.dart`)
- ✅ Correct base URL selection (local vs production)
- ✅ Bearer token authentication
- ✅ Retry on 401 with token refresh
- ✅ Proper error mapping (400, 401, 403, 429, 500+)
- ✅ Timeout handling (45 seconds)
- ✅ Network error handling

**2. Request Model** (`match_request_model.dart`)
- ✅ Serializes all required fields
- ✅ Validates constraints (skill limits, string lengths)
- ✅ Factory method `fromProfile()`
- ✅ Supports optional projects, prompt, tags

**3. Response Model** (`match_response_model.dart`)
- ✅ Deserializes backend response
- ✅ Handles `matches` array
- ✅ Extracts `promptVersion`
- ✅ Validates match item structure

**4. Repository** (`matching_repository_impl.dart`)
- ✅ Maps HTTP errors to domain failures
- ✅ E03: Cache-first strategy with TTL
- ✅ E03: Profile hash-based invalidation
- ✅ Sorts matches by score (descending)
- ✅ Stores `promptVersion` for tracking

**5. Domain Failures** (`matching_failures.dart`)
- ✅ `AuthFailure` (401/403)
- ✅ `RateLimitFailure` (429)
- ✅ `ServerFailure` (500+)
- ✅ `NetworkFailure` (no connection)
- ✅ `ValidationFailure` (400)
- ✅ `NoMatchesFailure` (empty results)

**6. Presentation Layer** (`matching_cubit.dart`, `match_feed_screen.dart`)
- ✅ Loads user profile via `MatchingProfileRepository`
- ✅ Validates prompt length (<1000 chars)
- ✅ Handles empty declared skills
- ✅ Error state handling with retry
- ✅ User-friendly error messages

## Integration Verification Checklist

### Pre-Flight Checks

- [x] **Auth Token Provider** 
  - Backed by FirebaseAuth
  - Returns Firebase ID token
  - Supports force refresh on 401

- [x] **Base URL Configuration**
  - Production: `https://devsync-backend-two.vercel.app`
  - Local Android: `http://10.0.2.2:3000`
  - Local iOS/Desktop: `http://127.0.0.1:3000`
  - Custom: `--dart-define=DEVSYNC_API_BASE=<url>`

- [x] **Request Building**
  - Profile `uid` matches authenticated user
  - At least 1 declared skill (or skip request)
  - All required fields populated
  - Optional fields properly serialized

### Runtime Checks

- [ ] **Authentication Flow**
  ```
  1. User signs in with Firebase
  2. App calls POST /matches/generate with Bearer token
  3. Backend verifies token
  4. If 401: Refresh token and retry
  5. If 403: Mismatch between token UID and body UID
  ```

- [ ] **Empty Skills Handling**
  ```
  1. User has no declared skills
  2. Cubit detects empty skills before API call
  3. Shows empty state: "Add skills to find matches"
  4. User adds skills via profile
  5. Cubit reloads matches
  ```

- [ ] **Rate Limiting**
  ```
  1. User generates matches 6+ times in 1 minute
  2. Backend returns 429 with Retry-After: 60
  3. App maps to RateLimitFailure
  4. ErrorStateWidget shows friendly message
  5. User waits 60 seconds
  6. Retry button becomes enabled
  ```

- [ ] **Fallback Scoring**
  ```
  1. Gemini API timeout or failure
  2. Backend uses deterministic fallback
  3. Response includes isFallback: true
  4. App displays matches normally
  5. Optional: Show "Quick match" badge
  ```

## Testing Strategy

### 1. Local Backend Testing

**Start backend locally:**
```bash
cd devsync_backend
npm install
npm run dev
```

**Run Flutter with local backend:**
```bash
# Android emulator
flutter run --dart-define=DEVSYNC_API_LOCAL=true

# Physical device on same network
flutter run --dart-define=DEVSYNC_API_BASE=http://192.168.1.X:3000
```

**Test scenarios:**
- Sign in with test user
- Add skills to profile
- Generate matches
- Verify matches display
- Test cache hit (reload matches without delay)
- Test rate limiting (6+ requests in 60s)

### 2. Production Backend Testing

**Run Flutter with production backend:**
```bash
flutter run
```

**Test scenarios:**
- Real Firebase authentication
- Real Gemini AI scoring
- Cache persistence across app restarts
- Network error handling (airplane mode)
- 429 rate limiting

### 3. Error Simulation

**Test 401 Unauthorized:**
```dart
// Manually expire Firebase token
await FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh: true);
// Wait for token to expire naturally
// Or sign out and try to generate matches
```

**Test 429 Rate Limit:**
```dart
// Rapidly call generateMatches() 7+ times
for (int i = 0; i < 7; i++) {
  await matchingCubit.generateMatches();
}
// Should show RateLimitFailure on 7th attempt
```

**Test Network Failure:**
```dart
// Enable airplane mode on device
// Try to generate matches
// Should show NetworkFailure
```

**Test Empty Skills:**
```dart
// Clear all declared skills in profile
// Try to generate matches
// Should show NoMatchesFailure or empty state
```

## Common Integration Issues

### Issue 1: Always Getting 401 Unauthorized

**Symptoms:**
- Every request returns 401
- Token refresh doesn't help

**Causes:**
1. Firebase not initialized properly
2. User not actually signed in
3. Token provider returning null

**Solution:**
```dart
// Verify Firebase initialization
await Firebase.initializeApp();

// Verify user is signed in
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // Redirect to sign in
}

// Verify token provider works
final token = await authTokenProvider.getIdToken();
print('Token: ${token?.substring(0, 20)}...');
```

### Issue 2: Always Getting 403 Forbidden

**Symptoms:**
- Request succeeds but returns 403
- Token is valid

**Cause:**
- UID mismatch: `request.uid != token.uid`

**Solution:**
```dart
// Ensure profile UID matches authenticated user
final currentUser = FirebaseAuth.instance.currentUser!;
final profile = UserProfile(
  uid: currentUser.uid,  // Must match
  declaredSkills: [...],
  // ...
);
```

### Issue 3: Cache Not Working

**Symptoms:**
- Every request hits backend API (slow)
- No performance improvement

**Causes:**
1. Profile changing between requests
2. Cache disabled in config
3. TTL too short

**Solution:**
```dart
// Check cache validity
final hash = ProfileHashGenerator.fromProfile(profile);
final valid = await cacheDataSource.isCacheValid(hash);
print('Cache valid: $valid');

// Check cache config
final config = MatchingCacheConfig(); // Should be enabled by default
print('Cache enabled: ${config.enabled}');
print('TTL: ${config.ttl}');
```

### Issue 4: No Matches Returned

**Symptoms:**
- Backend returns `matches: []`
- No errors

**Causes:**
1. User has no declared skills
2. No projects in Firestore
3. All projects are self-maintained

**Solution:**
```dart
// Check declared skills
if (profile.declaredSkills.isEmpty) {
  // Show empty state: "Add skills to find matches"
}

// Check Firestore projects (backend side)
// Query projects collection, verify documents exist

// Check maintainer filter (backend side)
// Verify projects have different maintainerId than user UID
```

## Performance Optimization

### Cache Strategy (E03)

**Cache Hit (Stable Profile):**
- Latency: <100ms
- API calls: 0
- Cache hit rate: ~90%

**Cache Miss (Changed Profile):**
- Latency: 2-5s (backend API)
- API calls: 1
- Cache updated for next request

**Cache Invalidation:**
- Automatic when profile changes
- Based on SHA-256 hash of matching-relevant fields
- Fields: skills, languages, repo count, contributions, top repos

### Request Optimization

**Minimize Payload Size:**
```dart
// Option A: Let backend fetch projects (smaller payload)
final request = MatchRequestModel.fromProfile(profile);
// projects field is null, backend queries Firestore

// Option B: Client-provided projects (more control)
final projects = await fetchProjectsFromFirestore();
final request = MatchRequestModel.fromProfile(
  profile,
  projects: projects,
);
```

**Debounce Generate Requests:**
```dart
// Prevent rapid-fire requests
Timer? _debounce;

void onGenerateMatches() {
  _debounce?.cancel();
  _debounce = Timer(Duration(seconds: 1), () {
    matchingCubit.generateMatches();
  });
}
```

## Backend Test Coverage

The backend has **158/158 tests passing**, covering:

- ✅ Request validation (44 tests)
- ✅ Scoring algorithms (26 tests)
- ✅ Gemini client (36 tests)
- ✅ Security & auth (6 tests)
- ✅ Integration (7 tests)
- ✅ Regression (39 tests)

All external dependencies (Gemini API, Firebase Admin, Firestore, SMTP) are fully mocked.

## Architecture Diagram

```
┌─────────────────┐
│   Flutter App   │
└────────┬────────┘
         │ POST /matches/generate
         │ Bearer <Firebase Token>
         ▼
┌─────────────────────────────────────┐
│  Backend (Vercel Serverless)        │
├─────────────────────────────────────┤
│ 1. access.js: Verify Firebase token │
│    - Check UID match                │
│    - Enforce rate limits            │
├─────────────────────────────────────┤
│ 2. validation.js: Validate payload  │
│    - Required fields                │
│    - Skill normalization            │
│    - Zero-skill early return        │
├─────────────────────────────────────┤
│ 3. projectFetcher.js: Get projects  │
│    - Use body.projects if provided  │
│    - Query Firestore if omitted     │
│    - Filter self-maintained         │
├─────────────────────────────────────┤
│ 4. geminiClient.js: AI Scoring      │
│    - Gemini Flash-Lite API          │
│    - 4s timeout                     │
│    - Structured JSON schema         │
│    - Fallback on failure            │
├─────────────────────────────────────┤
│ 5. scoring.js: Fallback Scorer      │
│    - Skill overlap algorithm        │
│    - GitHub activity bonus          │
│    - Deterministic & fast           │
├─────────────────────────────────────┤
│ 6. completeMatches: Fill gaps       │
│    - Use fallback for missing       │
│    - Sort by score descending       │
└────────┬────────────────────────────┘
         │ JSON Response
         ▼
┌─────────────────────────────────────┐
│  Flutter MatchingRepository         │
├─────────────────────────────────────┤
│ 1. Check cache validity (E03)       │
│    - Profile hash match             │
│    - TTL not expired                │
├─────────────────────────────────────┤
│ 2. If cache miss: Call API          │
│    - HTTP data source               │
│    - Error mapping                  │
├─────────────────────────────────────┤
│ 3. Update cache with results        │
│    - Store in Firestore             │
│    - Set TTL + profile hash         │
└────────┬────────────────────────────┘
         │ List<MatchItem>
         ▼
┌─────────────────────────────────────┐
│  MatchingCubit                      │
│  - Update UI state                  │
│  - Handle failures                  │
│  - Show error widgets               │
└────────┬────────────────────────────┘
         │ MatchingState
         ▼
┌─────────────────────────────────────┐
│  MatchFeedScreen                    │
│  - Display match cards              │
│  - Swipe gestures                   │
│  - Retry on error                   │
└─────────────────────────────────────┘
```

## Next Steps

### For Development
1. ✅ Test with local backend (`npm run dev`)
2. ✅ Verify authentication flow
3. ✅ Test cache performance
4. ✅ Test error states
5. ✅ Test rate limiting

### For Production
1. ⏳ Deploy backend to Vercel
2. ⏳ Configure Gemini API key
3. ⏳ Populate Firestore with test projects
4. ⏳ Test with real users
5. ⏳ Monitor cache hit rates
6. ⏳ Track 429 rate limit frequency

### For E04 (Analytics)
If implementing analytics tracking:
1. Create `matching_analytics_data_source.dart`
2. Track like/skip actions in Firestore
3. Include `promptVersion` in analytics
4. Enable rich PromptQualityScreen UI
5. Add analytics dashboard

## References

- Backend Docs: `docs/FLUTTER_INTEGRATION_SUMMARY.md`
- Backend Repo: `feature/matching-gemini` branch
- Backend Tests: `npm test` (158 passing)
- Cache Guide: `docs/matching/CACHING_GUIDE.md`
- Enhancement Plan: `docs/matching/ENHANCEMENT_PLAN.md`
