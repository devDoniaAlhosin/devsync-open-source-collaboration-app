# Matching handoff

Updated 2026-11-06, feature/matching. This checkpoint supersedes stale prior claims of complete mock removal.

## State
Audit completed; implementation in progress. Baseline HEAD df50f65. Existing history includes authenticated HTTP integration, mapper, and saved-match Firestore persistence, but runtime demo profile/analytics and fake profile DI remain defects (see IMPLEMENTATION_PLAN.md).

## Contract
Read-only sibling E:/project flutter/devsync_backend: controller fetches candidates server-side when projects omitted. POST /matches/generate accepts actual uid/declaredSkills/githubLanguages/publicRepoCount/totalContributions, optional bio/topRepositories/prompt/tags. Firebase Bearer ID token must match uid. Empty results and backend isFallback are valid. No backend edits.

## Ownership
Root: profile adapter, Cubit/domain/DI, checkpoints and commits. Parallel transport: HTTP/models/repository/tests. Parallel saved: liked data source/tests. Parallel screens: matching UI/widgets/tests. Earlier agents were interrupted; replacement agents inspect partial edits before continuing.

## Work remaining
Complete strict transport, real profile/Cubit, saved persistence failures, real screen behaviors, tests and final audit. Existing profile repository is sample-backed: never use it as real matching input. Matching-owned users/{uid} adapter plus explicit skills input is required. Unimplemented collaboration-request and GitHub-link flows must be disclosed, not simulated.

## Validation
No completed test run claimed yet; prior processes were interrupted. Flutter/Dart available. git fetch completed; local branch ahead 11, behind 0.

## Safety
Unrelated user modifications in profile presentation and generated platform files preserved. Immutable docs/DEVSYNC_FLUTTER_MATCHING_REFACTOR_AGENT_PROMPT.md was read only and is NOT staged/committed. No push requested.

## Next action
Read current git status/diff and IMPLEMENTATION_PLAN.md; finish the current scopes, format/test each logical increment, stage explicit owned files, commit and append hashes/results here.
