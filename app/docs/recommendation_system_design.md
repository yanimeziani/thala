# Thela Cultural Recommendation System Design

## Vision & Requirements
- Deliver personalised, culturally respectful story feeds, archive highlights, communities, and music tracks.
- Support hybrid curation (machine + cultural guardians) with transparency and safety controls.
- Operate in Supabase-first stack with option to run lightweight recommendations client-side when offline or during cold-start.

### Key Functional Goals
1. Personalised vertical video feed ranking within `FeedController`.
2. Cross-surface recommendations (archive cards, community spaces, tracks) aligned with the current session intent.
3. Contextual explainability (“Why this story?”) leveraging metadata.
4. Responsiveness <200ms per recommendation request; offline fallback using cached lists.
5. Governance hooks: content sensitivity flags, exposure auditing, guardian overrides.

## High-Level Architecture
```
┌─────────────────────┐     watch/like/share     ┌────────────────────────────┐
│ Flutter Client      │──────────────────────────▶│ Supabase Edge Functions    │
│  - Feed UI          │                           │  - Event logger (telemetry)│
│  - Recommendation   │◀──────────ranked feed─────│  - Rule enforcement        │
│    Service Adapter  │                           └────────────┬───────────────┘
└─────────┬───────────┘                                        │
          │                                                     ▼
          │         nightly batches / streaming        ┌─────────────────────┐
          │────────────────────────────────────────────▶ Feature Store (DBT)│
          │                                             │  - User profile    │
          │                                             │  - Content vectors  │
          │                                             │  - Guardian rules   │
          │                                             └─────────┬──────────┘
          │                                                       │
          │  near real-time                                       ▼
          │────────────────────────────────────────────┌───────────────────────┐
          │                                             │ Recommendation API   │
          │                                             │  - Baseline scorer   │
          │                                             │  - Personalisation   │
          │                                             │  - Diversifier       │
          │                                             └─────────┬───────────┘
          │Offline fallback                                     │
          ▼                                                     ▼
┌─────────────────────┐                                ┌───────────────────────┐
│ Local Cache         │                                │ Governance Dashboard  │
│  - Onboarding prefs │                                │  - Exposure analytics │
│  - Last recommendations                              │  - Guardian overrides│
└─────────────────────┘                                └───────────────────────┘
```

## Data Flow
1. **Instrumentation**: Flutter emits watch start/complete, skip, like, follow, share, “more like this” feedback using a `TelemetryClient` (new service). Edge Functions validate payloads, enrich with session metadata, and persist to Supabase tables.
2. **Onboarding data**: stored locally via `SharedPreferences` and synced to `user_profiles` table once auth available.
3. **Content metadata**: creators tag uploads with structured schema (`culture_family`, `language_code`, `art_form`, `sacred_level`, `tags`). Moderators approve and add guardian flags.
4. **Feature computation**: DBT/Supabase functions aggregate into user/content embeddings, compute freshness scores, guardian trust weights.
5. **Serving**: Flutter requests ranked lists through `RecommendationApiClient`. API merges:
   - Retrieval: candidate generator combining trending, follow graph, curated playlists, and similarity search.
   - Scoring: weighted sum of relevance (profile match), engagement prediction, cultural balance, guardian boost/penalty.
   - Diversification: greedy pass to ensure cultural family/format alternation and safe spacing for sensitive content.
6. **Delivery**: API returns `RecommendationBundle` containing ranked posts, badges, explanation snippets. Client caches for offline usage and to prefetch adjacent items.
7. **Feedback loop**: exposures + interactions fed back for evaluation dashboards.

## Component Breakdown

### Client (Flutter)
- `RecommendationService` (new) orchestrates between local heuristics and remote API.
- `PreferenceStore` persists onboarding and explicit feedback.
- `FeedController` updated to request recommendations instead of raw chronological list.
- UI surfaces “Why recommended” + controls (mute topic, request more like this).

### Supabase Layer
- Tables: `user_profiles`, `user_engagement_events`, `content_metadata`, `guardian_overrides`, `recommendation_logs`.
- Edge Functions: input validation, rights enforcement (block sacred content for general audience).
- Row-Level Security ensures only rightful access.

### Analytics & Modelling
- Deploy DBT pipelines to materialize daily aggregations.
- Optionally use external worker (Cloud Run, Fly.io) for heavier training tasks.
- Models stored in Supabase storage or huggingface-like bucket; API loads current model on startup.

### Recommendation API
- Exposed via Supabase Functions or external microservice.
- Modules:
  1. **Candidate Provider**: trending, follow, content similarity (using embeddings), curated sets.
  2. **Personalization Scorer**: logistic regression or gradient boosted trees initially; feature inputs from user/content vectors.
  3. **Cultural Diversifier**: ensures each top-N window covers multiple regions/languages.
  4. **Guardian Rule Engine**: final filter enforcing sacred content policies and manual boosts.

### Offline / Cold Start Handling
- If API unavailable, fallback to local heuristic: reorder cached feed using onboarding preferences and content metadata.
- Ship curated playlists for new users segmented by onboarding answers (diaspora, curious ally, etc.).

## Data Models (Draft)
```sql
create table user_profiles (
  user_id uuid primary key,
  is_amazigh boolean,
  country text,
  cultural_family text,
  discovery_source text,
  is_interested boolean,
  language_preference text,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

create table user_engagement_events (
  event_id uuid primary key default gen_random_uuid(),
  user_id uuid references user_profiles(user_id),
  content_id text,
  content_type text check (content_type in ('video','community','archive','music')),
  event_type text check (event_type in ('watch_start','watch_complete','skip','like','share','follow','more_like_this','mute_topic')),
  event_value jsonb,
  occurred_at timestamp default now()
);

create table content_metadata (
  content_id text primary key,
  content_type text,
  creator_handle text,
  culture_family text,
  region text,
  language_code text,
  art_form text,
  sacred_level text,
  tags text[],
  guardian_status text,
  created_at timestamp default now(),
  updated_at timestamp default now()
);
```

## Integration Touchpoints
- `FeedController._load()` → `RecommendationService.fetchRecommendedFeed(userId)`.
- `FeedActionsRepository` → augmented to log engagement events asynchronously via `TelemetryClient`.
- Onboarding flow completion → call `PreferenceStore.save(answers)` + optional `RecommendationService.syncPreferences()`.
- UI addition for explanation panel using metadata from `RecommendationBundle`.

## Deployment & Observability
- Version gating via feature flags: `rec_engine_v1`, `personalized_feed_enabled`.
- Metrics: request latency, cache hit rate, cultural diversity index, guardian override rate.
- Logging: store top-K outputs per cohort for after-the-fact audits.

## Scalability Considerations
- Start with serverless functions (Supabase) for scoring; migrate to dedicated service if latency or concurrency becomes bottleneck.
- Embedding generation can use third-party API (e.g., OpenAI text-embedding-3-large) under caching policy; plan for on-prem alternatives for sovereignty.
- Partition data by region for residency requirements if needed.

## Security & Privacy
- Encrypt sensitive guardian metadata at rest.
- Respect user opt-out for personalization by falling back to non-personalised curated feed.
- Ensure compliance with cultural data sovereignty guidelines; store data in regions approved by governance board.

## Roadmap Phasing
1. **Phase 0 (Prototype)**: local heuristic scoring + manual curation, basic telemetry logging.
2. **Phase 1 (Hybrid)**: Supabase-hosted API with metadata-driven ranking, explanation UI, guardian rules.
3. **Phase 2 (ML-driven)**: add collaborative filtering, embeddings, experimentation platform.
4. **Phase 3 (Advanced)**: session-based modelling, cross-surface orchestration, real-time adaptive sequencing.
