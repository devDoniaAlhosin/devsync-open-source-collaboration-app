# DevSync Matching Feature - Testing Guide

## Overview

This guide explains how to test the matching feature end-to-end with real backend integration.

## Architecture Summary

**DevSync uses two backends:**

1. **Firestore (Direct Client SDK)**
   - Projects: `projects/{projectId}` collection
   - Liked matches: `liked_matches/{userId}/matches/{projectId}`
   - User profiles: `users/{uid}`
   - Feedback: `matching_feedback/{documentId}`

2. **Vercel API** (https://devsync-backend-two.vercel.app)
   - Auth OTP operations
   - **Matching: `POST /matches/generate`** (AI-powered scoring)

## Key Principle: No REST API for Projects

**Important:** Projects are stored in **Firestore**, NOT on the Vercel API.

From README:
> "Do **not** add Vercel `POST /projects` or `GET /projects` (or similar) for normal CRUD — wire those features to Firestore the same way auth already upserts `users/{uid}`."

The backend queries Firestore's `projects` collection internally when generating matches.

---

## Prerequisites for Testing

### 1. Firebase Setup

You need access to the team Firebase project with:
- ✅ **Firestore** enabled
- ✅ **Firebase Auth** configured
- ✅ Security rules deployed

### 2. Backend API Access

- Production: https://devsync-backend-two.vercel.app
- Local (optional): Clone `devsync_backend` sibling repo and run `npm run dev`

### 3. Test User Account

Create a Firebase auth user for testing:
```bash
# Via Firebase Console or
firebase auth:import test_user.json
```

---

## Step-by-Step Testing Process

### Step 1: Create Test Projects in Firestore

**Option A: Firebase Console (Easiest)**

1. Open Firebase Console → Firestore Database
2. Create collection: `projects`
3. Add document with auto ID or custom projectId:

```json
{
  "projectId": "flutter-awesome-ui",
  "projectName": "flutter/awesome-ui",
  "description": "Beautiful Flutter UI components library",
  "githubUrl": "https://github.com/flutter/awesome-ui",
  "neededSkills": ["Flutter", "Dart", "UI/UX", "Animation"],
  "maintainerId": "karim-user-id",
  "createdAt": "2024-11-05T10:00:00Z",
  "updatedAt": "2024-11-05T10:00:00Z",
  "isActive": true
}
```

4. Add 3-5 test projects with varied skills

**Option B: Flutter Admin Script (Programmatic)**

Create `scripts/seed_projects.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;
  
  final projects = [
    {
      'projectId': 'flutter-charts',
      'projectName': 'flutter/charts',
      'description': 'Charts library for Flutter with animations',
      'githubUrl': 'https://github.com/flutter/charts',
      'neededSkills': ['Flutter', 'Dart', 'Animation', 'Charts'],
      'maintainerId': 'maintainer-uid-1',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    },
    {
      'projectId': 'firebase-plugins',
      'projectName': 'firebase/plugins',
      'description': 'Flutter plugins for Firebase services',
      'githubUrl': 'https://github.com/firebase/plugins',
      'neededSkills': ['Flutter', 'Dart', 'Firebase', 'Plugin Development'],
      'maintainerId': 'maintainer-uid-2',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    },
    // Add more...
  ];
  
  for (final project in projects) {
    await firestore
        .collection('projects')
        .doc(project['projectId'] as String)
        .set(project);
    print('Created project: ${project['projectName']}');
  }
  
  print('✅ Seeded ${projects.length} projects');
}
```

Run: `dart run scripts/seed_projects.dart`

**Option C: Via Projects Feature (When Built)**

Once the Projects feature is implemented by Bishay, maintainers can add projects via the app UI.

---

### Step 2: Set Up Test User Profile

Ensure your test user has profile data:

**Via Profile Feature:**
1. Sign in to app
2. Go to Profile screen
3. Add skills: `["Flutter", "Dart", "Firebase"]`
4. Add bio (optional)
5. Save profile

**Profile data needed for matching:**
- `skills`: Array of declared skill strings
- `githubUrl`: For fetching GitHub stats
- GitHub data automatically fetched via E01 enhancement

---

### Step 3: Test Matching Flow

#### A. Test Match Generation (HTTP Call)

1. **Open Match Feed Screen**
   - App automatically calls `loadInitialData()`
   - MatchingCubit → GetRankedMatchesUseCase → MatchingRepository

2. **Repository Flow:**
   ```dart
   // Check cache first
   final cached = await _localDataSource.getCachedMatches();
   if (cached.isNotEmpty && cacheValid) return cached;
   
   // Call backend API
   final result = await _remoteDataSource.getMatches(userProfile);
   // POST /matches/generate with UserProfile JSON
   ```

3. **Expected Backend Behavior:**
   - Backend queries Firestore `projects` collection internally
   - Compares user skills with project neededSkills
   - Returns scored matches with reasons
   - Currently returns fallback/stub matches (Gemini not live yet)

4. **Expected Response:**
   ```json
   {
     "matches": [
       {
         "projectId": "flutter-charts",
         "projectName": "flutter/charts",
         "description": "Charts library...",
         "githubUrl": "https://github.com/flutter/charts",
         "neededSkills": ["Flutter", "Dart", "Animation"],
         "score": 85,
         "reason": "Strong match: Flutter, Dart skills overlap",
         "maintainerId": "uid-123",
         "isFallback": false
       }
     ],
     "promptVersion": "v1.0"
   }
   ```

#### B. Test Like/Skip Actions

1. **Like a Match:**
   - Swipe right or tap heart
   - `MatchingCubit.performDeckAction(match, MatchSwipeAction.request)`
   - Saves to Firestore: `liked_matches/{userId}/matches/{projectId}`

2. **Verify in Firestore:**
   - Check `liked_matches/{userId}/matches` collection
   - Should see liked match with `likedAt` timestamp

3. **View Liked Matches:**
   - Navigate to Liked Matches screen
   - Should load from Firestore and display

#### C. Test GitHub Integration (E01)

1. **Profile with GitHub URL:**
   - Ensure profile has `githubUrl` set
   - ProfileRepository fetches top 5 repos via GitHub API

2. **Check topRepositories Field:**
   - Match request should include `topRepositories` array
   - Check network logs or debug print in `MatchingHttpRemoteDataSource`

3. **Expected:**
   ```json
   {
     "uid": "user-123",
     "declaredSkills": ["Flutter", "Dart"],
     "githubLanguages": {"Dart": 60, "Python": 20},
     "publicRepoCount": 15,
     "totalContributions": 500,
     "bio": "Mobile developer",
     "topRepositories": [
       "https://github.com/user/flutter-app",
       "https://github.com/user/dart-utils"
     ]
   }
   ```

---

### Step 4: Test Firestore Persistence (E02)

#### Liked Matches Persistence

1. **Like multiple projects**
2. **Close app completely**
3. **Reopen app**
4. **Navigate to Liked Matches**
5. **Expected:** All previously liked matches still visible

#### Cross-Device Sync

1. **Sign in on Device A**, like Project X
2. **Sign in on Device B** (same user)
3. **Navigate to Liked Matches**
4. **Expected:** Project X appears (synced via Firestore)

#### Offline Behavior

1. **Enable Airplane Mode**
2. **Open Liked Matches screen**
3. **Expected:** Shows cached likes (Firestore offline persistence)
4. **Like a new project while offline**
5. **Re-enable network**
6. **Expected:** Like syncs to Firestore automatically

---

### Step 5: Test Error Scenarios

#### No Auth Token

```dart
// Force sign out
await FirebaseAuth.instance.signOut();
// Try to load matches
// Expected: MatchingError with auth failure message
```

#### Empty Projects Collection

1. Delete all projects from Firestore
2. Try to load matches
3. **Expected:** Empty matches array or fallback matches

#### Backend Unreachable

1. Use invalid API URL: `--dart-define=DEVSYNC_API_BASE=http://invalid.url`
2. Try to load matches
3. **Expected:** NetworkFailure error, graceful degradation

#### Rate Limit (429)

Trigger rate limit on backend API (if implemented).
**Expected:** RateLimitFailure error

---

## Debugging Tools

### 1. Flutter DevTools - Network Tab

Monitor HTTP requests:
```bash
flutter run --dart-define=DEVSYNC_API_BASE=https://devsync-backend-two.vercel.app
# Open DevTools → Network
# Watch POST /matches/generate requests
```

### 2. Firebase Console - Firestore Tab

Real-time data viewing:
- Navigate to Firestore Database
- Watch `projects`, `liked_matches`, `matching_feedback` collections
- Verify data structure matches schemas

### 3. Add Debug Logging

```dart
// In matching_http_remote_data_source.dart
print('🔍 Matching Request: ${jsonEncode(requestModel.toJson())}');
print('✅ Matching Response: ${response.statusCode} - $body');
```

### 4. Charles Proxy / Proxyman

Intercept HTTPS traffic:
- Install SSL certificate
- Monitor requests to `devsync-backend-two.vercel.app`
- Inspect request/response payloads

---

## Testing Checklist

### ✅ E01: GitHub API Integration
- [ ] Profile loads GitHub URL
- [ ] Top 5 repos fetched from GitHub API
- [ ] `topRepositories` field populated in match request
- [ ] Graceful handling of GitHub rate limits

### ✅ E02: Firestore Persistence
- [ ] Liked matches save to Firestore
- [ ] Liked matches persist across app restarts
- [ ] Liked matches sync across devices
- [ ] Offline likes work (cache + sync when online)

### 🔄 Core Matching Flow
- [ ] Match generation calls `POST /matches/generate`
- [ ] Backend returns scored matches
- [ ] UI displays match cards with score + reason
- [ ] Empty state shown when no matches
- [ ] Loading state shows during API call

### 🔄 Auth Integration
- [ ] Firebase ID token attached to requests
- [ ] 401/403 triggers token refresh
- [ ] Unauthenticated users cannot load matches

### 🔄 Error Handling
- [ ] Network errors show user-friendly message
- [ ] Auth errors prompt sign-in
- [ ] Empty results show appropriate empty state
- [ ] Retry button works for retryable errors

---

## Backend Status (As of README)

### ✅ Implemented
- Firebase Auth + Firestore infrastructure
- DevSync API on Vercel
- Auth OTP endpoints (verify email, forgot password, sign in with code)
- `POST /matches/generate` endpoint (stub/fallback today)

### ⏳ Not Yet Implemented
- Live Gemini AI matching (currently returns fallback matches)
- Prompt quality analytics tracking
- Projects feature UI (Bishay's task, due W2)
- FCM notifications
- Collaboration requests feature

### 🎯 For Full Production Testing

You'll need:
1. **Projects created in Firestore** (manually or via Projects feature)
2. **Backend Gemini integration complete** (Emad's task, `feature/matching-gemini` branch)
3. **Security rules deployed** (Donia's task, due 12 Nov)

---

## Quick Test Script

```bash
# 1. Start with clean state
firebase firestore:delete projects --all-collections -f

# 2. Seed test projects (run your seed script)
dart run scripts/seed_projects.dart

# 3. Run app
flutter run

# 4. Test flow:
#    - Sign in
#    - Navigate to Profile → add skills
#    - Navigate to Matches → load matches
#    - Like a project
#    - Check Firestore for liked match
#    - Navigate to Liked Matches → verify
```

---

## Known Limitations (Current State)

1. **Gemini AI not live:** Backend returns deterministic/fallback matches based on skill overlap
2. **Projects feature not built:** Need to create projects manually in Firestore
3. **No analytics:** Prompt quality tracking (E04) not implemented
4. **No caching:** Match caching (E03) not implemented yet
5. **Mock GitHub data:** GitHub integration (E01) uses FakeGitHubApiDataSource by default in DI

---

## Next Steps

After completing current enhancements (E01, E02):
- ✅ E01: GitHub API - DONE
- ✅ E02: Firestore Persistence - DONE
- ⏳ E03: Caching Strategy with TTL
- ⏳ E04: Analytics Tracking
- ⏳ E05: Error UX Improvements

Then ready for M08 (integration testing with live backend).

---

## Support

- **Backend repo:** `devsync_backend` (sibling repository, READ ONLY)
- **API docs:** Check backend README for `/matches/generate` contract
- **Team owners:** Emad (AI matching), Bishay (Projects), Donia (Security rules)
- **Testing lead:** Saga (Quality & Release)

