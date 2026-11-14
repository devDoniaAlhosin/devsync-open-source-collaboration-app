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
