# Cultural Recommendation Research for Thala

## Mission Context
- **Objective**: help Amazigh people and allies rediscover cultural practices, stories, and music through an addictive-yet-respectful discovery engine.
- **North stars**: daily return habit, meaningful cultural learning per session, representation equity across Amazigh regions/diaspora, and strong trust from cultural guardians.

## Audience States & Use Cases
| Persona | Relationship to Amazigh culture | Key jobs-to-be-done | Recommendation implications |
|---------|---------------------------------|----------------------|-----------------------------|
| Diaspora youth | Grew up away from homeland, partial fluency | Find bite-sized lore, language micro-lessons, community meetups | Highlight diaspora-tagged stories, language primer playlists, near-by events |
| Culture keepers | Elders or practitioners stewarding traditions | Share knowledge, see respectful reuse | Boost reach for guardian-approved content, surface impact metrics |
| Curious allies | Non-Amazigh audience seeking context | Learn etiquette, basics, signal support opportunities | Onboard with contextual explainers, curated starter packs |
| Creative collaborators | Artists/DJs sampling Amazigh music | Discover remix-friendly stems, credit best practices | Recommend tracks with licensing info, show collaborative projects |

## Cultural Signal Inventory
| Signal | Status | Notes |
|--------|--------|-------|
| Onboarding answers (`isAmazigh`, `country`, `culturalFamily`, `discoverySource`, `isInterested`) | Available (client-side) | Persist locally + sync to Supabase for cross-device personalization. |
| Content metadata (`tags`, `location`, `creator_handle`, `likes/comments/shares`) | Partial (sample data + Supabase schema) | Extend to structured facets: region, language, art-form, sacredness level. |
| Engagement telemetry (watch time, likes, shares, follows, skips) | Not yet collected | Instrument via Supabase Edge Functions / analytics pipeline. |
| Social graph (follows, community membership) | Minimal | Model as bipartite graph (users ↔ creators/communities). |
| Archive & music catalog metadata | Available (sample data) | Normalize categories into shared taxonomy so cross-surface recs make sense. |
| Cultural stewardship flags (guardian approvals, content sensitivity) | Missing | Needed to apply access controls + fairness constraints. |

## External & Open Data Sources
1. **UNESCO Intangible Cultural Heritage** entries for Amazigh practices: metadata for rituals, music, craftsmanship. Use for enrichment + fact panels.
2. **Ethnologue / Glottolog** datasets for language dialect relationships → improve linguistic clustering.
3. **OpenStreetMap & Wikidata** for geocoding Amazigh regions, diaspora hubs.
4. **Creative Commons Amazigh media collections** (e.g., Internet Archive, Wikimedia Commons) for cold-start content.
5. **Academic corpora** (Amazigh oral histories) to populate knowledge graph relationships.

## Algorithm Landscape
| Layer | Approach | Rationale |
|-------|----------|-----------|
| Baseline ranking | Hybrid scoring combining recency, engagement velocity, cultural relevance boost | Ensures fresh content while keeping culture-aligned posts visible. |
| Personalization | Content-based filtering using user preference vectors (cultural family, topics, language) | Works with sparse user base; leverages rich metadata. |
| Collaborative signals | Implicit matrix factorization / neural CF on watch, like, share events | Activates once scale >10k users; cluster shared taste within diaspora segments. |
| Sequence modelling | Transformer/RNN to capture session-level dwell + completion | Drives streak-like experiences after baseline stable. |
| Knowledge-aware reranking | Graph-based diversification (Node2Vec / personalized PageRank) across culture, creator, community nodes | Protects against monoculture feeds; surfaces adjacent traditions. |
| Curator-in-the-loop | Manual playlists tagged by cultural guardians, merged via multi-armed bandits | Maintains human oversight, safeguards sacred content. |

## Relevance Signals & Feature Engineering
- **User profile vector**: one-hot or embedding for cultural family, countries of interest, language preference, diaspora vs homeland, learning intent.
- **Content vector**: bag-of-tags, Tifinagh keyword detection, audio fingerprint cluster, creator region, sacredness level.
- **Engagement features**: normalized watch completion, skips, replays, share rate, time-of-day usage.
- **Contextual features**: session stage (onboarding, depth >3), network quality (prefer shorter clips on low bandwidth), calendar cues (festivals, Yennayer).
- **Diversity constraints**: enforce rotation across cultural families/genres; limit consecutive commercialized remixes if user seeks heritage content.

## Ethics & Trust Guardrails
- Maintain a **sensitive content registry** curated with cultural guardians; block or gate recommendations when context missing.
- Audit recommendation outputs for regional/language bias; track exposure parity relative to content pool.
- Provide **Why this story?** transparency with cultural attribution details.
- Offer user controls: mute region/topic, request more language practice, opt-out of personalization.
- Capture explicit feedback loops ("More like this", "Respectful enough?", "Report misuse").

## Data & Experimentation Roadmap
1. **Instrumentation**: ensure Supabase tables/logging capture watch completions, skip timestamps, onboarding answers, follow relationships.
2. **Data warehouse**: replicate operational data into analytics-friendly store (e.g., Supabase → BigQuery / DuckDB) for modelling.
3. **Feature pipelines**: nightly batch jobs to compute user/content embeddings; optionally lightweight on-device caching for cold-start.
4. **Evaluation suite**: define offline metrics (precision@k, coverage, cultural diversity index) + online metrics (session length, retention, guardian satisfaction surveys).
5. **Experimentation**: launch gated A/B infra (feature flags) to test scoring tweaks with cultural review board oversight.

## Open Research Questions
- How to encode guardian knowledge so sacred content respects usage rights? Potential approach: rule-based filters with manual overrides.
- What is the right balance between nostalgia-driven content vs forward-looking creative remixes?
- How to support multilingual subtitles and transliteration for low-resource dialects? Explore crowd-sourced annotation workflows.
- How to augment recommendations with community actions (e.g., nudge to join event after viewing related story)?

## Immediate Recommendations
1. Persist onboarding answers and start logging lightweight engagement metrics client-side → Supabase buckets.
2. Create a shared cultural taxonomy (regions, dialects, art forms, rituals) to tag all surfaces.
3. Prototype a metadata-driven recommender locally (see implementation plan) to validate scoring heuristics before investing in ML stack.
4. Convene a cultural review circle to set redlines on sacred content handling and define fairness targets.
