import '../models/localized_text.dart';
import '../models/video_post.dart';

/// Seed posts shown in the prototype feed.
const samplePosts = <VideoPost>[
  VideoPost(
    id: 'tamazight-scroll-manifesto',
    videoUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80',
    mediaKind: StoryMediaKind.post,
    imageUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    textSlides: <LocalizedText>[
      LocalizedText(
        en: 'ⴰⵎⴰⵣⵉⵖ · We are the rhythm of mountains',
        fr: 'ⴰⵎⴰⵣⵉⵖ · Nous sommes le rythme des montagnes',
      ),
      LocalizedText(
        en: 'Stitch one word a day, keep Tamazight breathing',
        fr: 'Brode un mot par jour, garde le tamazight vivant',
      ),
      LocalizedText(
        en: 'Every village carries a vowel of resistance',
        fr: 'Chaque village porte une voyelle de résistance',
      ),
      LocalizedText(
        en: 'Write for elders who sang freedom as a lullaby',
        fr: 'Écris pour les anciens qui chantaient la liberté en berceuse',
      ),
    ],
    title: LocalizedText(
      en: 'Tamazight manifesto in motion',
      fr: 'Manifeste tamazight en mouvement',
    ),
    description: LocalizedText(
      en: 'Swipe sideways to read the micro-poems shaping a new dawn.',
      fr: 'Fais défiler les micro-poèmes qui sculptent une nouvelle aube.',
    ),
    location: LocalizedText(
      en: 'Tizi Ouzou, Algeria',
      fr: 'Tizi Ouzou, Algérie',
    ),
    creatorName: LocalizedText(en: 'Thala Editorial', fr: 'Éditorial Thala'),
    creatorHandle: '@thalaeditorial',
    likes: 4210,
    comments: 302,
    shares: 188,
    tags: ['#Tamazight', '#Poetry', '#Minimal', '#Scroll'],
  ),
  VideoPost(
    id: 'tifinagh-gallery-scroll',
    videoUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    mediaKind: StoryMediaKind.image,
    imageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    galleryUrls: <String>[
      'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=1200&q=80',
    ],
    aspectRatio: 4 / 5,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=1200&q=80',
    title: LocalizedText(
      en: 'Tifinagh weaving motifs',
      fr: 'Motifs tissés en tifinagh',
    ),
    description: LocalizedText(
      en: 'Scroll through handwoven patterns from Kabylia and the Rif.',
      fr: 'Parcours des motifs tissés de Kabylie et du Rif.',
    ),
    location: LocalizedText(en: 'North Africa', fr: 'Afrique du Nord'),
    creatorName: LocalizedText(en: 'Azetta Studio', fr: 'Atelier Azetta'),
    creatorHandle: '@azetta',
    likes: 2860,
    comments: 174,
    shares: 201,
    tags: ['#Tifinagh', '#Weaving', '#Craft', '#Scroll'],
  ),
  VideoPost(
    id: 'imzad-lullaby-session',
    videoUrl:
        'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    mediaKind: StoryMediaKind.image,
    imageUrl:
        'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    galleryUrls: <String>[
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    ],
    aspectRatio: 3 / 4,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    title: LocalizedText(
      en: 'Imzad lullaby session',
      fr: 'Séance de berceuse à l\'imzad',
    ),
    description: LocalizedText(
      en: 'Soft strings captured while Tassili winds hum along.',
      fr: 'Cordes douces captées pendant que les vents du Tassili fredonnent.',
    ),
    location: LocalizedText(en: 'Djanet, Algeria', fr: 'Djanet, Algérie'),
    creatorName: LocalizedText(en: 'Tassili Ensemble', fr: 'Ensemble Tassili'),
    creatorHandle: '@imzadensembles',
    likes: 1980,
    comments: 148,
    shares: 132,
    musicTrackId: 'imzad-dawn',
    tags: ['#Imzad', '#Lullaby', '#Music', '#Scroll'],
  ),
  VideoPost(
    id: 'atlas-sunrise-film',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    mediaKind: StoryMediaKind.video,
    aspectRatio: 16 / 9,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    title: LocalizedText(
      en: 'Atlas sunrise in wide frame',
      fr: 'Aube sur l\'Atlas en grand angle',
    ),
    description: LocalizedText(
      en: 'A filmmaker tracks first light spilling over the High Atlas.',
      fr: 'Un cinéaste suit la première lumière sur le Haut Atlas.',
    ),
    location: LocalizedText(en: 'Haut Atlas, Morocco', fr: 'Haut Atlas, Maroc'),
    creatorName: LocalizedText(en: 'Tamount Media', fr: 'Tamount Media'),
    creatorHandle: '@tamountmedia',
    likes: 3520,
    comments: 210,
    shares: 275,
    effectId: 'cool_mist',
    tags: ['#Atlas', '#Sunrise', '#Cinematography', '#WideFrame'],
  ),
  VideoPost(
    id: 'imzad-rhythms',
    videoUrl: 'assets/Kabyle_men_dressed_202510021911_7jclb.mp4',
    videoSource: VideoSource.asset,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1527497592873-8dfc72ec4b4b?auto=format&fit=crop&w=800&q=80',
    title: LocalizedText(
      en: 'Imzad rhythms at sunset',
      fr: "Rythmes d'imzad au coucher du soleil",
    ),
    description: LocalizedText(
      en: 'Maessa plays an ancient Imzad melody passed down by her mother.',
      fr: 'Maessa joue une mélodie ancestrale d\'imzad transmise par sa mère.',
    ),
    location: LocalizedText(en: 'Hoggar, Algeria', fr: 'Hoggar, Algérie'),
    creatorName: LocalizedText(en: 'Maessa', fr: 'Maessa'),
    creatorHandle: '@imzadvoices',
    likes: 1340,
    comments: 82,
    shares: 45,
    tags: ['#Imzad', '#Amazigh', '#Sahara', '#Thala'],
  ),
  VideoPost(
    id: 'agadir-dance',
    videoUrl: 'assets/Two_kabyle_men_202510021913_5q92e.mp4',
    videoSource: VideoSource.asset,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1528909514045-2fa4ac7a08ba?auto=format&fit=crop&w=800&q=80',
    title: LocalizedText(
      en: 'ⵀ Ahouach circle in Agadir',
      fr: 'ⵀ Cercle ahouach à Agadir',
    ),
    description: LocalizedText(
      en: 'Young performers lead an ahouach dance celebrating the harvest.',
      fr: 'De jeunes artistes mènent une danse ahouach pour célébrer la récolte.',
    ),
    location: LocalizedText(en: 'Agadir, Morocco', fr: 'Agadir, Maroc'),
    creatorName: LocalizedText(en: 'Imazighen Pulse', fr: 'Imazighen Pulse'),
    creatorHandle: '@pulseimazighen',
    likes: 2980,
    comments: 156,
    shares: 204,
    tags: ['#Ahouach', '#Agadir', '#Dance', '#Thala'],
  ),
  VideoPost(
    id: 'kabyle-poetry',
    videoUrl: 'assets/Kabyle_men_dressed_202510021911_7jclb.mp4',
    videoSource: VideoSource.asset,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=800&q=80',
    title: LocalizedText(
      en: 'Kabyle poetry slam night',
      fr: 'Soirée slam kabyle',
    ),
    description: LocalizedText(
      en: 'Lwennas performs verses dedicated to Amazigh resilience.',
      fr: 'Lwennas déclame des vers dédiés à la résilience amazighe.',
    ),
    location: LocalizedText(en: 'Paris, France', fr: 'Paris, France'),
    creatorName: LocalizedText(en: 'Ayen', fr: 'Ayen'),
    creatorHandle: '@ayenpoesie',
    likes: 870,
    comments: 64,
    shares: 39,
    tags: ['#Kabyle', '#Poetry', '#Diaspora', '#Thala'],
  ),
  VideoPost(
    id: 'rif-bread',
    videoUrl: 'assets/Two_kabyle_men_202510021913_5q92e.mp4',
    videoSource: VideoSource.asset,
    thumbnailUrl:
        'https://images.unsplash.com/photo-1543353071-873f17a7a088?auto=format&fit=crop&w=800&q=80',
    title: LocalizedText(
      en: 'Baking aghroum n tmazirt',
      fr: 'Préparer l\'aghroum n tmazirt',
    ),
    description: LocalizedText(
      en: 'Tala shows the steps for the traditional Rif sourdough bread.',
      fr: 'Tala partage les étapes du pain traditionnel rifain.',
    ),
    location: LocalizedText(en: 'Nador, Morocco', fr: 'Nador, Maroc'),
    creatorName: LocalizedText(en: 'Tala', fr: 'Tala'),
    creatorHandle: '@rifkitchen',
    likes: 1540,
    comments: 112,
    shares: 88,
    tags: ['#Rif', '#Cuisine', '#Aghroum', '#Thala'],
  ),
];
