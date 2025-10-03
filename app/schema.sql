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

CREATE TABLE IF NOT EXISTS public.video_effects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  config JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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

-- Maintain updated_at on change.
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
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

-- Shares of videos.
CREATE TABLE IF NOT EXISTS public.video_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id TEXT NOT NULL REFERENCES public.videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE SET NULL,
  shared_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS video_shares_video_idx
  ON public.video_shares (video_id, shared_at DESC);

-- Maintain aggregate counters on videos for comments and shares.
CREATE OR REPLACE FUNCTION public.sync_video_comment_counter()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
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
LANGUAGE plpgsql AS $$
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

CREATE OR REPLACE FUNCTION public.update_thread_from_message()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
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

-- ---------- Seeds ----------

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
  ('aghouid-meetup', '00000000-0000-0000-0000-000000000001'),
  ('aghouid-meetup', NULL),
  ('imzad-crafters', '00000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

INSERT INTO public.community_host_requests (name, email, message, user_id, status)
VALUES
  ('Leila Amour', 'leila@example.com', 'Requesting to host a pop up radio hour featuring village choirs.', '00000000-0000-0000-0000-000000000001', 'pending'),
  ('Yassine Merzouk', 'yassine@example.com', 'Looking to facilitate a workshop on renewable powered stages.', '00000000-0000-0000-0000-000000000002', 'reviewed')
ON CONFLICT DO NOTHING;

COMMIT;
