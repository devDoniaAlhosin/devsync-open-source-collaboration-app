# Firestore Security Rules for Liked Matches

## Collection Structure

```
liked_matches/{userId}/matches/{projectId}
```

## Security Rules

Add these rules to your `firestore.rules` file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Liked Matches Collection
    match /liked_matches/{userId}/matches/{projectId} {
      // Users can only read/write their own liked matches
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Specifically:
      // - Users can list their own liked matches
      // - Users can add a liked match (create)
      // - Users can remove a liked match (delete)
      // - Users can update a liked match (update)
      
      // Validation: Ensure required fields are present
      allow create: if request.auth != null 
                    && request.auth.uid == userId
                    && request.resource.data.keys().hasAll([
                      'projectId', 
                      'projectName', 
                      'description', 
                      'githubUrl', 
                      'neededSkills', 
                      'score', 
                      'reason'
                    ])
                    && request.resource.data.projectId is string
                    && request.resource.data.projectName is string
                    && request.resource.data.score is number
                    && request.resource.data.neededSkills is list;
    }
  }
}
```

## Testing Security Rules

Use the Firebase Console's Rules Playground or Firebase Emulator Suite to test:

### Test 1: User can read their own liked matches
```javascript
// Should ALLOW
auth: { uid: "user123" }
get /databases/(default)/documents/liked_matches/user123/matches/project1
```

### Test 2: User cannot read another user's liked matches
```javascript
// Should DENY
auth: { uid: "user123" }
get /databases/(default)/documents/liked_matches/user456/matches/project1
```

### Test 3: User can write to their own liked matches
```javascript
// Should ALLOW
auth: { uid: "user123" }
create /databases/(default)/documents/liked_matches/user123/matches/project1
{
  projectId: "project1",
  projectName: "Test Project",
  description: "A test project",
  githubUrl: "https://github.com/test/project",
  neededSkills: ["Dart", "Flutter"],
  score: 95,
  reason: "Perfect match",
  likedAt: timestamp
}
```

### Test 4: Unauthenticated user cannot access
```javascript
// Should DENY
auth: null
get /databases/(default)/documents/liked_matches/user123/matches/project1
```

## Indexes

For optimal query performance, create this index:

**Collection:** `liked_matches/{userId}/matches`
- Field: `likedAt` (Descending)
- Query scope: Collection

This index supports the `orderBy('likedAt', descending: true)` query used in `getLikedMatches()`.

### Creating the Index

Option 1: Firebase Console
1. Go to Firestore → Indexes
2. Click "Create Index"
3. Collection ID: Enter the full path for a sample user (e.g., `liked_matches/user123/matches`)
4. Add field: `likedAt` (Descending)
5. Query scope: Collection
6. Create

Option 2: Via Error Message
- Run the app and trigger `getLikedMatches()`
- Firebase will show an error with a direct link to create the index
- Click the link and confirm

Option 3: firestore.indexes.json
```json
{
  "indexes": [
    {
      "collectionGroup": "matches",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "likedAt",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

## Data Schema

Each document in `liked_matches/{userId}/matches/{projectId}` contains:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| projectId | string | Yes | Firestore project document ID |
| projectName | string | Yes | Display name (e.g., "flutter/packages") |
| description | string | Yes | Short project description |
| githubUrl | string | Yes | GitHub repository URL |
| neededSkills | array | Yes | List of skill strings |
| score | number | Yes | AI match score (0-100) |
| reason | string | Yes | Why this is a match |
| maintainerId | string | No | Project maintainer UID |
| isFallback | boolean | No | True if fallback match |
| likedAt | timestamp | Yes | When user liked this match |

## Deployment

1. Update `firestore.rules` with the rules above
2. Deploy rules: `firebase deploy --only firestore:rules`
3. Create the index (see above)
4. Test with Firebase Emulator Suite locally before deploying to production

## Notes

- Security rules use path-based authentication (`userId` variable)
- Rules prevent users from accessing other users' liked matches
- Validation ensures data integrity on create operations
- Offline persistence works automatically (Firestore SDK handles caching)
- No Cloud Functions required - all CRUD operations are client-side
