# DevSync Matching Cache Guide

## Overview

The matching feature implements a **cache-first strategy** with TTL (Time To Live) to reduce backend API calls and improve performance. Match results are cached in Firestore with automatic invalidation when the user's profile changes.

## Architecture

### Cache Flow

```
User requests matches
    ↓
Generate profile hash
    ↓
Check cache validity (hash + TTL)
    ↓
Cache valid? ──Yes──> Return cached matches
    ↓ No
Fetch from backend API
    ↓
Update cache with new results
    ↓
Return fresh matches
```

## Components

### 1. FirestoreMatchingCacheDataSource

**Location:** `lib/features/matching/data/datasources/matching_cache_data_source.dart`

**Responsibilities:**
- Store match results in Firestore
- Check cache validity (TTL + profile hash)
- Retrieve cached matches
- Clear cache when needed

**Key Methods:**
```dart
// Get cached matches if available and valid
Future<List<MatchItemModel>?> getCachedMatches();

// Cache matches with profile hash
Future<void> cacheMatches(
  List<MatchItemModel> matches,
  {required String profileHash}
);

// Check if cache is still valid
Future<bool> isCacheValid(
  String profileHash,
  {Duration ttl = const Duration(hours: 1)}
);

// Clear cached matches
Future<void> clearCache();
```

### 2. ProfileHashGenerator

**Location:** `lib/features/matching/data/utils/profile_hash.dart`

**Purpose:** Generate a deterministic hash from profile fields that affect matching.

**Hashed Fields:**
- `declaredSkills` (sorted)
- `githubLanguages` (sorted by key)
- `publicRepoCount`
- `totalContributions`
- `topRepositories` (sorted)

**Algorithm:** SHA-256

**Example:**
```dart
final profile = Profile(...);
final hash = ProfileHashGenerator.fromProfile(profile);
// hash: "abc123def456..." (64-character hex string)
```

### 3. MatchingCacheConfig

**Location:** `lib/features/matching/domain/models/cache_config.dart`

**Configuration Options:**
```dart
// Default: 1-hour TTL, enabled
const config = MatchingCacheConfig();

// Custom TTL
const config = MatchingCacheConfig.withTtl(Duration(minutes: 30));

// Disabled cache
const config = MatchingCacheConfig.disabled();
```

## Cache Schema

### Firestore Structure

```
matches_cache/
  {userId}/
    matches: [
      {
        projectId: "proj-123",
        projectName: "Flutter Toolkit",
        description: "A toolkit for Flutter developers",
        githubUrl: "https://github.com/example/toolkit",
        neededSkills: ["Flutter", "Dart"],
        score: 95,
        reason: "Strong match based on your Flutter experience",
        maintainerId: "maintainer-456",
        isFallback: false
      },
      ...
    ]
    cachedAt: Timestamp(2024-11-05T12:00:00Z)
    profileHash: "abc123def456..."
    ttl: 3600
```

### Security Rules

```javascript
match /matches_cache/{userId} {
  allow read, write: if request.auth != null 
    && request.auth.uid == userId;
}
```

## Cache Invalidation

Cache is invalidated when:

1. **TTL expires** (default: 1 hour)
2. **Profile changes** (detected via hash mismatch)
   - User adds/removes skills
   - GitHub repo count changes
   - GitHub contributions change
   - Top repositories change
   - GitHub languages change

Cache is **NOT** invalidated when:
- User changes bio (doesn't affect matching)
- User changes name (doesn't affect matching)
- User changes display preferences

## Configuration

### Dependency Injection

**Location:** `lib/features/matching/matching_dependencies.dart`

```dart
MatchingRepository createMatchingRepository(
  FirebaseAuth firebaseAuth,
  FirebaseFirestore firebaseFirestore,
) {
  return MatchingRepositoryImpl(
    remoteDataSource: MatchingHttpRemoteDataSource(...),
    localDataSource: InMemoryMatchingLocalDataSource(),
    cacheDataSource: FirestoreMatchingCacheDataSource(
      firestore: firebaseFirestore,
      auth: firebaseAuth,
      config: const MatchingCacheConfig(), // Default: 1 hour TTL
    ),
  );
}
```

### Custom Configuration

To customize cache behavior:

```dart
// 30-minute TTL
cacheDataSource: FirestoreMatchingCacheDataSource(
  firestore: firebaseFirestore,
  auth: firebaseAuth,
  config: const MatchingCacheConfig.withTtl(Duration(minutes: 30)),
)

// Disable caching
cacheDataSource: FirestoreMatchingCacheDataSource(
  firestore: firebaseFirestore,
  auth: firebaseAuth,
  config: const MatchingCacheConfig.disabled(),
)
```

## Performance Characteristics

### Cache Hit
- **Latency:** < 100ms (Firestore read)
- **Bandwidth:** Minimal (cached data)
- **Backend Load:** None

### Cache Miss
- **Latency:** 2-5 seconds (backend API call)
- **Bandwidth:** Full API response
- **Backend Load:** Full Gemini API call

### Expected Cache Hit Rate
- **Stable profiles:** ~90% (most users don't change profile frequently)
- **Active developers:** ~70% (frequent skill updates)
- **New users:** ~50% (still exploring and updating profile)

## Error Handling

All cache operations are **non-blocking** and fail gracefully:

### Cache Read Failure
```dart
try {
  final cached = await cacheDataSource.getCachedMatches();
  if (cached != null) return cached;
} catch (e) {
  // Silently fall through to API call
}
```

### Cache Write Failure
```dart
try {
  await cacheDataSource.cacheMatches(matches, profileHash: hash);
} catch (e) {
  // Silently fail, don't block user experience
}
```

### Cache Validation Failure
```dart
try {
  final valid = await cacheDataSource.isCacheValid(hash);
  if (!valid) {
    // Fetch from API
  }
} catch (e) {
  // Assume invalid, fetch from API
}
```

## Testing

### Unit Tests

**Profile Hash Tests:** `test/features/matching/data/utils/profile_hash_test.dart`
- ✅ Consistent hashing for same profile
- ✅ Different hash when relevant fields change
- ✅ Same hash regardless of field order
- ✅ Same hash when non-relevant fields change
- ✅ Handles empty lists

### Integration Tests

To test caching in integration tests:

```dart
test('cache hit returns cached matches', () async {
  // First request - cache miss
  final matches1 = await repository.getRankedMatches(profile);
  
  // Second request - cache hit (same profile)
  final matches2 = await repository.getRankedMatches(profile);
  
  // Should return same matches without API call
  expect(matches1, equals(matches2));
  verify(mockRemoteDataSource.getMatches(any)).called(1); // Only once
});

test('cache invalidates on profile change', () async {
  // First request
  final matches1 = await repository.getRankedMatches(profile1);
  
  // Update profile (add skill)
  final profile2 = profile1.copyWith(
    skills: [...profile1.skills, 'New Skill']
  );
  
  // Second request with updated profile - cache miss
  final matches2 = await repository.getRankedMatches(profile2, userProfile: profile2);
  
  verify(mockRemoteDataSource.getMatches(any)).called(2); // Twice
});
```

## Monitoring

### Metrics to Track

1. **Cache Hit Rate:** `cache_hits / total_requests`
2. **Average Latency:** 
   - Cache hit: ~100ms
   - Cache miss: ~2-5s
3. **Cache Size:** Number of cached entries per user
4. **Invalidation Rate:** How often profiles change

### Firestore Usage

- **Reads:** 1 per match request (cache check)
- **Writes:** 1 per cache miss (cache update)
- **Storage:** ~10KB per cached result

**Cost Estimate** (for 1000 users):
- Reads: 1000 checks/day = $0.04/day
- Writes: 100 cache misses/day = $0.01/day
- Storage: 10MB total = $0.001/day
- **Total:** ~$1.50/month

## Future Improvements

### Potential Enhancements

1. **Multi-level caching:**
   - L1: In-memory (instant, session-scoped)
   - L2: Firestore (fast, persistent)

2. **Partial cache invalidation:**
   - Only refresh affected matches when profile changes slightly

3. **Prefetching:**
   - Pre-load matches in background when profile is updated

4. **Cache warming:**
   - Pre-cache matches for active users during off-peak hours

5. **Analytics integration:**
   - Track which cached matches get liked/skipped
   - Use analytics to improve cache strategy

6. **Offline-first:**
   - Serve stale cache when offline
   - Sync when connection restored

## Troubleshooting

### Cache Not Working

**Symptom:** Every request hits the API

**Possible Causes:**
1. Cache disabled in config
2. Profile changes between requests
3. TTL too short
4. Firestore permissions issue

**Debug:**
```dart
// Check cache validity
final valid = await cacheDataSource.isCacheValid(profileHash);
print('Cache valid: $valid');

// Check cached data
final cached = await cacheDataSource.getCachedMatches();
print('Cached matches: ${cached?.length ?? 0}');
```

### Stale Cache

**Symptom:** Old matches returned after profile update

**Possible Causes:**
1. Profile hash not updating
2. Cache not checking profile hash
3. Race condition in cache update

**Fix:**
- Verify profile hash changes when profile updates
- Check cache validity logic
- Consider adding explicit cache clear on profile update

### High Firestore Costs

**Symptom:** Unexpected Firestore bills

**Possible Causes:**
1. Cache TTL too short (too many writes)
2. Many cache misses (frequent profile updates)
3. Large cache entries

**Solutions:**
- Increase TTL to 2-4 hours
- Optimize cache entry size
- Add cache hit rate monitoring

## References

- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Cache Strategies](https://aws.amazon.com/caching/best-practices/)
- [SHA-256 Hashing](https://en.wikipedia.org/wiki/SHA-2)
