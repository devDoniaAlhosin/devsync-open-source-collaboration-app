# Projects — Firestore schema

This is the contract used by `features/projects`. It is aligned with
`lib/core/constants/firestore_collections.dart` and the shared `requests`
collection owned by the requests feature.

## `projects/{projectId}`

| Field | Type | Written by | Notes |
| --- | --- | --- | --- |
| `ownerId` | string | client (create/update) | Firebase uid; drives `isOwner`. |
| `ownerName` | string | client (create/update) | Denormalized so Discover avoids a users read. |
| `title` | string | client | |
| `description` | string | client | |
| `githubUrl` | string | client | Full URL. |
| `githubRepo` | string | client | `owner/repo`, derived from `githubUrl`. |
| `techStack` | array<string> | client | |
| `requiredContributors` | number | client | |
| `viewsCount` | number | client transaction | Incremented by `views` logging. |
| `requestsCount` | number | client transaction | Incremented when a request is created. |
| `createdAt` | timestamp | client (create) | Orders the "New" filter. |
| `updatedAt` | timestamp | client | |
| `matchPercentage` | number | **DevSync API / matching** | Read-only for this feature. |
| `matchSummary` | string | **DevSync API / matching** | Read-only. |
| `alignments` | array<{label, score}> | **DevSync API / matching** | Read-only. |
| `matchedSkills` | array<string> | **DevSync API / matching** | Read-only. |
| `github` | map | **DevSync API sync** | `{stars, contributors, openTasks, syncedAt}`. Refreshed opportunistically by the details screen when stale. |

`ProjectModel.toFirestore` deliberately never writes the AI or GitHub fields.

## `views/{projectId}_{uid}_{yyyy-MM-dd}`

| Field | Type | Notes |
| --- | --- | --- |
| `projectId` | string | |
| `viewerId` | string | Must equal `request.auth.uid` in rules. |
| `createdAt` | timestamp | Server timestamp. |

The deterministic id gives one view per user per project per day. The weekly
sparkline counts `createdAt` in seven daily buckets; this requires the composite
index in `firestore.indexes.json`.

## `requests/{requestId}`

| Field | Type | Notes |
| --- | --- | --- |
| `projectId` | string | |
| `projectTitle` | string | Snapshot, so the inbox survives project edits. |
| `ownerId` | string | Maintainer uid. |
| `ownerName` | string | Optional denormalized maintainer name. |
| `requesterId` | string | Must equal `request.auth.uid` on create. |
| `requesterName` | string | |
| `requesterEmail` | string | Optional. |
| `message` | string | Trimmed, max 1000 chars. |
| `matchPercentage` | number | Cached AI score at request time. |
| `status` | string | `pending` \| `accepted` \| `declined`. |
| `type` | string | `sent` (requester's view). |
| `createdAt` / `updatedAt` | timestamp | |

`RequestToCollaborate` is idempotent: an existing pending request for the same
`projectId` + `requesterId` returns `created: false` and does not increment
`projects.requestsCount`.

## External systems

* **GitHub API** — `GithubRemoteDataSource` refreshes `projects.github` on the
  details screen when the cache is older than 6 hours. Set `GITHUB_TOKEN` via
  `--dart-define` to raise the rate limit.
* **DevSync API (Vercel) + Gemini Flash-Lite** — owns AI fields and writes them
  into project documents. The app never calls Gemini directly.
* **Cloud Messaging** — `POST {DEVSYNC_API_BASE_URL}/api/collaboration-requests/notify`
  is called best-effort after a request commits. The API owns the FCM service
  account. If the URL is not configured the call is a no-op.
