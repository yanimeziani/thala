import '../models/cultural_event.dart';
import '../models/localized_text.dart';

final sampleEvents = <CulturalEvent>[
  CulturalEvent(
    id: 'tamazgha-fest-2025',
    title: const LocalizedText(
      en: 'Tamazgha Festival 2025',
      fr: 'Festival Tamazgha 2025',
    ),
    dateLabel: const LocalizedText(
      en: 'March 15-17, 2025',
      fr: '15-17 mars 2025',
    ),
    location: const LocalizedText(
      en: 'Paris, France',
      fr: 'Paris, France',
    ),
    description: const LocalizedText(
      en: 'Join us for three days celebrating Amazigh culture through music, art, and storytelling. Featuring artists from across Tamazgha and the diaspora.',
      fr: 'Rejoignez-nous pour trois jours de célébration de la culture amazighe à travers la musique, l\'art et les récits. Avec des artistes de toute Tamazgha et de la diaspora.',
    ),
    additionalDetail: const LocalizedText(
      en: 'Free entry for students with valid ID. Workshops and exhibitions open daily.',
      fr: 'Entrée gratuite pour les étudiants avec carte valide. Ateliers et expositions ouverts tous les jours.',
    ),
    mode: CulturalEventMode.inPerson,
    startAt: DateTime(2025, 3, 15, 10, 0),
    endAt: DateTime(2025, 3, 17, 22, 0),
    tags: const [
      LocalizedText(en: 'Music', fr: 'Musique'),
      LocalizedText(en: 'Art', fr: 'Art'),
      LocalizedText(en: 'Community', fr: 'Communauté'),
    ],
    ctaLabel: const LocalizedText(
      en: 'Get Tickets',
      fr: 'Obtenir des billets',
    ),
    ctaNote: const LocalizedText(
      en: 'Limited capacity - register early',
      fr: 'Capacité limitée - inscription anticipée',
    ),
    backgroundColorHex: const ['#E67E22', '#D35400'],
    heroImageUrl:
        'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?auto=format&fit=crop&w=1200&q=80',
    hostName: 'Amazigh Cultural Center Paris',
    hostHandle: '@amazigh_paris',
    isHostVerified: true,
    interestedCount: 247,
    isUserInterested: false,
  ),
  CulturalEvent(
    id: 'amazigh-language-workshop',
    title: const LocalizedText(
      en: 'Tamazight Language Workshop',
      fr: 'Atelier de langue tamazight',
    ),
    dateLabel: const LocalizedText(
      en: 'Every Saturday, 2-4 PM',
      fr: 'Chaque samedi, 14h-16h',
    ),
    location: const LocalizedText(
      en: 'Online via Zoom',
      fr: 'En ligne via Zoom',
    ),
    description: const LocalizedText(
      en: 'Learn Tamazight with native speakers in small, interactive groups. Perfect for beginners and those reconnecting with their roots.',
      fr: 'Apprenez le tamazight avec des locuteurs natifs dans de petits groupes interactifs. Parfait pour les débutants et ceux qui renouen avec leurs racines.',
    ),
    additionalDetail: const LocalizedText(
      en: 'Materials provided digitally. Recording available for registered participants.',
      fr: 'Matériels fournis numériquement. Enregistrement disponible pour les participants inscrits.',
    ),
    mode: CulturalEventMode.online,
    startAt: DateTime(2025, 2, 8, 14, 0),
    endAt: DateTime(2025, 2, 8, 16, 0),
    tags: const [
      LocalizedText(en: 'Language', fr: 'Langue'),
      LocalizedText(en: 'Education', fr: 'Éducation'),
      LocalizedText(en: 'Beginner-friendly', fr: 'Pour débutants'),
    ],
    ctaLabel: const LocalizedText(
      en: 'Join Workshop',
      fr: 'Rejoindre l\'atelier',
    ),
    ctaNote: const LocalizedText(
      en: 'Free for community members',
      fr: 'Gratuit pour les membres de la communauté',
    ),
    backgroundColorHex: const ['#16A085', '#1ABC9C'],
    heroImageUrl:
        'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=1200&q=80',
    hostName: 'Tamazight Learning Hub',
    hostHandle: '@tamazight_hub',
    isHostVerified: true,
    interestedCount: 89,
    isUserInterested: true,
  ),
  CulturalEvent(
    id: 'yennayer-celebration-2975',
    title: const LocalizedText(
      en: 'Yennayer 2975 Celebration',
      fr: 'Célébration de Yennayer 2975',
    ),
    dateLabel: const LocalizedText(
      en: 'January 12, 2025',
      fr: '12 janvier 2025',
    ),
    location: const LocalizedText(
      en: 'Montreal & Online',
      fr: 'Montréal & En ligne',
    ),
    description: const LocalizedText(
      en: 'Celebrate the Amazigh New Year with traditional food, music, and dance. Join us in person in Montreal or stream the festivities online.',
      fr: 'Célébrez le Nouvel An amazigh avec de la nourriture traditionnelle, de la musique et de la danse. Rejoignez-nous en personne à Montréal ou diffusez les festivités en ligne.',
    ),
    additionalDetail: const LocalizedText(
      en: 'Traditional meal served at 7 PM. Children\'s activities start at 5 PM.',
      fr: 'Repas traditionnel servi à 19h. Activités pour enfants dès 17h.',
    ),
    mode: CulturalEventMode.hybrid,
    startAt: DateTime(2025, 1, 12, 17, 0),
    endAt: DateTime(2025, 1, 12, 23, 0),
    tags: const [
      LocalizedText(en: 'Tradition', fr: 'Tradition'),
      LocalizedText(en: 'Festival', fr: 'Festival'),
      LocalizedText(en: 'Family-friendly', fr: 'Pour toute la famille'),
    ],
    ctaLabel: const LocalizedText(
      en: 'RSVP Now',
      fr: 'Confirmer maintenant',
    ),
    ctaNote: const LocalizedText(
      en: 'In-person seats limited to 200',
      fr: 'Places en personne limitées à 200',
    ),
    backgroundColorHex: const ['#8E44AD', '#9B59B6'],
    heroImageUrl:
        'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?auto=format&fit=crop&w=1200&q=80',
  ),
  CulturalEvent(
    id: 'tifinagh-calligraphy-class',
    title: const LocalizedText(
      en: 'Tifinagh Calligraphy Class',
      fr: 'Cours de calligraphie tifinagh',
    ),
    dateLabel: const LocalizedText(
      en: 'February 22, 2025',
      fr: '22 février 2025',
    ),
    location: const LocalizedText(
      en: 'Berlin Cultural Center',
      fr: 'Centre culturel de Berlin',
    ),
    description: const LocalizedText(
      en: 'Discover the ancient art of Tifinagh script with master calligrapher Dihya Amrani. Learn traditional and contemporary styles.',
      fr: 'Découvrez l\'art ancien de l\'écriture tifinagh avec la maître calligraphe Dihya Amrani. Apprenez les styles traditionnels et contemporains.',
    ),
    additionalDetail: const LocalizedText(
      en: 'All materials provided. Bring your creativity!',
      fr: 'Tous les matériaux fournis. Apportez votre créativité !',
    ),
    mode: CulturalEventMode.inPerson,
    startAt: DateTime(2025, 2, 22, 15, 0),
    endAt: DateTime(2025, 2, 22, 18, 0),
    tags: const [
      LocalizedText(en: 'Art', fr: 'Art'),
      LocalizedText(en: 'Writing', fr: 'Écriture'),
      LocalizedText(en: 'Workshop', fr: 'Atelier'),
    ],
    ctaLabel: const LocalizedText(
      en: 'Reserve Spot',
      fr: 'Réserver une place',
    ),
    ctaNote: const LocalizedText(
      en: '€15 materials fee',
      fr: 'Frais de matériel de 15€',
    ),
    backgroundColorHex: const ['#C0392B', '#E74C3C'],
    heroImageUrl:
        'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&w=1200&q=80',
  ),
  CulturalEvent(
    id: 'amazigh-film-screening',
    title: const LocalizedText(
      en: 'Amazigh Cinema Night',
      fr: 'Soirée cinéma amazigh',
    ),
    dateLabel: const LocalizedText(
      en: 'March 8, 2025',
      fr: '8 mars 2025',
    ),
    location: const LocalizedText(
      en: 'Algiers & Streaming',
      fr: 'Alger & Diffusion',
    ),
    description: const LocalizedText(
      en: 'Screening of award-winning Amazigh films with Q&A session with filmmakers. Celebrating stories from and for our communities.',
      fr: 'Projection de films amazighs primés avec session de questions-réponses avec les cinéastes. Célébrant les histoires de et pour nos communautés.',
    ),
    additionalDetail: const LocalizedText(
      en: 'French and English subtitles available. Discussion follows screening.',
      fr: 'Sous-titres français et anglais disponibles. Discussion après la projection.',
    ),
    mode: CulturalEventMode.hybrid,
    startAt: DateTime(2025, 3, 8, 19, 0),
    endAt: DateTime(2025, 3, 8, 22, 30),
    tags: const [
      LocalizedText(en: 'Film', fr: 'Film'),
      LocalizedText(en: 'Culture', fr: 'Culture'),
      LocalizedText(en: 'Discussion', fr: 'Discussion'),
    ],
    ctaLabel: const LocalizedText(
      en: 'Get Tickets',
      fr: 'Obtenir des billets',
    ),
    ctaNote: const LocalizedText(
      en: 'Streaming free, in-person ticketed',
      fr: 'Diffusion gratuite, billets en personne',
    ),
    backgroundColorHex: const ['#2C3E50', '#34495E'],
    heroImageUrl:
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
  ),
];
