# Staging feature gaps (short index)

**Full guidance for Claude / owners:** [FEATURE_OWNER_GUIDANCE.md](FEATURE_OWNER_GUIDANCE.md)

Staging after Mohey requests merge includes Firestore `requests` + FCM bootstrap. Matching HTTP generate was already on staging.

| Feature | Data on staging | Biggest gap |
|---|---|---|
| Auth | Firebase + Vercel OTP | Team `google-services.json` / API key |
| Profile | Firestore `users` | Live GitHub (fake scan still in matching UI) |
| Projects | Firestore `projects` / `views` | `ownerId` required for requests; rules tighten |
| Matching | `POST /matches/generate` + RAM cache | `Result`; `matches`/`feedback` unused |
| Requests | Firestore `requests` | Deploy rules; E2E + FCM UX |
| Tasks | — | Not started |

## Firestore Console: why only `users` + `projects`?

Collections **appear only after the first document write**. Declared names in code do not show up empty.

| Collection | Written by app? | How it appears in Console |
|---|---|---|
| `users` | Yes | First sign-in / profile |
| `projects` | Yes | First create/edit project |
| `views` | Yes | Open project detail (`recordView`) — Bishay |
| `requests` | Yes | Successful send (needs `ownerId` + rules) — Mohey |
| `matches` | **No** | Emad must persist (or stays invisible) |
| `feedback` | **No** | Unused |
| `tasks` | **No** | Not built |

FCM tokens live under `users/{uid}/fcmTokens` (subcollection), not a top-level collection.

See the full matrix in [FEATURE_OWNER_GUIDANCE.md](FEATURE_OWNER_GUIDANCE.md#firestore-console-checklist-why-you-only-see-some-collections).
