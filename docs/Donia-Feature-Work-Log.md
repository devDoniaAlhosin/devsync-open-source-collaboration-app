# DevSync — Feature work log (Added / Changed)

| Field | Value |
|-------|-------|
| **Member** | Donia Alhosin |
| **Role** | Project Manager — foundation, design system, Auth; staging integration |
| **Branch** | `staging` |
| **Date** | 30 Oct 2026 |

Scope: what **I built or changed**. Teammate-owned UIs are marked clearly; “Work inside teammates’ features” lists concrete edits on their screens.

---

## 1. Authorship quick table (who made what)

| Piece | Path / route | Original owner | My staging work |
|-------|--------------|----------------|-----------------|
| **Connect GitHub** | `lib/features/matching/presentation/screens/connect_github_screen.dart` · `/connect-github` | **Saga** (`Abd-Elrahman22`, `eddac37`) | Wired default Continue → `/edit-profile` when `onContinue` is null (onboarding after Auth) |
| **Send request success** | Success / Done step inside `request_join_sheet.dart` | **Yousef** created sheet (`d00c3c9`) | Large rewrite of sheet: success UI, motion, Done result returned to flow |
| **Allow notification** | `notification_permission_screen.dart` · `/notification-permission` | **Me** (new, untracked until commit) | Built soft-ask screen + routes |
| **Connected celebration** | `connected_celebration_screen.dart` · `/connected` | **Me** (new, untracked until commit) | Built screen; opened from request card Accept |
| **Request flow glue** | `collaboration_request_flow.dart` | **Me** (new) | Join Done → Allow notification; hooked from matching / projects |
| Match feed / AI studio | `matching/presentation/screens/*` | **Emad** | Merged + shared chrome / liked-matches |
| Projects UI | `projects/screens/*` | **Bishay** | Merged + shared headers / request flow hooks |
| Profile UI | `profile/presentation/screens/*` | **Saga** | Merged + shared headers; onboarding lands on edit profile |
| Requests inbox cards | `request_card` / original inbox | **Yousef** | pages→screens; card → Connected; join sheet rewrite |

```text
Join sheet (Yousef base + my rewrite)
  → Send success / Done (in sheet)
  → collaboration_request_flow (me)
  → Allow notification (me)

Request card Accept
  → Connected celebration (me)
```

---

## 2. Per feature — Added | Changed

### Core / design system

| Added | Changed |
|-------|---------|
| `DsPageFade`, `DsStaggeredEntrance`, `DsFadeSwitch`, `DsItemEnter`, `DsTabSwitcher`, `DsBrandIcon` | `AppTypography`, `AppAnimations`, `DsAppBar`, `DsBottomNav`, `DsPageHeader`, `DsLogo`, `DsNotificationTile` |
| `dummy_notifications.dart`; `core/navigation/` | Design tokens, `AppIcons`, widgets barrel; Auth GetIt / `Result` / `Failure` |

### Auth (my ownership)

| Added | Changed |
|-------|---------|
| Intro landing, Welcome 3-step, Login, Register, Forgot, Verify code, Code sign-in, Email link sent, Verify email under `presentation/screens/` | `pages/` → `screens/` |
| Clean Architecture + Firebase Auth; delete-account; password-reset path; auth tests | **AuthGate**: signed-out → **Intro** first; `navigateToOnboarding` → Connect GitHub |

### Shell / Settings

| Added | Changed |
|-------|---------|
| Settings + shared chrome | `HomeShellScreen` tabs (Matches, Discover, Projects, Requests, Profile) |

### Matching

| Added | Changed |
|-------|---------|
| **Liked matches** screen + store; `/liked-matches` | Merged Emad’s feature; shared `DsAppBar` / fade; removed `match_feed_app_bar` |
| | **Connect GitHub** Continue → edit profile; details/liked → request flow |

### Projects

| Added | Changed |
|-------|---------|
| — (Bishay UI) | Merged; removed `project_top_bar`; shared headers/search; discover/details → request flow |

### Profile

| Added | Changed |
|-------|---------|
| — (Saga UI) | Merged; shared headers; edit profile is onboarding step after Connect GitHub |

### Requests

| Added | Changed |
|-------|---------|
| **Allow notification** screen; **Connected celebration**; `collaboration_request_flow` | Merged Yousef inbox; `pages/` → `screens/` |
| | **Send-request success** rewrite in join sheet; request_card → Connected; routes |

### Notifications

| Added | Changed |
|-------|---------|
| Notifications inbox + dummy seed | Route `/notifications` |

### Docs / PM

| Added | Changed |
|-------|---------|
| Shared-screen handoffs; hub Schema/ERD; this work log | README ownership; `.gitignore` restore after merges |

---

## 3. Work I did inside teammates’ features

### Matching (Emad) + Connect GitHub (Saga)

- Merged `feature/matching` into `staging`.
- Replaced feature-local match feed app bar with shared `DsAppBar` / page enter motion; aligned empty state, greeting, deck, skeletons, project-details chrome to DS.
- **Added** `LikedMatchesScreen` + `liked_matches_store` and route `/liked-matches`.
- On **Saga’s Connect GitHub** screen: if no `onContinue` callback, **Continue** navigates to `/edit-profile` (onboarding chain from Auth).
- Wired project details / liked matches to `presentCollaborationRequestFlow` (send request → success → allow notification).

### Projects (Bishay)

- Merged `feature/projects` into `staging`.
- Removed feature `project_top_bar`; aligned discover / my projects / details / add-edit and shell with shared headers, search, and app chrome.
- Hooked discover + project details into `presentCollaborationRequestFlow` so send-request success + allow notification run after join Done.

### Profile (Saga)

- Merged `feature/profile-ui` into `staging`.
- Aligned profile / edit profile / insights to shared headers and navigation.
- Edit profile is the next step after Connect GitHub in the onboarding path I wired.

### Requests (Yousef)

- Merged `feature/requests` into `staging`; moved inbox to `presentation/screens/`.
- **Rewrote** `request_join_sheet`: form → **send success** step → **Done** returns result (this is the “request sent successfully” UX).
- **Added** `NotificationPermissionScreen` (“Allow notification” soft-ask) and route.
- **Added** `ConnectedCelebrationScreen` and route; **request_card** Accept navigates there.
- **Added** `collaboration_request_flow.dart`: after Done on success sheet → push Allow notification.
- Registered `/notification-permission` and `/connected` in `app_routes` / `devsync_app`.

---

## 4. Screen checklist

| Screen / step | Feature | Who built base | My role |
|---------------|---------|----------------|---------|
| Intro (landing) | Auth | Me | Built + AuthGate entry |
| Welcome (3 steps) | Auth | Me | Built; after Intro Get started |
| Connect GitHub | Matching | **Saga** | Continue → edit profile |
| Send request **success** (in join sheet) | Requests | **Yousef** sheet | Rewrote success / Done |
| Allow notification | Requests | **Me** | Built + after Done |
| Connected celebration | Requests | **Me** | Built + from Accept |
| Liked matches | Matching | **Me** | Built (staging) |
| Notifications inbox | Notifications | **Me** | Built (staging) |
| Match feed / studio | Matching | Emad | Merge + chrome |
| Projects screens | Projects | Bishay | Merge + chrome + flow hooks |
| Profile / insights | Profile | Saga | Merge + chrome |
| Requests inbox | Requests | Yousef | Merge + screens move + card→Connected |
