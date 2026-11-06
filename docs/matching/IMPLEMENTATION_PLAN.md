# Matching implementation checkpoint

Updated: 2026-11-06. Branch: feature/matching.

## Goal and acceptance
Remove runtime sample data, use the authenticated matching backend, make every matching screen truthful and functional, and commit verified increments. Preserve all unrelated changes and the immutable docs/DEVSYNC_FLUTTER_MATCHING_REFACTOR_AGENT_PROMPT.md.

## Verified audit (supersedes earlier completion claims)
Existing HTTP/auth and Firestore liked-match implementations are retained. Earlier handoff incorrectly claimed all sample data was removed: Cubit still used demo-user while profile loaded, repository swallowed errors and returned demo analytics, profile DI supplies Profile.sample/FakeGitHubApiDataSource, GitHub scan is simulated, and several screens show invented values/actions.
Backend sibling was inspected read-only: src/matching/controller.js fetches Firestore candidates if projects omitted; access.js checks Firebase token and UID; validation.js supports optional prompt (1000 chars) and tags (30 x 100). Flutter must not fetch candidate projects. Existing backend deterministic fallback is real functionality.

## Increment checklist
- [x] R01 Audit contract, boundaries, runtime dummy sources; checkpoint.
- [ ] R02 Strict HTTP/DTO/repository: authenticated requests, bounded retry/timeout, safe explicit errors, stable ranking, real prompt/tags.
- [ ] R03 Matching-owned profile adapter and Cubit: read actual users/{uid}; never consume sample ProfileRepository; allow explicitly declared skills; prevent stale/duplicate requests; remove demo analytics/preferences.
- [ ] R04 Saved actions: surface storage failures, account isolation, await persistence/undo.
- [ ] R05 Screens: real feed/studio/results insights/profile setup/progress/details/saved data; remove fake scan and quality/trend artifacts; responsive/error tests.
- [ ] R06 Whole matching validation, regression suite, live availability checks, final handoff.

## Decisions and boundaries
Profile and requests are unfinished separate features. Do not rewrite them. A matching-owned adapter uses the existing authenticated users collection, with optional matching profile fields and explicit skills input; absent statistics stay absent/empty instead of invented. Existing profile edits remain untouched. Only /matches/generate is used for matching; no new backend endpoints or backend changes. No production data seeding.

## Current work and validation
R02-R05 in progress in separate file scopes. Flutter SDK available at D:/FlutterSDK/flutter. Baseline test process was interrupted before completion: no baseline pass is claimed. Git fetch completed; branch is 11 commits ahead and 0 behind origin/feature/matching. No pull needed. Initially unrelated modified paths: three profile presentation files and five platform generated registration files; prompt untracked. Nothing initially staged.

## Exact next action
Complete and test transport, real profile/Cubit, saved persistence, then screen slices. Stage explicit matching paths only. Record each actual commit and verification in AGENT_HANDOFF.md. Never stage the prompt or unrelated files.
