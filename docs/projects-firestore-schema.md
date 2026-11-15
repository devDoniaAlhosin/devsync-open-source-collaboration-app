# Projects — Firestore schema

Contract for `features/projects`, aligned with
`lib/core/constants/firestore_collections.dart`. Collaboration **create**
should use the requests feature (`RequestsCubit` / `RequestModel`), not a
second local schema.

## Status on main

| Piece | Status |
| --- | --- |
| `projects/{id}` create / edit / list | **Exists** — client writes core fields |
| `views/{id}` daily view docs | **Exists** — `recordView` on project open |
| Discover / My projects / details UI | **Exists** |
| `ownerId` + `ownerName` on upsert | **Exists** (resolved from Auth / users doc) — still need every legacy doc filled |
| Join request create | **Exists** via RequestsCubit — **Needs work:** remove dual write from projects remote if still present |
| AI fields on project (`matchPercentage`, …) | **Exists as read-only** — written by DevSync API / matching, not Flutter |
| GitHub metrics map | **Exists** — opportunistic client refresh + optional API sync |
| Firestore rules (owner-only updates) | **Needs work** — tighten |
| Views sparkline composite index | **Needs work** — deploy `firestore.indexes.json` if Console warns |

Task board / `tasks` collection is **extra** — not part of this contract.

---

## `projects/{projectId}`

### Exists (client-written)

| Field | Type | Written by | Notes |
| --- | --- | --- | --- |
| `ownerId` | string | client (create/update) | Firebase uid; drives `isOwner`. |
| `ownerName` | string | client (create/update) | Denormalized so Discover avoids a users read. |
| `title` | string | client | |
| `description` | string | client | |
| `githubUrl` | string | client | Full URL. |
| `githubRepo` | string | client | `owner/repo`, derived from `githubUrl`. |
| `techStack` | array\<string\> | client | |
| `requiredContributors` | number | client | |
| `viewsCount` | number | client transaction | Incremented by `views` logging. |
| `requestsCount` | number | client transaction | Incremented when a request is created. |
| `createdAt` | timestamp | client (create) | Orders the "New" filter. |
| `updatedAt` | timestamp | client | |

### Exists (read-only for Flutter / other writers)

| Field | Type | Written by | Notes |
| --- | --- | --- | --- |
| `matchPercentage` | number | **DevSync API / matching** | Not in `ProjectModel.toFirestore`. |
| `matchSummary` | string | **DevSync API / matching** | Read-only. |
| `alignments` | array\<{label, score}\> | **DevSync API / matching** | Read-only. |
| `matchedSkills` | array\<string\> | **DevSync API / matching** | Read-only. |
| `github` | map | API sync **or** client refresh | `{stars, contributors, openTasks, syncedAt}`. Details screen may refresh when stale. |

### Needs work (projects feature)

1. Ensure **every** project doc has non-empty `ownerId` and preferred non-empty `ownerName` (legacy empties break join).
2. Keep **one** request-create path (RequestsCubit only).
3. Tighten Firestore rules (owner-only updates where safe).
4. Confirm views composite index is deployed for weekly sparkline queries.

---

## `views/{projectId}_{uid}_{yyyy-MM-dd}`

### Exists

| Field | Type | Notes |
| --- | --- | --- |
| `projectId` | string | |
| `viewerId` | string | Must equal `request.auth.uid` in rules. |
| `createdAt` | timestamp | Server timestamp. |

Deterministic id = one view per user per project per day. Weekly sparkline
buckets `createdAt` over seven days (needs composite index in
`firestore.indexes.json`).

### Needs work

- Deploy / verify the composite index if queries fail in Console.
- Rules: viewer may only write their own `viewerId`.

---

## `requests/{requestId}` (shared with requests feature)

### Canonical shape — **Exists** (Mohey `RequestModel`) — required

| Field | Type | Notes |
| --- | --- | --- |
| `projectId` | string | |
| `senderId` | string | Requester uid (`request.auth.uid` on create). |
| `ownerId` | string | Maintainer uid (must match project). |
| `initials` | string | UI avatar. |
| `title` | string | Inbox title (often project name). |
| `subtitle` | string | |
| `status` | string | `pending` \| `accepted` \| `declined`. |
| `type` | string | `sent` \| `received` (viewer-relative). |
| `message` | string | Optional. |
| `displayName` | string | Requester display name. |
| `targetName` | string | Maintainer / target label. |
| `matchPercent` | number | Score at request time. |
| `matchSummary` | string | |
| `repositoryCount` | number | Profile snapshot. |
| `commitCount` | number | |
| `languageCount` | number | |
| `skills` | array\<string\> | |
| `createdAt` | timestamp | |
| `respondedAt` | timestamp \| null | Set on accept/decline. |

Idempotent create: same sender + project should not double-increment
`projects.requestsCount`.

### Legacy shape — **Needs removal** (older projects-remote path)

Do **not** treat as the contract. If still present in code, delete/guard it:

`projectTitle`, `requesterId`, `requesterName`, `requesterEmail`, `ownerName`,
`matchPercentage`, `updatedAt` — conflicts with rules expecting `RequestModel`.

### Needs work

1. Single writer: `RequestsCubit` / `RequestsRemoteDataSource` only.
2. Deploy rules matching `RequestModel` / `validRequestData`.
3. Keep `projects.requestsCount` in sync without double docs.

---

## External systems

| System | Status | Notes |
| --- | --- | --- |
| GitHub REST (`GithubRemoteDataSource`) | **Exists** | Refreshes `projects.github` when stale. Optional `--dart-define=GITHUB_TOKEN=…`. |
| DevSync API (Vercel) + Gemini | **Exists for matching generate** | App calls `POST /matches/generate`. AI fields on project docs are API-owned when synced. |
| FCM notify HTTP | **Partial** | Best-effort `POST …/api/collaboration-requests/notify` after some creates; no-op if base URL unset. Token storage is `users/{uid}/fcmTokens`. |

### Needs work (cross-feature)

- Matching does **not** write Firestore `matches` today (RAM cache) — see [FEATURE_MISSING_REPORT.md](FEATURE_MISSING_REPORT.md).
- Full FCM UX / deep links owned by requests feature.
