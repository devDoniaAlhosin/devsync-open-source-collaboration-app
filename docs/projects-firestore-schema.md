# Projects — Firestore schema

Contract for `features/projects`, aligned with
`lib/core/constants/firestore_collections.dart`. Collaboration **create**
should use the requests feature (`RequestsCubit` / `RequestModel`), not a
second local schema.

## Status on main

| Piece | Status |
| --- | --- |
| `projects/{id}` create / edit / list | **Exists** — client writes core fields; owner-guarded |
| `views/{id}` daily view docs | **Exists** — `recordView` on project open |
| Discover / My projects / details UI | **Exists** |
| `ownerId` + `ownerName` on upsert | **Exists** — stamped from Auth / users doc; empty owner IDs are rejected |
| Join request create | **Exists only in RequestsCubit** — projects module has no request writer |
| AI fields on project (`matchPercentage`, …) | **Exists as read-only** — written by DevSync API / matching, not Flutter |
| GitHub metrics map | **Exists** — opportunistic client refresh + optional API sync |
| Firestore rules (owner-only updates) | **Exists** — owner content/delete; counter-only +1 exception |
| Views sparkline composite index | **Exists** — deploy `firestore.indexes.json` |

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
| `viewsCount` | number | client transaction | Incremented once per daily view document. |
| `requestsCount` | number | requests feature transaction | Incremented once per request document; never double-counted on re-send. |
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

### Guards (implemented)

1. Every create/edit stamps a non-empty `ownerId` (`request.auth.uid`) and `ownerName` (Auth display name → `users/{uid}` → email local part → `Maintainer`).
2. Edit runs in a transaction: document must exist, have a non-empty `ownerId`, and match the signed-in user. Legacy unowned docs must be re-created.
3. Rules: signed-in read; create requires `ownerId == request.auth.uid` and non-empty `ownerName`; update/delete are owner-only, except single +1 counter diffs.
4. Keep **one** request-create path (RequestsCubit only).
5. `firestore.indexes.json` contains the weekly views index and the request inbox indexes.

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

Idempotent create: request id is deterministic — `${senderId}_${projectId}`. A
pending or accepted request is never duplicated; a declined request is re-opened
on the same document. `projects.requestsCount` increments exactly once, in the
same transaction that creates the document (never on re-open).

### Legacy shape — removed from the client

The old projects-remote writer (`projectTitle`, `requesterId`, `requesterName`,
`requesterEmail`, `ownerName`, `matchPercentage`, `updatedAt`) has been deleted.
Do not reintroduce it; those docs, if present in a database, should be deleted.

### Implemented

1. Single writer: `RequestsCubit` / `RequestsRemoteDataSource` only.
2. Rules match `RequestModel` / `validRequestData`, and allow the same
   transaction to bump `projects.requestsCount` by 1.
3. No duplicate request documents (deterministic id + transaction).

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
