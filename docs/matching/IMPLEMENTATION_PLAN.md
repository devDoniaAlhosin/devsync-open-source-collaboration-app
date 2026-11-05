# DevSync Matching Feature - Implementation Plan

## Current Status: IN_PROGRESS
**Last Updated:** 2024-11-05 (Initial Agent Session)
**Branch:** `feature/matching`
**Agent:** Claude Code (Session 1)

## Task Breakdown

| ID | Task | Status | Acceptance Criteria | Validation |
|----|------|--------|-------------------|------------|
| M01 | Audit current matching feature | COMPLETED | Real vs mock paths documented | Verified via code inspection |
| M02 | Add Firebase ID token to HTTP requests | IN_PROGRESS | Auth header with Bearer token attached | - |
| M03 | Refactor matching domain/data boundaries | NOT_STARTED | Clean Architecture, SOLID, testable | - |
| M04 | Connect real profile/project inputs | NOT_STARTED | No hardcoded data in production | - |
| M05 | Complete Cubit flows | NOT_STARTED | Ranked UI, stable states | - |
| M06 | Remove obsolete mocks | NOT_STARTED | No dummy data in production | - |
| M07 | Add/update matching tests | NOT_STARTED | Contract, auth, states tested | - |
| M08 | Integration verification | NOT_STARTED | Local/prod verified or blockers documented | - |

## M01 Audit Results

### Current Implementation Status

**✅ Already Implemented:**
- HTTP data source (`MatchingHttpRemoteDataSource`)
- Request/response models with proper JSON serialization
- Domain entities and repository contract
- Cubit with loading/success/error states
- Match feed screens and widgets
- DI registration in `injection.dart`
- Local/production URL configuration via dart-define

**❌ Missing/Incomplete:**
- Firebase ID token not attached to HTTP requests
- Mock data source still registered as production fallback
- Auth token refresh mechanism not integrated
- No error handling for 401/403 auth failures
- Empty state handling incomplete
- Tests for auth scenarios

**📋 Temporary/Obsolete Code Identified:**
- `MockMatchingRemoteDataSource` in `matching_remote_data_source.dart`
- `createDemoMatchingRepository()` in `matching_dependencies.dart`
- `createDemoMatchingCubit()` in `matching_dependencies.dart`
- Demo analytics and custom prompt methods not needed for MVP

### Backend Contract Verified

**Endpoint:** `POST /matches/generate`
**Base URLs:**
- Production: `https://devsync-backend-two.vercel.app`
- Local: `http://localhost:3000` (or `http://10.0.2.2:3000` for Android emulator)

**Required Headers:**
- `Content-Type: application/json`
- `Authorization: Bearer <firebase-id-token>` ⚠️ MISSING IN CURRENT IMPLEMENTATION

**Request Payload:**
```json
{
  "uid": "string",
  "declaredSkills": ["string"],
  "githubLanguages": {"language": number},
  "publicRepoCount": number,
  "totalContributions": number,
  "bio": "string (optional)",
  "topRepositories": ["string"]
}
```

**Response:**
```json
{
  "matches": [
    {
      "projectId": "string",
      "projectName": "string",
      "description": "string",
      "githubUrl": "string",
      "neededSkills": ["string"],
      "score": number (0-100),
      "reason": "string",
      "maintainerId": "string",
      "isFallback": boolean (optional)
    }
  ],
  "promptVersion": "string"
}
```

**Status Codes:**
- 200: Success (may include empty matches array)
- 400: Invalid request payload
- 401: Missing or invalid auth token
- 403: Forbidden (UID mismatch)
- 429: Rate limit exceeded
- 500+: Server errors

### Architecture Analysis

**Current Structure:** ✅ Follows Clean Architecture
```
matching/
  domain/
    entities/        - Pure domain objects ✅
    repositories/    - Abstract contracts ✅
    usecases/        - Business logic ✅
  data/
    models/          - JSON DTOs ✅
    datasources/     - HTTP + Mock implementations ✅
    repositories/    - Repository implementation ✅
  presentation/
    cubit/           - State management ✅
    screens/         - UI screens ✅
    widgets/         - Reusable components ✅
```

**SOLID Compliance:**
- ✅ Single Responsibility: Clear separation of concerns
- ✅ Open/Closed: Interface-based design allows extension
- ✅ Liskov Substitution: Mock/real sources implement same interface
- ✅ Interface Segregation: Focused repository contract
- ✅ Dependency Inversion: Domain depends on abstractions

**Issues to Address:**
- ❌ HTTP data source violates SRP by not delegating auth token retrieval
- ❌ Direct Firebase Auth dependency should be injected
- ❌ Error mapping could be more explicit

## Next Steps (M02)

1. Create auth token provider interface/service
2. Inject FirebaseAuth into HTTP data source
3. Add Authorization header with Bearer token
4. Handle token refresh on 401/403
5. Add error mapping for auth failures
6. Update DI to use production HTTP source by default
7. Test auth token integration
8. Commit: "feat(matching): integrate Firebase ID token authentication"

## Blocked/Deferred Items

None currently identified.

## Notes

- Backend team confirmed Gemini integration is complete
- Empty matches array is a valid success response
- Backend handles Firestore project queries (Flutter doesn't need to fetch projects)
- Profile feature provides UserProfile entity with required fields
