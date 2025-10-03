# Recommendation Evaluation & Rollout Plan

## Success Metrics
- **Engagement**: session duration (+20%), average watch completion (+15%), daily return rate (D30 retention).
- **Cultural Impact**: content diversity index (distinct cultural families per 10 stories), guardian satisfaction score (>4/5).
- **Trust & Safety**: 0 critical incidents, <1% content requiring retroactive takedown.
- **Explainability**: 80% of users agree explanations feel accurate (survey prompt).

## Offline Evaluation
1. Assemble labelled validation set with guardian-provided relevance scores.
2. Compute metrics: precision@k, recall@k, normalized discounted cumulative gain (nDCG), diversity coverage, cultural fairness (exposure vs catalogue).
3. Stress-test cold start scenarios (ally onboarding, diaspora youth) using synthetic profiles.

## Online Experimentation
- Launch feature flag `personalized_feed_v1` for internal QA, then 5% public cohorts.
- Track guard-rail dashboards updated hourly; auto-disable flag if diversity index drops below threshold.
- Run A/B test vs. curated baseline; measure key metrics over minimum 7 days.

## QA Checklist
- Manual review of top 50 recommendations per persona by cultural guardians.
- Validate “Why you’re seeing this” copy matches stored reasons.
- Simulate network loss to confirm offline fallback uses stored list.
- Confirm opt-out flow reverts to chronological feed.

## Instrumentation & Logging
- Log recommendation requests/responses with anonymized user id, features, explanation, chosen items.
- Persist exposure events to `recommendation_logs` for audits.
- Send outcome events (`watch_complete`, `skip`, `more_like_this`, `mute_topic`) via telemetry client.

## Testing Strategy
- **Unit**: RecommendationEngine scoring cases, preference serialization, explanation generation.
- **Widget**: VideoStoryPage explanation card renders and hides as expected.
- **Integration**: FeedController fetches recommendations and handles empty states.
- **Golden / Snapshot**: Validate explanation UI theme across light/dark.

## Rollout Phases
1. **Alpha**: team-only with manual playlist overrides; gather qualitative feedback.
2. **Beta**: limited community cohort, collect guardian feedback + track metrics.
3. **General Availability**: once metrics surpass baseline and governance board signs off.

## Future Enhancements
- Add cross-surface bundles (archive, community, music) with shared scoring.
- Integrate multi-armed bandit to balance curated playlists with algorithmic picks.
- Introduce user controls for slider-based personalization (e.g., “more language”, “more music”).
- Build automated fairness audits comparing distribution vs. catalogue.
