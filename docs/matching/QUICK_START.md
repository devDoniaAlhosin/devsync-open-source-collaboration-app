# DevSync Matching Feature - Quick Start Guide

## Overview

This guide gets you from zero to testing the matching feature in under 10 minutes.

## Prerequisites

- ✅ Flutter SDK installed
- ✅ Firebase project configured
- ✅ Android emulator or iOS simulator running
- ✅ Backend repository cloned (optional for local testing)

---

## Option 1: Test with Production Backend (Fastest)

### Step 1: Run the App

```bash
cd "e:\project flutter\devsync-open-source-collaboration-app"
flutter pub get
flutter run
```

### Step 2: Sign In

1. App launches to sign-in screen
2. Sign in with your test account
3. Wait for Firebase authentication

### Step 3: Set Up Profile

1. Navigate to Profile screen
2. Add at least 3 skills (e.g., "Flutter", "Dart", "Firebase")
3. Verify GitHub connection (if available)
4. Save profile

### Step 4: Generate Matches

1. Navigate to Matching screen
2. Tap "Find Matches" button
3. Wait 2-5 seconds for AI matching
4. View match cards

### Step 5: Test Cache

1. Swipe through some matches
2. Navigate away and back to Matching screen
3. Matches should load instantly (<100ms) from cache
4. ✅ **Cache is working!**

### Step 6: Test Error Handling

**Test Rate Limiting:**
```dart
// Tap "Find Matches" 7 times rapidly
// Should show friendly error after 6th attempt
```

**Test Empty Skills:**
```dart
// Remove all skills from profile
// Try to generate matches
// Should show "Add skills to find matches"
```

**Test Network Error:**
```dart
// Enable airplane mode
// Try to generate matches
// Should show "No internet connection"
```

---

## Option 2: Test with Local Backend (Full Control)

### Step 1: Start Local Backend

```bash
cd ../devsync_backend
npm install
npm run dev
```

You should see:
```
Server listening on port 3000
```

### Step 2: Run Flutter with Local Backend

**For Android Emulator:**
```bash
flutter run --dart-define=DEVSYNC_API_LOCAL=true
```

**For iOS Simulator:**
```bash
flutter run --dart-define=DEVSYNC_API_LOCAL=true
```

**For Physical Device (on same network):**
```bash
# Find your computer's IP address
# Windows: ipconfig
# Mac/Linux: ifconfig

flutter run --dart-define=DEVSYNC_API_BASE=http://192.168.1.X:3000
```

### Step 3: Verify Backend Connection

Check backend console for incoming requests:
```
POST /matches/generate
Status: 200
Matches returned: 5
```

### Step 4: Test Gemini AI vs Fallback

**Test Gemini AI (if GEMINI_API_KEY configured):**
```bash
# Backend should log:
# "Using Gemini AI scorer"
# Check match cards for isFallback: false
```

**Test Fallback (no API key or timeout):**
```bash
# Backend should log:
# "Using deterministic fallback scorer"
# Check match cards for isFallback: true
```

---

## Option 3: Create Test Projects in Firestore

### Manual Method (Firebase Console)

1. Open Firebase Console
2. Go to Firestore Database
3. Create collection: `projects`
4. Add documents with this structure:

```json
{
  "projectId": "flutter-toolkit-001",
  "projectName": "Flutter Dev Toolkit",
  "description": "A collection of Flutter development utilities and helpers",
  "githubUrl": "https://github.com/example/flutter-toolkit",
  "neededSkills": ["Flutter", "Dart"],
  "maintainerId": "different_user_uid_123",
  "status": "active",
  "createdAt": "2024-11-05T12:00:00Z"
}
```

**Create 5-10 test projects with various skills:**
- Flutter + Dart
- React + JavaScript
- Python + Django
- Go + Docker
- etc.

### Programmatic Method (Dart Script)

Create `scripts/seed_test_projects.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  final testProjects = [
    {
      'projectId': 'flutter-toolkit-001',
      'projectName': 'Flutter Dev Toolkit',
      'description': 'A collection of Flutter development utilities',
      'githubUrl': 'https://github.com/example/flutter-toolkit',
      'neededSkills': ['Flutter', 'Dart'],
      'maintainerId': 'test_maintainer_1',
      'status': 'active',
    },
    {
      'projectId': 'react-dashboard-002',
      'projectName': 'Admin Dashboard Template',
      'description': 'Modern React admin dashboard with charts',
      'githubUrl': 'https://github.com/example/react-dashboard',
      'neededSkills': ['React', 'JavaScript', 'CSS'],
      'maintainerId': 'test_maintainer_2',
      'status': 'active',
    },
    {
      'projectId': 'python-ml-003',
      'projectName': 'Machine Learning Library',
      'description': 'Python library for common ML tasks',
      'githubUrl': 'https://github.com/example/ml-lib',
      'neededSkills': ['Python', 'TensorFlow', 'NumPy'],
      'maintainerId': 'test_maintainer_3',
      'status': 'active',
    },
    // Add more projects...
  ];

  for (final project in testProjects) {
    await firestore.collection('projects').doc(project['projectId'] as String).set(project);
    print('Created project: ${project['projectName']}');
  }

  print('✅ Seeded ${testProjects.length} test projects');
}
```

Run:
```bash
dart run scripts/seed_test_projects.dart
```

---

## Troubleshooting Quick Fixes

### Issue: "No matches found"

**Possible causes:**
1. No projects in Firestore → Create test projects (see above)
2. No declared skills → Add skills to profile
3. All projects self-maintained → Use different maintainerIds

**Fix:**
```dart
// Add skills to profile
Profile → Edit → Add Skills: ["Flutter", "Dart", "Firebase"]

// Create projects with different maintainerId
// (not your current user UID)
```

### Issue: "Please sign in to find matches"

**Cause:** Not authenticated

**Fix:**
```dart
// Sign in first
Auth → Sign In → Use test account
```

### Issue: Cache not working (always slow)

**Possible causes:**
1. Profile changing between requests
2. Cache disabled

**Fix:**
```dart
// Check cache config
print(MatchingCacheConfig().enabled); // Should be true
print(MatchingCacheConfig().ttl); // Should be 1 hour

// Verify profile stable
// Don't change skills between match requests
```

### Issue: "Rate limit exceeded"

**Cause:** Too many requests (>6/min)

**Fix:**
```dart
// Wait 60 seconds before retrying
// Or restart backend to reset limits
```

### Issue: Backend not connecting (local)

**Possible causes:**
1. Wrong IP address for physical device
2. Firewall blocking port 3000
3. Backend not running

**Fix:**
```bash
# Verify backend running
curl http://localhost:3000/health
# Should return: { "status": "ok" }

# Check Flutter is using correct URL
flutter run -v | grep "DEVSYNC_API"
```

---

## Testing Checklist

Use this checklist to verify all features work:

### Basic Flow
- [ ] App launches successfully
- [ ] User can sign in with Firebase
- [ ] Profile screen loads
- [ ] User can add/edit skills
- [ ] Matching screen accessible

### Match Generation
- [ ] "Find Matches" button works
- [ ] Loading state shows (2-5s)
- [ ] Match cards display correctly
- [ ] Can swipe through matches
- [ ] Match details show (name, score, skills, reason)

### Cache Performance
- [ ] First load: 2-5 seconds (API call)
- [ ] Second load: <100ms (cache hit)
- [ ] Cache invalidates when profile changes
- [ ] Cache persists after app restart

### Error Handling
- [ ] Rate limit (6+ requests) shows friendly message
- [ ] Empty skills shows "Add skills" message
- [ ] Network error (airplane mode) shows connection error
- [ ] Retry button works after error
- [ ] Auth error redirects to sign in

### Liked Matches
- [ ] Can like/save matches
- [ ] Saved matches appear in Liked screen
- [ ] Saved matches persist after app restart
- [ ] Can remove liked matches

### Backend Integration
- [ ] Gemini AI scoring works (check logs)
- [ ] Fallback scoring works (disable API key)
- [ ] isFallback flag correct in UI
- [ ] promptVersion tracked correctly

---

## Performance Benchmarks

Expected performance metrics:

| Operation | Expected Time | Threshold |
|-----------|--------------|-----------|
| First match load (API) | 2-5 seconds | <10s |
| Cache hit load | <100ms | <500ms |
| Swipe animation | 60 FPS | >30 FPS |
| Profile save | <2 seconds | <5s |
| Sign in | <3 seconds | <10s |

If any operation exceeds threshold, investigate.

---

## Next Steps After Testing

### 1. Monitor Performance
```dart
// Add timing logs
final stopwatch = Stopwatch()..start();
await matchingCubit.generateMatches();
print('Match generation took: ${stopwatch.elapsedMilliseconds}ms');
```

### 2. Track Cache Hit Rate
```dart
// Log cache hits vs misses
if (cachedMatches != null) {
  print('Cache HIT');
} else {
  print('Cache MISS');
}
```

### 3. Monitor Backend Logs
```bash
# In backend console, watch for:
# - 429 rate limit responses
# - Gemini timeout/failures
# - Fallback scorer activations
```

### 4. Test with Real Users
- Invite beta testers
- Collect feedback on match quality
- Monitor for errors in production
- Track user engagement metrics

---

## Advanced Testing Scenarios

### Test Profile Hash Invalidation

```dart
// 1. Generate matches (cache miss)
await matchingCubit.generateMatches();

// 2. Generate again immediately (cache hit)
await matchingCubit.generateMatches();

// 3. Change profile (add skill)
await profileCubit.updateProfile(
  skills: [...profile.skills, 'NewSkill']
);

// 4. Generate again (cache miss - profile changed)
await matchingCubit.generateMatches();
```

### Test Concurrent Requests

```dart
// Fire 4 concurrent requests (at backend limit)
await Future.wait([
  matchingCubit.generateMatches(),
  matchingCubit.generateMatches(),
  matchingCubit.generateMatches(),
  matchingCubit.generateMatches(),
]);

// 5th concurrent request should queue or fail gracefully
```

### Test Token Refresh

```dart
// 1. Generate matches (works)
await matchingCubit.generateMatches();

// 2. Manually expire token
await FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh: true);

// 3. Generate matches again (should auto-refresh token)
await matchingCubit.generateMatches();
```

---

## Getting Help

If you encounter issues:

1. **Check documentation:**
   - `docs/matching/BACKEND_INTEGRATION.md`
   - `docs/matching/CACHING_GUIDE.md`
   - `docs/matching/TESTING_GUIDE.md`

2. **Check backend logs:**
   ```bash
   # Local: Console output
   # Production: Vercel logs dashboard
   ```

3. **Check Flutter logs:**
   ```bash
   flutter logs
   ```

4. **Common error patterns:**
   - 401 → Not signed in or token expired
   - 403 → UID mismatch
   - 429 → Rate limited (wait 60s)
   - Empty matches → No projects or no skills

---

## Success Criteria

You've successfully tested the matching feature when:

✅ Matches generate in 2-5 seconds (first time)  
✅ Matches load in <100ms (cached)  
✅ Cache invalidates when profile changes  
✅ Error messages are user-friendly  
✅ Retry works after errors  
✅ Liked matches persist  
✅ No crashes or freezes  
✅ Performance within benchmarks  

**Congratulations! The matching feature is working. 🎉**

---

## Quick Reference

### Commands
```bash
# Run with production backend
flutter run

# Run with local backend (Android)
flutter run --dart-define=DEVSYNC_API_LOCAL=true

# Run with custom backend
flutter run --dart-define=DEVSYNC_API_BASE=http://IP:3000

# Run tests
flutter test test/features/matching/

# Start backend
cd ../devsync_backend && npm run dev
```

### Key URLs
- Production: `https://devsync-backend-two.vercel.app`
- Local Android: `http://10.0.2.2:3000`
- Local iOS: `http://127.0.0.1:3000`

### Key Collections
- Projects: `projects/{projectId}`
- Liked Matches: `liked_matches/{userId}/matches/{projectId}`
- Match Cache: `matches_cache/{userId}`

### Performance Targets
- API call: 2-5s
- Cache hit: <100ms
- Cache hit rate: ~90%
- Rate limit: 6 req/min
