-- Thala Supabase schema and seed data
-- Run this file with psql or supabase db reset to provision required tables.

BEGIN;

-- Ensure UUID generation helpers are available.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------- Lookup tables ----------

CREATE TABLE IF NOT EXISTS public.music_tracks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  artwork_url TEXT,
  duration_seconds INTEGER NOT NULL CHECK (duration_seconds >= 0),
  preview_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.music_tracks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read music tracks" ON public.music_tracks;
CREATE POLICY "Read music tracks" ON public.music_tracks
  FOR SELECT
  USING (true);

CREATE TABLE IF NOT EXISTS public.video_effects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  config JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.video_effects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read video effects" ON public.video_effects;
CREATE POLICY "Read video effects" ON public.video_effects
  FOR SELECT
  USING (true);

-- ---------- Core media tables ----------

CREATE TABLE IF NOT EXISTS public.videos (
  id TEXT PRIMARY KEY,
  creator_id UUID REFERENCES auth.users ON DELETE SET NULL,
  creator_handle TEXT NOT NULL,
  creator_name_en TEXT,
  creator_name_fr TEXT,
  video_url TEXT NOT NULL,
  video_source TEXT NOT NULL DEFAULT 'network' CHECK (video_source IN ('network', 'asset', 'local')),
  media_kind TEXT NOT NULL DEFAULT 'video' CHECK (media_kind IN ('video', 'image', 'post')),
  image_url TEXT,
  gallery_urls TEXT[] NOT NULL DEFAULT '{}',
  text_slides JSONB NOT NULL DEFAULT '[]'::JSONB,
  aspect_ratio NUMERIC(6,3),
  thumbnail_url TEXT,
  music_track_id TEXT REFERENCES public.music_tracks(id),
  effect_id TEXT REFERENCES public.video_effects(id),
  title_en TEXT NOT NULL,
  title_fr TEXT NOT NULL,
  description_en TEXT NOT NULL DEFAULT '',
  description_fr TEXT NOT NULL DEFAULT '',
  location_en TEXT NOT NULL DEFAULT '',
  location_fr TEXT NOT NULL DEFAULT '',
  likes INTEGER NOT NULL DEFAULT 0 CHECK (likes >= 0),
  comments INTEGER NOT NULL DEFAULT 0 CHECK (comments >= 0),
  shares INTEGER NOT NULL DEFAULT 0 CHECK (shares >= 0),
  tags TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS videos_created_at_idx ON public.videos (created_at DESC);
CREATE INDEX IF NOT EXISTS videos_creator_handle_idx ON public.videos (creator_handle);

ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read videos" ON public.videos;
CREATE POLICY "Read videos" ON public.videos
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Update video counters" ON public.videos;
CREATE POLICY "Update video counters" ON public.videos
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Publish videos when authenticated" ON public.videos;
CREATE POLICY "Publish videos when authenticated" ON public.videos
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Maintain updated_at on change.
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS videos_touch_updated_at ON public.videos;
CREATE TRIGGER videos_touch_updated_at
BEFORE UPDATE ON public.videos
FOR EACH ROW
EXECUTE FUNCTION public.touch_updated_at();

-- Comments recorded against videos.
CREATE TABLE IF NOT EXISTS public.video_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id TEXT NOT NULL REFERENCES public.videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE SET NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS video_comments_video_idx
  ON public.video_comments (video_id, created_at DESC);

ALTER TABLE public.video_comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read video comments" ON public.video_comments;
CREATE POLICY "Read video comments" ON public.video_comments
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Insert own video comments" ON public.video_comments;
CREATE POLICY "Insert own video comments" ON public.video_comments
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Shares of videos.
CREATE TABLE IF NOT EXISTS public.video_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id TEXT NOT NULL REFERENCES public.videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE SET NULL,
  shared_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS video_shares_video_idx
  ON public.video_shares (video_id, shared_at DESC);

ALTER TABLE public.video_shares ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read video shares" ON public.video_shares;
CREATE POLICY "Read video shares" ON public.video_shares
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Insert own video shares" ON public.video_shares;
CREATE POLICY "Insert own video shares" ON public.video_shares
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Maintain aggregate counters on videos for comments and shares.
CREATE OR REPLACE FUNCTION public.sync_video_comment_counter()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.videos
      SET comments = comments + 1,
          updated_at = NOW()
      WHERE id = NEW.video_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.videos
      SET comments = GREATEST(comments - 1, 0),
          updated_at = NOW()
      WHERE id = OLD.video_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS video_comments_counter_insert ON public.video_comments;
CREATE TRIGGER video_comments_counter_insert
AFTER INSERT ON public.video_comments
FOR EACH ROW
EXECUTE FUNCTION public.sync_video_comment_counter();

DROP TRIGGER IF EXISTS video_comments_counter_delete ON public.video_comments;
CREATE TRIGGER video_comments_counter_delete
AFTER DELETE ON public.video_comments
FOR EACH ROW
EXECUTE FUNCTION public.sync_video_comment_counter();

CREATE OR REPLACE FUNCTION public.sync_video_share_counter()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.videos
      SET shares = shares + 1,
          updated_at = NOW()
      WHERE id = NEW.video_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.videos
      SET shares = GREATEST(shares - 1, 0),
          updated_at = NOW()
      WHERE id = OLD.video_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS video_shares_counter_insert ON public.video_shares;
CREATE TRIGGER video_shares_counter_insert
AFTER INSERT ON public.video_shares
FOR EACH ROW
EXECUTE FUNCTION public.sync_video_share_counter();

DROP TRIGGER IF EXISTS video_shares_counter_delete ON public.video_shares;
CREATE TRIGGER video_shares_counter_delete
AFTER DELETE ON public.video_shares
FOR EACH ROW
EXECUTE FUNCTION public.sync_video_share_counter();

-- Follower relationships for creators.
CREATE TABLE IF NOT EXISTS public.creator_followers (
  creator_handle TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  followed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (creator_handle, user_id)
);

CREATE INDEX IF NOT EXISTS creator_followers_user_idx
  ON public.creator_followers (user_id);

ALTER TABLE public.creator_followers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Manage own creator follows" ON public.creator_followers;
CREATE POLICY "Manage own creator follows" ON public.creator_followers
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ---------- Messaging tables ----------

CREATE TABLE IF NOT EXISTS public.message_threads (
  id TEXT PRIMARY KEY,
  title_en TEXT NOT NULL,
  title_fr TEXT NOT NULL,
  last_message_en TEXT NOT NULL DEFAULT '',
  last_message_fr TEXT NOT NULL DEFAULT '',
  unread_count INTEGER NOT NULL DEFAULT 0 CHECK (unread_count >= 0),
  participants TEXT[] NOT NULL DEFAULT '{}',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS message_threads_updated_idx
  ON public.message_threads (updated_at DESC);

ALTER TABLE public.message_threads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read message threads" ON public.message_threads;
CREATE POLICY "Read message threads" ON public.message_threads
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

DROP TRIGGER IF EXISTS message_threads_touch_updated_at ON public.message_threads;
CREATE TRIGGER message_threads_touch_updated_at
BEFORE UPDATE ON public.message_threads
FOR EACH ROW
EXECUTE FUNCTION public.touch_updated_at();

CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id TEXT NOT NULL REFERENCES public.message_threads(id) ON DELETE CASCADE,
  author_handle TEXT NOT NULL,
  author_display_name TEXT NOT NULL,
  body TEXT NOT NULL,
  delivery_status TEXT NOT NULL DEFAULT 'sent'
    CHECK (delivery_status IN ('pending', 'sent', 'delivered', 'read', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS messages_thread_idx
  ON public.messages (thread_id, created_at DESC);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read messages" ON public.messages;
CREATE POLICY "Read messages" ON public.messages
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE OR REPLACE FUNCTION public.update_thread_from_message()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  UPDATE public.message_threads
    SET last_message_en = NEW.body,
        last_message_fr = NEW.body,
        updated_at = NEW.created_at
    WHERE id = NEW.thread_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS messages_thread_touch ON public.messages;
CREATE TRIGGER messages_thread_touch
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.update_thread_from_message();

-- ---------- Community tables ----------

CREATE TABLE IF NOT EXISTS public.community_views (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  community_id TEXT NOT NULL,
  user_id UUID REFERENCES auth.users ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS community_views_community_idx
  ON public.community_views (community_id, created_at DESC);

ALTER TABLE public.community_views ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read community views" ON public.community_views;
CREATE POLICY "Read community views" ON public.community_views
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Record community view" ON public.community_views;
CREATE POLICY "Record community view" ON public.community_views
  FOR INSERT
  WITH CHECK (user_id IS NULL OR auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.community_host_requests (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  user_id UUID REFERENCES auth.users ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'reviewed', 'approved', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS community_host_requests_status_idx
  ON public.community_host_requests (status, created_at DESC);

ALTER TABLE public.community_host_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read community host requests" ON public.community_host_requests;
CREATE POLICY "Read community host requests" ON public.community_host_requests
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Submit community host requests" ON public.community_host_requests;
CREATE POLICY "Submit community host requests" ON public.community_host_requests
  FOR INSERT
  WITH CHECK (user_id IS NULL OR auth.uid() = user_id);

-- Cultural knowledge and discovery tables.

CREATE TABLE IF NOT EXISTS public.community_profiles (
  id TEXT PRIMARY KEY,
  space JSONB NOT NULL,
  region TEXT NOT NULL,
  languages TEXT[] NOT NULL DEFAULT '{}',
  priority NUMERIC NOT NULL DEFAULT 0,
  cards JSONB NOT NULL DEFAULT '[]'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS community_profiles_priority_idx
  ON public.community_profiles (priority DESC, created_at DESC);

ALTER TABLE public.community_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read community profiles" ON public.community_profiles;
CREATE POLICY "Read community profiles" ON public.community_profiles
  FOR SELECT
  USING (true);

CREATE TABLE IF NOT EXISTS public.archive_entries (
  id TEXT PRIMARY KEY,
  title JSONB NOT NULL,
  summary JSONB NOT NULL,
  era JSONB NOT NULL,
  category TEXT,
  thumbnail_url TEXT NOT NULL,
  community_upvotes INTEGER NOT NULL DEFAULT 0,
  registered_users INTEGER NOT NULL DEFAULT 0,
  required_approval_percent NUMERIC NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS archive_entries_created_idx
  ON public.archive_entries (created_at DESC);

ALTER TABLE public.archive_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read archive entries" ON public.archive_entries;
CREATE POLICY "Read archive entries" ON public.archive_entries
  FOR SELECT
  USING (true);

CREATE TABLE IF NOT EXISTS public.cultural_events (
  id TEXT PRIMARY KEY,
  title JSONB NOT NULL,
  date_label JSONB NOT NULL,
  location JSONB NOT NULL,
  description JSONB NOT NULL,
  additional_detail JSONB,
  mode TEXT NOT NULL CHECK (mode IN ('in_person', 'online', 'hybrid')),
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ,
  tags JSONB NOT NULL DEFAULT '[]'::JSONB,
  cta_label JSONB NOT NULL,
  cta_note JSONB NOT NULL,
  background_colors TEXT[] NOT NULL DEFAULT '{}',
  hero_image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS cultural_events_schedule_idx
  ON public.cultural_events (start_at DESC, created_at DESC);

ALTER TABLE public.cultural_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read cultural events" ON public.cultural_events;
CREATE POLICY "Read cultural events" ON public.cultural_events
  FOR SELECT
  USING (true);

CREATE TABLE IF NOT EXISTS public.content_profiles (
  content_id TEXT PRIMARY KEY,
  cultural_families TEXT[] NOT NULL DEFAULT '{}',
  regions TEXT[] NOT NULL DEFAULT '{}',
  languages TEXT[] NOT NULL DEFAULT '{}',
  topics TEXT[] NOT NULL DEFAULT '{}',
  energy TEXT,
  sacred_level TEXT,
  is_guardian_approved BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.content_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Read content profiles" ON public.content_profiles;
CREATE POLICY "Read content profiles" ON public.content_profiles
  FOR SELECT
  USING (true);

-- ---------- Seeds ----------

INSERT INTO public.content_profiles (
  content_id,
  cultural_families,
  regions,
  languages,
  topics,
  energy,
  sacred_level,
  is_guardian_approved
)
VALUES
  (
    'imzad-rhythms',
    ARRAY['Tuareg'],
    ARRAY['Hoggar', 'Algeria', 'Sahara'],
    ARRAY['Tamahaq'],
    ARRAY['Music', 'Instrumental', 'Heritage'],
    'Calm',
    'guardian_reviewed',
    TRUE
  ),
  (
    'agadir-dance',
    ARRAY['Shilha / Tashelhit'],
    ARRAY['Agadir', 'Morocco'],
    ARRAY['Tashelhit'],
    ARRAY['Dance', 'Festival', 'Community'],
    'High',
    'public_celebration',
    FALSE
  ),
  (
    'kabyle-poetry',
    ARRAY['Kabyle'],
    ARRAY['Kabylie', 'Algeria', 'Paris'],
    ARRAY['Kabyle', 'French'],
    ARRAY['Poetry', 'Diaspora', 'Spoken Word'],
    'Reflective',
    'public_celebration',
    FALSE
  ),
  (
    'rif-bread',
    ARRAY['Rifian'],
    ARRAY['Rif', 'Morocco', 'Nador'],
    ARRAY['Tarifit'],
    ARRAY['Food', 'Heritage', 'Everyday Life'],
    'Warm',
    'household_practice',
    FALSE
  )
ON CONFLICT (content_id) DO UPDATE
SET cultural_families = EXCLUDED.cultural_families,
    regions = EXCLUDED.regions,
    languages = EXCLUDED.languages,
    topics = EXCLUDED.topics,
    energy = EXCLUDED.energy,
    sacred_level = EXCLUDED.sacred_level,
    is_guardian_approved = EXCLUDED.is_guardian_approved;

INSERT INTO public.archive_entries (
  id,
  title,
  summary,
  era,
  category,
  thumbnail_url,
  community_upvotes,
  registered_users,
  required_approval_percent
)
VALUES
  (
    'ancestral-tar',
    jsonb_build_object('en', 'Ancestral Tar Artwork', 'fr', 'Œuvre ancestrale du tar'),
    jsonb_build_object(
      'en', 'Exploring embroidered motifs from Aurès artisans preserved since 1920.',
      'fr', 'Motifs brodés des artisanes de l''Aurès conservés depuis 1920.'
    ),
    jsonb_build_object('en', 'Aurès · 1920s', 'fr', 'Aurès · Années 1920'),
    'Textile',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80',
    8200,
    12000,
    60
  ),
  (
    'ahwach-oral',
    jsonb_build_object('en', 'Ahouach Oral Histories', 'fr', 'Histoires orales ahouach'),
    jsonb_build_object(
      'en', 'Digitised chants celebrating the first harvest moon.',
      'fr', 'Chants numérisés célébrant la première lune des récoltes.'
    ),
    jsonb_build_object('en', 'Agadir · 1968', 'fr', 'Agadir · 1968'),
    'Audio',
    'https://images.unsplash.com/photo-1523419409543-0c1df022bdd1?auto=format&fit=crop&w=800&q=80',
    5400,
    8600,
    55
  ),
  (
    'blue-tifinagh',
    jsonb_build_object('en', 'Indigo Tifinagh Banner', 'fr', 'Bannière tifinagh indigo'),
    jsonb_build_object(
      'en', 'Handwoven banner used in Amazigh student movements.',
      'fr', 'Bannière tissée utilisée par les mouvements étudiants amazighs.'
    ),
    jsonb_build_object('en', 'Rabat · 1984', 'fr', 'Rabat · 1984'),
    'Archive',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80',
    4800,
    7000,
    50
  )
ON CONFLICT (id) DO UPDATE
SET title = EXCLUDED.title,
    summary = EXCLUDED.summary,
    era = EXCLUDED.era,
    category = EXCLUDED.category,
    thumbnail_url = EXCLUDED.thumbnail_url,
    community_upvotes = EXCLUDED.community_upvotes,
    registered_users = EXCLUDED.registered_users,
    required_approval_percent = EXCLUDED.required_approval_percent;

INSERT INTO public.cultural_events (
  id,
  title,
  date_label,
  location,
  description,
  additional_detail,
  mode,
  start_at,
  end_at,
  tags,
  cta_label,
  cta_note,
  background_colors,
  hero_image_url
)
VALUES
  (
    'agadir-film-night',
    jsonb_build_object(
      'en', 'Agadir Amazigh Film Night',
      'fr', 'Soirée cinéma amazighe à Agadir'
    ),
    jsonb_build_object('en', 'March 23, 2024 · 19:00', 'fr', '23 mars 2024 · 19 h 00'),
    jsonb_build_object('en', 'Agadir, Morocco', 'fr', 'Agadir, Maroc'),
    jsonb_build_object(
      'en', 'Screenings of shorts celebrating Amazigh storytellers followed by a Q&A with local directors.',
      'fr', 'Projection de courts métrages mettant en lumière des conteurs amazighs, suivie d’une discussion avec des réalisateurs locaux.'
    ),
    jsonb_build_object(
      'en', 'Hosted at Dar Lfenn. Doors open at 18:30. Seats are limited—RSVP required.',
      'fr', 'Organisé à Dar Lfenn. Ouverture des portes à 18 h 30. Places limitées : réservation obligatoire.'
    ),
    'in_person',
    TIMESTAMPTZ '2024-03-23T19:00:00+00',
    TIMESTAMPTZ '2024-03-23T22:00:00+00',
    to_jsonb(ARRAY[
      jsonb_build_object('en', 'Cinema', 'fr', 'Cinéma'),
      jsonb_build_object('en', 'Community', 'fr', 'Communauté')
    ]),
    jsonb_build_object('en', 'Reserve a seat', 'fr', 'Réserver une place'),
    jsonb_build_object(
      'en', 'We will follow up with availability details for Agadir Amazigh Film Night.',
      'fr', 'Nous vous contacterons avec les détails de disponibilité pour la soirée cinéma amazighe d’Agadir.'
    ),
    ARRAY['#2A1B4A', '#36254F', '#4B2C6B'],
    'https://images.unsplash.com/photo-1542204165-65bf26472b9b?auto=format&fit=crop&w=1200&q=80'
  ),
  (
    'language-lab-livestream',
    jsonb_build_object(
      'en', 'Amazigh Language Lab Livestream',
      'fr', 'Laboratoire de langue amazighe en direct'
    ),
    jsonb_build_object('en', 'April 5, 2024 · 16:00 GMT', 'fr', '5 avril 2024 · 16 h 00 GMT'),
    jsonb_build_object('en', 'Online broadcast', 'fr', 'Diffusion en ligne'),
    jsonb_build_object(
      'en', 'Interactive session on new teaching tools for Tamazight educators, streamed with live captions.',
      'fr', 'Session interactive sur les nouveaux outils pédagogiques pour les enseignants de tamazight, diffusée avec sous-titres en direct.'
    ),
    jsonb_build_object(
      'en', 'Featuring guests from the Kabylia Language Cooperative and the Atlas Cultural Lab.',
      'fr', 'Avec la participation de la Coopérative linguistique kabyle et du Laboratoire culturel de l’Atlas.'
    ),
    'online',
    TIMESTAMPTZ '2024-04-05T16:00:00+00',
    TIMESTAMPTZ '2024-04-05T18:00:00+00',
    to_jsonb(ARRAY[
      jsonb_build_object('en', 'Education', 'fr', 'Éducation'),
      jsonb_build_object('en', 'Livestream', 'fr', 'Diffusion en direct')
    ]),
    jsonb_build_object('en', 'Get streaming link', 'fr', 'Recevoir le lien'),
    jsonb_build_object(
      'en', 'We will email the livestream link 24 hours before the Language Lab session.',
      'fr', 'Nous enverrons le lien de diffusion 24 heures avant la session du Laboratoire de langue.'
    ),
    ARRAY['#0F2027', '#203A43', '#2C5364'],
    'https://images.unsplash.com/photo-1522199755839-a2bacb67c546?auto=format&fit=crop&w=1200&q=80'
  ),
  (
    'montreal-tifawin-week',
    jsonb_build_object(
      'en', 'Tifawin Cultural Week',
      'fr', 'Semaine culturelle Tifawin'
    ),
    jsonb_build_object('en', 'April 18–21, 2024', 'fr', '18–21 avril 2024'),
    jsonb_build_object('en', 'Montreal & online sessions', 'fr', 'Montréal & sessions en ligne'),
    jsonb_build_object(
      'en', 'A hybrid celebration featuring Amazigh film, poetry, and culinary pop-ups across Montreal.',
      'fr', 'Un festival hybride mêlant cinéma, poésie et pop-ups culinaires amazighs à Montréal.'
    ),
    jsonb_build_object(
      'en', 'Community partners include Tifawin Montréal and Amazigh Women of Canada.',
      'fr', 'Avec la participation de Tifawin Montréal et du Collectif des femmes amazighes du Canada.'
    ),
    'hybrid',
    TIMESTAMPTZ '2024-04-18T15:00:00+00',
    TIMESTAMPTZ '2024-04-21T22:00:00+00',
    to_jsonb(ARRAY[
      jsonb_build_object('en', 'Festival', 'fr', 'Festival'),
      jsonb_build_object('en', 'Diaspora', 'fr', 'Diaspora')
    ]),
    jsonb_build_object('en', 'Join the programme', 'fr', 'Découvrir le programme'),
    jsonb_build_object(
      'en', 'We will send the hybrid schedule and registration instructions for Tifawin Cultural Week.',
      'fr', 'Vous recevrez le programme hybride et les modalités d’inscription pour la semaine culturelle Tifawin.'
    ),
    ARRAY['#1B3B5A', '#274D6A', '#3E6F8C'],
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80'
  )
ON CONFLICT (id) DO UPDATE
SET title = EXCLUDED.title,
    date_label = EXCLUDED.date_label,
    location = EXCLUDED.location,
    description = EXCLUDED.description,
    additional_detail = EXCLUDED.additional_detail,
    mode = EXCLUDED.mode,
    start_at = EXCLUDED.start_at,
    end_at = EXCLUDED.end_at,
    tags = EXCLUDED.tags,
    cta_label = EXCLUDED.cta_label,
    cta_note = EXCLUDED.cta_note,
    background_colors = EXCLUDED.background_colors,
    hero_image_url = EXCLUDED.hero_image_url;

INSERT INTO public.community_profiles (
  id,
  space,
  region,
  languages,
  priority,
  cards
)
VALUES
  (
    'fk2q',
    jsonb_build_object(
      'id', 'fk2q',
      'name', jsonb_build_object(
        'en', 'Kabyle Forum of Québec City',
        'fr', 'Forum Kabyle de la Ville de Québec'
      ),
      'description', jsonb_build_object('en', '', 'fr', ''),
      'location', jsonb_build_object(
        'en', 'Québec City, QC',
        'fr', 'Ville de Québec, QC'
      ),
      'imageUrl',
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=900&q=80',
      'memberCount', 420,
      'tags', to_jsonb(ARRAY['Kabyle','Québec','Diaspora','Culture','Yennayer'])
    ),
    'Québec · Canada',
    ARRAY['Kabyle', 'Français'],
    1.0,
    jsonb_build_array(
      jsonb_build_object(
        'id', 'mission',
        'kind', 'mission',
        'title', jsonb_build_object('en', 'Purpose & Mission', 'fr', 'But / Mission'),
        'body', jsonb_build_object(
          'en', 'Preserve and promote Amazigh and Kabyle culture in Québec through seasonal events, workshops, practical resources, and support for new arrivals.',
          'fr', 'Préserver et promouvoir la culture amazighe et kabyle à Québec par des évènements, ateliers, ressources pratiques et un soutien aux nouveaux arrivants.'
        )
      ),
      jsonb_build_object(
        'id', 'activities',
        'kind', 'activities',
        'title', jsonb_build_object('en', 'Activity Pillars', 'fr', 'Catégories d’activités'),
        'items', to_jsonb(ARRAY[
          jsonb_build_object(
            'en', 'Cultural events: Yennayer celebrations, community festivals, solidarity gatherings.',
            'fr', 'Événements culturels : célébrations de Yennayer, fêtes communautaires, rencontres solidaires.'
          ),
          jsonb_build_object(
            'en', 'Workshops: language school, Kabyle cooking, cultural heritage labs.',
            'fr', 'Ateliers : école, ateliers de langue kabyle, cuisine et patrimoine.'
          ),
          jsonb_build_object(
            'en', 'Information resources: newcomer toolkit, integration guidance, local partners.',
            'fr', 'Ressources informationnelles : trousse de l’immigrant, accompagnement à l’intégration, partenaires locaux.'
          ),
          jsonb_build_object(
            'en', 'Diaspora solidarity: fundraising drives such as Kabylie wildfire relief (2021).',
            'fr', 'Solidarité diaspora : collectes de fonds, dont la campagne Feux de Kabylie (2021).'
          ),
          jsonb_build_object(
            'en', 'Community archive: regular updates on members, elders, and ongoing initiatives.',
            'fr', 'Archives communautaires : communications régulières autour des membres et initiatives.'
          )
        ])
      ),
      jsonb_build_object(
        'id', 'resources',
        'kind', 'resources',
        'title', jsonb_build_object('en', 'Resources & Support', 'fr', 'Ressources & soutien'),
        'items', to_jsonb(ARRAY[
          jsonb_build_object('en', 'Newcomer welcome kit in Kabyle and French.', 'fr', 'Trousse d’accueil pour nouveaux arrivants en kabyle et en français.'),
          jsonb_build_object('en', 'Integration mentorship circles with long-term residents.', 'fr', 'Cercles de mentorat pour faciliter l’intégration.'),
          jsonb_build_object('en', 'Educational guides on Amazigh history for schools in Québec.', 'fr', 'Guides pédagogiques sur l’histoire amazighe pour les écoles de Québec.')
        ])
      ),
      jsonb_build_object(
        'id', 'contact',
        'kind', 'contact',
        'title', jsonb_build_object('en', 'Team & Contact', 'fr', 'Équipe & contact'),
        'links', to_jsonb(ARRAY[
          jsonb_build_object('type', 'email', 'label', 'Email', 'value', 'kabyles2quebec@gmail.com'),
          jsonb_build_object('type', 'phone', 'label', 'Téléphone', 'value', '581-XXX-XXXX'),
          jsonb_build_object('type', 'facebook', 'label', 'Facebook', 'value', 'facebook.com/Kabyles2quebec/'),
          jsonb_build_object('type', 'website', 'label', 'Site officiel', 'value', 'kabyles2quebec.com/fk2q/')
        ])
      ),
      jsonb_build_object(
        'id', 'timeline',
        'kind', 'timeline',
        'title', jsonb_build_object('en', 'Key Dates', 'fr', 'Dates marquantes'),
        'items', to_jsonb(ARRAY[
          jsonb_build_object('en', '11 Sept 2022: community board renewed (11 elected members).', 'fr', '11 septembre 2022 : renouvellement du bureau (11 membres élus).'),
          jsonb_build_object('en', 'Yennayer celebrations each January, including 2975 in 2024.', 'fr', 'Grandes célébrations de Yennayer chaque janvier, dont 2975 en 2024.'),
          jsonb_build_object('en', 'Seasonal gatherings: corn roast, DJ nights, solidarity fundraisers.', 'fr', 'Fêtes saisonnières : épluchette, soirées DJ, collectes solidaires.')
        ])
      ),
      jsonb_build_object(
        'id', 'highlights',
        'kind', 'highlights',
        'title', jsonb_build_object('en', 'Feature Stories', 'fr', 'Articles phares'),
        'items', to_jsonb(ARRAY[
          jsonb_build_object('en', 'Tribute to Hamid Ouchen & Laou Smail (2025).', 'fr', 'Hommage à Hamid Ouchen & Laou Smail (2025).'),
          jsonb_build_object('en', 'Yennayer celebrations 2975 (2024) & 2973 (2022-2023).', 'fr', 'Célébrations de Yennayer 2975 (2024) et 2973 (2022-2023).'),
          jsonb_build_object('en', 'Kabylie wildfires solidarity campaign (2021).', 'fr', 'Solidarité Feux de Kabylie (2021).'),
          jsonb_build_object('en', 'Immigrant toolkit for Amazigh and Kabyle newcomers.', 'fr', 'Trousse et ressources pour immigrants amazigh/kabyles.')
        ])
      ),
      jsonb_build_object(
        'id', 'tags',
        'kind', 'tags',
        'title', jsonb_build_object('en', 'Tags & Index', 'fr', 'Tags / Index'),
        'items', to_jsonb(ARRAY[
          jsonb_build_object('en', '#Kabyle', 'fr', '#Kabyle'),
          jsonb_build_object('en', '#Amazigh', 'fr', '#Amazigh'),
          jsonb_build_object('en', '#Québec', 'fr', '#Québec'),
          jsonb_build_object('en', '#Culture', 'fr', '#Culture'),
          jsonb_build_object('en', '#Diaspora', 'fr', '#Diaspora'),
          jsonb_build_object('en', '#Yennayer', 'fr', '#Yennayer'),
          jsonb_build_object('en', '#Solidarity', 'fr', '#Solidarité'),
          jsonb_build_object('en', '#Workshops', 'fr', '#Ateliers'),
          jsonb_build_object('en', '#KabyleSchool', 'fr', '#ÉcoleKabyle'),
          jsonb_build_object('en', '#Immigration', 'fr', '#Immigration')
        ])
      )
    )
  ),
  (
    'women-imzad-circle',
    jsonb_build_object(
      'id', 'women-imzad-circle',
      'name', jsonb_build_object('en', 'Women of Imzad Circle', 'fr', 'Cercle des femmes de l''imzad'),
      'description', jsonb_build_object(
        'en', 'Workshops and storytelling nights safeguarding Imzad music and Saharan women’s leadership.',
        'fr', 'Ateliers et veillées de contes pour préserver l''imzad et le leadership des femmes touarègues.'
      ),
      'location', jsonb_build_object('en', 'Tamanrasset · Online', 'fr', 'Tamanrasset · En ligne'),
      'imageUrl', 'https://images.unsplash.com/photo-1527358043728-909898958ceb?auto=format&fit=crop&w=900&q=80',
      'memberCount', 438,
      'tags', to_jsonb(ARRAY['Heritage','Music','Women'])
    ),
    'Tamanrasset · Algeria',
    ARRAY['Tamasheq', 'Français'],
    0.7,
    jsonb_build_array(
      jsonb_build_object(
        'id', 'landing',
        'kind', 'landing',
        'title', jsonb_build_object('en', 'Keeping Imzad alive', 'fr', 'Préserver l''imzad'),
        'body', jsonb_build_object(
          'en', 'Weekly circles led by Imzad guardians blending music, oral history, and leadership workshops for young women.',
          'fr', 'Cercles hebdomadaires animés par des gardiennes de l''imzad mêlant musique, histoires orales et leadership pour les jeunes femmes.'
        )
      ),
      jsonb_build_object(
        'id', 'programmes',
        'kind', 'activities',
        'title', jsonb_build_object('en', 'Programmes', 'fr', 'Programmes'),
        'items', to_jsonb(ARRAY[
          jsonb_build_object('en', 'Imzad apprenticeships with elders.', 'fr', 'Apprentissages de l''imzad avec des aînées.'),
          jsonb_build_object('en', 'Story circles for young Saharan girls.', 'fr', 'Cercles de contes pour les jeunes sahariennes.'),
          jsonb_build_object('en', 'Leadership coaching for community projects.', 'fr', 'Coaching en leadership pour des projets communautaires.')
        ])
      ),
      jsonb_build_object(
        'id', 'contact',
        'kind', 'contact',
        'title', jsonb_build_object('en', 'Reach out', 'fr', 'Nous contacter'),
        'links', to_jsonb(ARRAY[
          jsonb_build_object('type', 'email', 'label', 'Email', 'value', 'imzad.circle@example.org'),
          jsonb_build_object('type', 'instagram', 'label', 'Instagram', 'value', '@womenofimzad'),
          jsonb_build_object('type', 'website', 'label', 'Site web', 'value', 'imzadcircle.org')
        ])
      )
    )
  ),
  (
    'imghiwan-radio',
    jsonb_build_object(
      'id', 'imghiwan-radio',
      'name', jsonb_build_object('en', 'Imghiwan Radio Collective', 'fr', 'Collectif radio Imghiwan'),
      'description', jsonb_build_object(
        'en', 'Community radio archiving Amazigh vinyl, oral histories, and contemporary remixes.',
        'fr', 'Radio communautaire archivant vinyles amazighs, histoires orales et remixes contemporains.'
      ),
      'location', jsonb_build_object('en', 'Paris · Casablanca · Online', 'fr', 'Paris · Casablanca · En ligne'),
      'imageUrl', 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=900&q=80',
      'memberCount', 512,
      'tags', to_jsonb(ARRAY['Radio','Archive','Diaspora','Youth'])
    ),
    'Paris & Casablanca · France & Morocco',
    ARRAY['Tamazight', 'Français', 'English'],
    0.6,
    jsonb_build_array(
      jsonb_build_object(
        'id', 'mission',
        'kind', 'mission',
        'title', jsonb_build_object('en', 'Broadcast mission', 'fr', 'Mission radio'),
        'body', jsonb_build_object(
          'en', 'Digitise and broadcast Amazigh sound archives while uplifting new diaspora voices.',
          'fr', 'Numériser et diffuser les archives sonores amazighes tout en valorisant de nouvelles voix de la diaspora.'
        )
      ),
      jsonb_build_object(
        'id', 'shows',
        'kind', 'highlights',
        'title', jsonb_build_object('en', 'Featured shows', 'fr', 'Émissions phares'),
        'items', to_jsonb(ARRAY[
          jsonb_build_object('en', 'Imghiwan Archives: weekly dig through rare vinyl.', 'fr', 'Archives Imghiwan : exploration hebdomadaire de vinyles rares.'),
          jsonb_build_object('en', 'Diaspora Frequencies: youth-led conversations on identity.', 'fr', 'Fréquences diaspora : conversations menées par les jeunes sur l’identité.'),
          jsonb_build_object('en', 'Guardian Sessions: live mixes blessed by cultural guardians.', 'fr', 'Sessions gardiennes : mixes live approuvés par les gardiens culturels.')
        ])
      ),
      jsonb_build_object(
        'id', 'connect',
        'kind', 'contact',
        'title', jsonb_build_object('en', 'Stay tuned', 'fr', 'Restez à l’écoute'),
        'links', to_jsonb(ARRAY[
          jsonb_build_object('type', 'website', 'label', 'Site web', 'value', 'imghiwan.fm'),
          jsonb_build_object('type', 'instagram', 'label', 'Instagram', 'value', '@imghiwan.fm'),
          jsonb_build_object('type', 'link', 'label', 'Mixcloud', 'value', 'mixcloud.com/imghiwan')
        ])
      )
    )
  )
ON CONFLICT (id) DO UPDATE
SET space = EXCLUDED.space,
    region = EXCLUDED.region,
    languages = EXCLUDED.languages,
    priority = EXCLUDED.priority,
    cards = EXCLUDED.cards;

INSERT INTO public.video_effects (id, name, description, config)
VALUES
  ('original', 'Original', 'No additional treatment.', NULL),
  (
    'warm_glow',
    'Warm Glow',
    'Adds golden tones for sunset moods.',
    '{"preset":"warm"}'::JSONB
  ),
  (
    'cool_mist',
    'Cool Mist',
    'Soft cyan lift with a gentle haze.',
    '{"preset":"cool"}'::JSONB
  ),
  (
    'noir',
    'Noir',
    'High contrast monochrome.',
    '{"preset":"noir"}'::JSONB
  )
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    config = EXCLUDED.config;

INSERT INTO public.music_tracks (id, title, artist, artwork_url, duration_seconds, preview_url)
VALUES
  ('imzad-dawn', 'Imzad Dawn', 'Tassili Ensemble', 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=600&q=80', 252, 'https://samplelib.com/lib/preview/mp3/sample-3s.mp3'),
  ('rif-waves', 'Rif Coast Waves', 'Taziri', 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=600&q=80', 308, 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3'),
  ('kabyle-strings', 'Kabyle Strings', 'Ayen Collective', 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80', 226, 'https://samplelib.com/lib/preview/mp3/sample-9s.mp3'),
  ('desert-heartbeat', 'Desert Heartbeat', 'Amayas', 'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=600&q=80', 362, 'https://samplelib.com/lib/preview/mp3/sample-12s.mp3')
ON CONFLICT (id) DO UPDATE
SET title = EXCLUDED.title,
    artist = EXCLUDED.artist,
    artwork_url = EXCLUDED.artwork_url,
    duration_seconds = EXCLUDED.duration_seconds,
    preview_url = EXCLUDED.preview_url;

INSERT INTO public.videos (
  id,
  creator_handle,
  creator_name_en,
  creator_name_fr,
  video_url,
  video_source,
  media_kind,
  image_url,
  gallery_urls,
  text_slides,
  aspect_ratio,
  thumbnail_url,
  music_track_id,
  effect_id,
  title_en,
  title_fr,
  description_en,
  description_fr,
  location_en,
  location_fr,
  likes,
  comments,
  shares,
  tags,
  created_at
)
VALUES
  (
    'tamazight-scroll-manifesto',
    '@thalaeditorial',
    'Thala Editorial',
    'Editorial Thala',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80',
    'network',
    'post',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80',
    ARRAY[]::TEXT[],
    jsonb_build_array(
      jsonb_build_object('en', 'Amazigh we are the rhythm of mountains', 'fr', 'Amazigh nous sommes le rythme des montagnes'),
      jsonb_build_object('en', 'Stitch one word a day keep Tamazight breathing', 'fr', 'Brode un mot par jour garde le tamazight vivant'),
      jsonb_build_object('en', 'Every village carries a vowel of resistance', 'fr', 'Chaque village porte une voyelle de resistance'),
      jsonb_build_object('en', 'Write for elders who sang freedom as a lullaby', 'fr', 'Ecris pour les anciens qui chantaient la liberte en berceuse')
    ),
    NULL,
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    NULL,
    NULL,
    'Tamazight manifesto in motion',
    'Manifeste tamazight en mouvement',
    'Swipe sideways to read the micro poems shaping a new dawn.',
    'Fais defiler les micro poemes qui sculptent une nouvelle aube.',
    'Tizi Ouzou, Algeria',
    'Tizi Ouzou, Algerie',
    4210,
    300,
    187,
    ARRAY['#Tamazight', '#Poetry', '#Minimal', '#Scroll'],
    TIMESTAMPTZ '2024-04-20T10:00:00Z'
  ),
  (
    'tifinagh-gallery-scroll',
    '@azetta',
    'Azetta Studio',
    'Atelier Azetta',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    'network',
    'image',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    ARRAY[
      'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=1200&q=80'
    ],
    '[]'::JSONB,
    0.800,
    'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=1200&q=80',
    NULL,
    NULL,
    'Tifinagh weaving motifs',
    'Motifs tisses en tifinagh',
    'Scroll through handwoven patterns from Kabylia and the Rif.',
    'Parcours des motifs tisses de Kabylie et du Rif.',
    'North Africa',
    'Afrique du Nord',
    2860,
    174,
    201,
    ARRAY['#Tifinagh', '#Weaving', '#Craft', '#Scroll'],
    TIMESTAMPTZ '2024-04-19T09:30:00Z'
  ),
  (
    'imzad-lullaby-session',
    '@imzadensembles',
    'Tassili Ensemble',
    'Ensemble Tassili',
    'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    'network',
    'image',
    'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    ARRAY[
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80'
    ],
    '[]'::JSONB,
    0.750,
    'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    'imzad-dawn',
    NULL,
    'Imzad lullaby session',
    'Seance de berceuse a limzad',
    'Soft strings captured while Tassili winds hum along.',
    'Cordes douces captees pendant que les vents du Tassili fredonnent.',
    'Djanet, Algeria',
    'Djanet, Algerie',
    1980,
    147,
    132,
    ARRAY['#Imzad', '#Lullaby', '#Music', '#Scroll'],
    TIMESTAMPTZ '2024-04-18T21:15:00Z'
  ),
  (
    'atlas-sunrise-film',
    '@tamountmedia',
    'Tamount Media',
    'Tamount Media',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'network',
    'video',
    NULL,
    ARRAY[]::TEXT[],
    '[]'::JSONB,
    1.778,
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    NULL,
    'cool_mist',
    'Atlas sunrise in wide frame',
    'Aube sur le Haut Atlas en grand angle',
    'A filmmaker tracks first light spilling over the High Atlas.',
    'Un cineaste suit la premiere lumiere sur le Haut Atlas.',
    'High Atlas, Morocco',
    'Haut Atlas, Maroc',
    3520,
    209,
    274,
    ARRAY['#Atlas', '#Sunrise', '#Cinematography', '#WideFrame'],
    TIMESTAMPTZ '2024-04-18T07:00:00Z'
  ),
  (
    'imzad-rhythms',
    '@imzadvoices',
    'Maessa',
    'Maessa',
    'https://images.unsplash.com/photo-1527497592873-8dfc72ec4b4b?auto=format&fit=crop&w=1200&q=80',
    'network',
    'video',
    NULL,
    ARRAY[]::TEXT[],
    '[]'::JSONB,
    NULL,
    'https://images.unsplash.com/photo-1527497592873-8dfc72ec4b4b?auto=format&fit=crop&w=800&q=80',
    NULL,
    NULL,
    'Imzad rhythms at sunset',
    'Rythmes dimzad au coucher du soleil',
    'Maessa plays an ancient Imzad melody passed down by her mother.',
    'Maessa joue une melodie ancestrale dimzad transmise par sa mere.',
    'Hoggar, Algeria',
    'Hoggar, Algerie',
    1340,
    82,
    45,
    ARRAY['#Imzad', '#Amazigh', '#Sahara', '#Thala'],
    TIMESTAMPTZ '2024-04-17T19:10:00Z'
  ),
  (
    'agadir-dance',
    '@pulseimazighen',
    'Imazighen Pulse',
    'Imazighen Pulse',
    'https://images.unsplash.com/photo-1528909514045-2fa4ac7a08ba?auto=format&fit=crop&w=1200&q=80',
    'network',
    'video',
    NULL,
    ARRAY[]::TEXT[],
    '[]'::JSONB,
    NULL,
    'https://images.unsplash.com/photo-1528909514045-2fa4ac7a08ba?auto=format&fit=crop&w=800&q=80',
    NULL,
    NULL,
    'Ahouach circle in Agadir',
    'Cercle ahouach a Agadir',
    'Young performers lead an ahouach dance celebrating the harvest.',
    'De jeunes artistes menent une danse ahouach pour celebrer la recolte.',
    'Agadir, Morocco',
    'Agadir, Maroc',
    2980,
    156,
    203,
    ARRAY['#Ahouach', '#Agadir', '#Dance', '#Thala'],
    TIMESTAMPTZ '2024-04-16T20:45:00Z'
  )
ON CONFLICT (id) DO UPDATE
SET video_url = EXCLUDED.video_url,
    video_source = EXCLUDED.video_source,
    media_kind = EXCLUDED.media_kind,
    image_url = EXCLUDED.image_url,
    gallery_urls = EXCLUDED.gallery_urls,
    text_slides = EXCLUDED.text_slides,
    aspect_ratio = EXCLUDED.aspect_ratio,
    thumbnail_url = EXCLUDED.thumbnail_url,
    music_track_id = EXCLUDED.music_track_id,
    effect_id = EXCLUDED.effect_id,
    title_en = EXCLUDED.title_en,
    title_fr = EXCLUDED.title_fr,
    description_en = EXCLUDED.description_en,
    description_fr = EXCLUDED.description_fr,
    location_en = EXCLUDED.location_en,
    location_fr = EXCLUDED.location_fr,
    likes = EXCLUDED.likes,
    comments = EXCLUDED.comments,
    shares = EXCLUDED.shares,
    tags = EXCLUDED.tags,
    creator_handle = EXCLUDED.creator_handle,
    creator_name_en = EXCLUDED.creator_name_en,
    creator_name_fr = EXCLUDED.creator_name_fr,
    created_at = EXCLUDED.created_at;

INSERT INTO public.video_comments (video_id, content)
VALUES
  ('tamazight-scroll-manifesto', 'Powerful words. Thank you for sharing.'),
  ('tamazight-scroll-manifesto', 'These lines gave me chills.'),
  ('imzad-lullaby-session', 'Listening while cooking dinner. Perfect mood.'),
  ('atlas-sunrise-film', 'The framing on this sunrise is incredible.')
ON CONFLICT DO NOTHING;

INSERT INTO public.video_shares (video_id)
VALUES
  ('tamazight-scroll-manifesto'),
  ('atlas-sunrise-film'),
  ('agadir-dance')
ON CONFLICT DO NOTHING;

INSERT INTO public.message_threads (
  id,
  title_en,
  title_fr,
  last_message_en,
  last_message_fr,
  unread_count,
  participants,
  created_at,
  updated_at
)
VALUES
  (
    'thread-001',
    'Village elders',
    'Les anciens du village',
    'We are gathering near the cedar grove at dusk.',
    'Nous nous retrouvons pres du bosquet de cedres au crepuscule.',
    3,
    ARRAY['@aziza', '@amir'],
    TIMESTAMPTZ '2024-04-16T17:00:00Z',
    TIMESTAMPTZ '2024-04-16T18:30:00Z'
  ),
  (
    'thread-002',
    'Festival co-op',
    'Collectif du festival',
    'Soundcheck finished. Sharing the mix in 10 minutes.',
    'Balance terminee. Partage du mix dans 10 minutes.',
    1,
    ARRAY['@leila', '@yassine', '@simo'],
    TIMESTAMPTZ '2024-04-16T16:00:00Z',
    TIMESTAMPTZ '2024-04-16T17:45:00Z'
  ),
  (
    'thread-003',
    'Guardians of the archive',
    'Gardiens de l''archive',
    'Scan finished. Uploading to the shared drive tonight.',
    'Scan termine. Mise en ligne sur le drive partage ce soir.',
    0,
    ARRAY['@amina'],
    TIMESTAMPTZ '2024-04-15T20:00:00Z',
    TIMESTAMPTZ '2024-04-15T22:05:00Z'
  )
ON CONFLICT (id) DO UPDATE
SET title_en = EXCLUDED.title_en,
    title_fr = EXCLUDED.title_fr,
    last_message_en = EXCLUDED.last_message_en,
    last_message_fr = EXCLUDED.last_message_fr,
    unread_count = EXCLUDED.unread_count,
    participants = EXCLUDED.participants,
    created_at = EXCLUDED.created_at,
    updated_at = EXCLUDED.updated_at;

INSERT INTO public.messages (
  thread_id,
  author_handle,
  author_display_name,
  body,
  delivery_status,
  created_at
)
VALUES
  ('thread-001', '@amir', 'Amir Idir', 'Are we meeting at the cedar grove or the plaza?', 'read', TIMESTAMPTZ '2024-04-16T17:05:00Z'),
  ('thread-001', '@you', 'You', 'Cedar grove. I will bring the new recordings.', 'delivered', TIMESTAMPTZ '2024-04-16T17:06:00Z'),
  ('thread-001', '@aziza', 'Aziza Taleb', 'Grateful. The elders will appreciate hearing the songs.', 'read', TIMESTAMPTZ '2024-04-16T18:12:00Z'),
  ('thread-001', '@amir', 'Amir Idir', 'We are gathering near the cedar grove at dusk.', 'read', TIMESTAMPTZ '2024-04-16T18:30:00Z'),
  ('thread-002', '@leila', 'Leila Amour', 'Who has the final tracklist for tonight?', 'read', TIMESTAMPTZ '2024-04-16T16:10:00Z'),
  ('thread-002', '@you', 'You', 'Uploading now, hold on.', 'delivered', TIMESTAMPTZ '2024-04-16T16:12:00Z'),
  ('thread-002', '@yassine', 'Yassine Merzouk', 'Levels are balanced. Crowd is already humming along.', 'read', TIMESTAMPTZ '2024-04-16T17:20:00Z'),
  ('thread-002', '@simo', 'Simo Lahcen', 'Soundcheck finished. Sharing the mix in 10 minutes.', 'read', TIMESTAMPTZ '2024-04-16T17:45:00Z'),
  ('thread-003', '@amina', 'Amina B', 'Scan finished. Uploading to the shared drive tonight.', 'read', TIMESTAMPTZ '2024-04-15T22:05:00Z')
ON CONFLICT DO NOTHING;

INSERT INTO public.community_views (community_id, user_id)
VALUES
  ('aghouid-meetup', NULL),
  ('aghouid-meetup', NULL),
  ('imzad-crafters', NULL)
ON CONFLICT DO NOTHING;

INSERT INTO public.community_host_requests (name, email, message, user_id, status)
VALUES
  (
    'Leila Amour',
    'leila@example.com',
    'Requesting to host a pop up radio hour featuring village choirs.',
    NULL,
    'pending'
  ),
  (
    'Yassine Merzouk',
    'yassine@example.com',
    'Looking to facilitate a workshop on renewable powered stages.',
    NULL,
    'reviewed'
  )
ON CONFLICT DO NOTHING;

COMMIT;
