# Supabase Publishing Pipeline

This scope moves creator drafts from device-only storage into a Supabase-backed feed while keeping the capture flow minimalist.

## 1. Storage & Buckets
- Create a storage bucket `stories` with public read access scoped via policies.
- Allow authenticated users to upload to `stories/raw/{userId}/{uuid}.mp4` and optionally `stories/thumbs/{uuid}.jpg`.
- Enforce max file size/duration via RLS function or edge hook.

## 2. Database Tables
| table | purpose | key columns |
| --- | --- | --- |
| `videos` | canonical feed records | `id uuid pk`, `creator_id uuid`, `video_url text`, `thumbnail_url text`, `title_en`, `title_fr`, `description_en`, `description_fr`, `location_en`, `location_fr`, `media_kind text`, `video_source text`, `music_track_id text`, `effect_id text`, `likes int`, `comments int`, `shares int`, `tags text[]`, `created_at timestamptz default now()` |
| `video_uploads` | transient uploads awaiting moderation | `id uuid pk`, `creator_id uuid`, `file_path text`, `thumbnail_path text`, `status text` (`pending`, `approved`, `rejected`), `metadata jsonb`, `created_at` |
| `video_moderation` | decisions log | `id uuid pk`, `video_id uuid`, `moderator_id uuid`, `decision text`, `notes text`, `created_at` |

Indexes: `videos (created_at desc)`, `video_uploads (creator_id, created_at desc)`.

## 3. RLS Policies
- `video_uploads`: creators can insert rows for themselves; moderators/service role can update status; creators can read own rows.
- `videos`: public read; insert/update restricted to service role (moderation function) to keep review lightweight.
- Storage bucket policies mirror table access: creators write to `stories/raw/{auth.uid()}/**` and read their own; service role/full app can read approved files.

## 4. Edge Functions / Supabase Functions
1. **`process-upload`** (invoked after app posts draft metadata)
   - Validates payload (duration, aspect ratio, file presence in storage, content type).
   - Writes to `video_uploads` with `pending` status.
   - Optionally triggers encoding pipeline (Mux, FFmpeg job) and thumbnail generation via queued job.
2. **`approve-upload`** (moderator endpoint or automated rule)
   - Moves metadata into `videos` table.
   - Copies/renames storage assets from `stories/raw` to `stories/published`.
   - Updates `video_uploads.status = 'approved'` and records in `video_moderation`.
3. **`reject-upload`**
   - Marks record as `rejected`, optionally deletes raw assets, notifies creator.

Use database triggers or Cron to clean up stale `pending` uploads older than N hours.

## 5. Client Flow Changes
1. **Publish CTA** (existing `_handlePublish`)
   - After building `VideoPost`, call new `SupabasePublisher.submitDraft` service.
   - Service uploads file + optional thumbnail to storage, returns storage paths.
   - POST `/functions/v1/process-upload` with metadata (titles, locales, tags, effect, duration, aspect ratio).
   - Show existing “saved locally” snackbar; optionally surface toast indicating review state.
2. **Draft State**
   - Persist `video_uploads` status locally via `PreferenceStore` so creators can see “pending” or “approved” badges.
   - When feed refreshes, if uploaded video is approved, remote post supersedes local draft (matching on `id`).

## 6. Minimal UI Additions
- In review sheet, replace “Publish” tooltip with translation (done) and, after submission, show a `Pending review` chip on drafts (`VideoPost.isLocalDraft && uploadPending`).
- Optional: simple `Pending` banner in profile/community for creators; avoid new screens.

## 7. Moderation Workflow
- Use Supabase Dashboard or lightweight admin tool to list `video_uploads` where `status = 'pending'`.
- Approve/reject via RPC/Edge function; automation rules can auto-approve trusted users.
- Keep moderation metadata minimal (decision, notes) to stay focused on storytelling rather than heavy compliance.

## 8. Future Hooks
- Add analytics table `video_metrics` for view counts without bloating `videos`.
- Support comments/follows via existing repositories once Supabase credentials are wired.
- Introduce webhooks to notify Discord/Slack channel when new pending upload arrives.

This plan keeps the recording UI lean while ensuring every shared story lands in a moderated, bilingual Supabase feed.
