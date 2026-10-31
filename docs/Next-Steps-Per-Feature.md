# Next steps (phased) + shared backend + ERD

Audience: Claude (PDF) and the team.  
**Deadline: core product path done by 12 Nov freeze** (no new screens after that). Demo day 30 Nov.

## Generate PDF / team brief

- Output / update: `docs/DevSync-Feature-Summaries-All-Members.pdf`
- Structure the brief as **phases** (this file), not a flat feature dump
- Include Auth **already done vs still missing**, and **ERD as shapes by 12 Nov**
- Keep Emad / Bishay / Yousef / Saga / Donia as owners
- Put shared backend + ERD once (team-wide)

---

## 1. Shared backend & core (everyone uses)

| Shared piece | Where | Rule |
|--------------|-------|------|
| Collection names | `lib/core/constants/firestore_collections.dart` | Only: `users`, `projects`, `matches`, `feedback`, `requests`, `tasks` — no new spellings |
| Errors | `lib/core/result/result.dart`, `lib/core/error/failures.dart` | Repos return `Result<T>`; map at data boundary |
| DI | `lib/core/di/injection.dart` | One composition root |
| State | feature `presentation/cubit/` | Cubit first; screens never call Firebase |
| Design system | `lib/core/widgets/ds_*`, theme | Shared chrome; no feature-local page headings |
| Swap pattern | data layer | Keep domain contracts; replace `*LocalDataSource` → `*RemoteDataSource` |

### Document paths

| Collection | Path | Notes |
|------------|------|--------|
| Users / profile | `users/{uid}` | Auth creates/merges; Profile **extends** same doc |
| Projects | `projects/{projectId}` | Include `ownerId` |
| Matches | `matches/{…}` | Cache / rank results |
| Requests | `requests/{requestId}` | Sender + receiver + status |
| Feedback / tasks | `feedback`, `tasks` | Feedback with like/skip; tasks if-time |

---

## 2. ERD (source of truth + shapes deliverable)

**Same ERD as Document 4 / hub — do not invent a second model.**

| Source | Location |
|--------|----------|
| Document 4 | [`DevSync-4-System-Analysis-and-Design.pdf`](DevSync-4-System-Analysis-and-Design.pdf) |
| Live diagram | Hub Schema & ERD in [`index.html`](index.html) (`erdSource`) |
| Code names | `FirestoreCollections` |

```text
USER ||--o{ PROJECT : maintains
USER ||--o{ MATCH : receives
USER ||--o{ FEEDBACK : writes
USER ||--o{ REQUEST : sends | receives as maintainer
PROJECT ||--o{ MATCH | FEEDBACK | REQUEST | TASK
USER ||--o{ TASK : assigned
PROMPT_VERSION ||--o{ MATCH : produced by
```

| Status | Collections |
|--------|-------------|
| **Implemented** | `users/{uid}` identity (auth) |
| **Planned** | `projects`, `matches`, `feedback`, `requests` |
| **If-time** | `tasks` |

### ERD as shapes (by 12 Nov)

Generate the Document 4 / hub ERD **as shape diagrams** (entity boxes + relationship lines) for the report / team PDF.

- Same entities: `USER`, `PROJECT`, `MATCH`, `FEEDBACK`, `REQUEST`, `PROMPT_VERSION`, and `TASK` (if-time)
- Visual shapes only — **not** a new schema
- Deliver with the freeze package by **12 Nov**

---

## 3. Auth — already done vs still missing

### Already in the app (code) — Phase 0

- Email + password sign-in / register
- Google Sign-In (`signInWithGoogle`)
- GitHub OAuth sign-in (`signInWithGitHub`)
- Email link + password reset + delete account
- `users/{uid}` bootstrap / merge
- Owner-only Firestore rules for `users/{uid}` only

### Still missing / polish (Auth) — Phase 3, by 12 Nov

- Confirm Firebase Console providers + SHA / client IDs work on every teammate device
- Production email templates (verify / link / reset)
- Real email OTP (verify screen still demo `123456`)
- Extend `firestore.rules` beyond `users` → projects, matches, feedback, requests
- Coordinate with Saga: profile field names on the **same** `users/{uid}` (Connect GitHub **stats** = Profile, not Auth sign-in)

---

## 4. Phases (whole app)

| Phase | When | What |
|-------|------|------|
| **Phase 0 — Done** | Now | Auth methods above; Cubit / GetIt / `Result` shell; Matching / Projects / Requests / Profile UI on **local / dummy** data |
| **Phase 1 — Shared contracts + ERD shapes** | Immediately | Lock `FirestoreCollections` + Doc 4 ERD; **generate ERD as shapes** for report/PDF |
| **Phase 2 — Wire Firestore** | Before freeze | Projects seed → Matches cache/rank → Requests + Feedback → Profile fields on `users/{uid}` behind existing repos |
| **Phase 3 — Connect path** | By 12 Nov | Soft-ask / Connected; Auth Console polish; rules for all planned collections; seed/fallback OK if Cloud Function / FCM not ready |
| **Phase 4 — Freeze** | **12 Nov** | **Core project done**: no new screens; signed-in path works; ERD shapes delivered; rules shipped |
| **After freeze / if-time** | Post-12 Nov → 30 Nov | Tasks board, prompt dashboard, extra motion, wider tests → demo day |

### Phase 0 — Done (now)

- Donia: email / Google / GitHub auth + `users/{uid}` (see §3)
- Emad / Bishay / Yousef / Saga: screens + Cubits on local/dummy sources
- Team: shared `Result` / GetIt / `Ds*` converging

### Phase 1 — Shared contracts + ERD shapes

- Everyone: use only `FirestoreCollections` spellings; no parallel schemas
- Team / Donia (docs): generate ERD **as shapes** from Doc 4 / hub (boxes + relationships)
- Profile extends `USER`; never a second users collection

### Phase 2 — Wire Firestore (owners)

**Bishay — Projects**

- `ProjectsRemoteDataSource` + mappers; `ownerId` queries; drop dummy when seed is in Firestore
- Keep repository / use case / Cubit APIs stable

**Emad — Matching**

- Firestore `matches` cache; Cloud Function calling **Gemini Flash-Lite** when ready (seed/skills-overlap fallback OK for v1)
- Persist likes; real GitHub scan when OAuth/API ready
- LLM key stays a Cloud Function secret — never in the Flutter app

**Yousef — Requests**

- Firestore `requests`; like/skip → `feedback` without changing ranking
- Keep `presentCollaborationRequestFlow`

**Saga — Profile**

- Map `Profile` ↔ `users/{uid}`; Connect GitHub → languages / stats
- Do not own Settings (Donia)

### Phase 3 — Connect path (by 12 Nov)

- Yousef: soft-ask / Connected; FCM after send/accept if ready (permission screen exists)
- Donia: Auth missing items in §3; extend rules for projects / matches / feedback / requests
- Emad: loading / empty / fallback states on feed
- Bishay: motion only as PRs screen owners review

### Phase 4 — Freeze (12 Nov) — core project done

- No new screens
- Signed-in path: Welcome → Auth → (Connect GitHub / profile) → Feed / Projects / Requests
- ERD shapes delivered for Document 4 / PDF
- Firestore rules cover planned collections
- Local seed still acceptable where remote AI / FCM is not ready

### After freeze / if-time → demo 30 Nov

- Tasks board (Donia, only if freeze is green)
- Prompt-quality dashboard (Emad)
- Extra motion / walkthrough (Bishay)
- Wider tests + snapshots / README (Saga)
- Present demo (Saga + Bishay)

---

## 5. Pre-merge checklist (PM extras → each `feature/*`)

1. Pull shared core first (`Result`, `Failure`, `FirestoreCollections`, `injection.dart`, `Ds*`)
2. Do not reintroduce: `MatchingController`, `presentation/pages/`, feature-root projects `screens/` / `widgets/`, old custom app bars
3. Keep domain repository interfaces; add remote data sources behind them
4. Register Cubits only via `configureDependencies()`
5. Smoke-test on local until remote DS is swapped

---

## 6. One-line summary

> Auth email + Google + GitHub is already in code; AI is Gemini Flash-Lite via Cloud Function (seed fallback OK). Remaining work is phased Firestore wiring, Auth Console/OTP/rules polish, and ERD-as-shapes — **core project done by 12 Nov freeze**, same Doc 4 ERD, no second model.
