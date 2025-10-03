import '../models/community_space.dart';
import '../models/localized_text.dart';

const sampleCommunities = <CommunitySpace>[
  CommunitySpace(
    id: 'women-imzad-circle',
    name: LocalizedText(
      en: 'Women of Imzad Circle',
      fr: "Cercle des femmes de l'imzad",
    ),
    description: LocalizedText(
      en: 'Workshops to share techniques, stories, and songs of the Imzad.',
      fr: "Ateliers pour partager techniques, histoires et chants de l'imzad.",
    ),
    location: LocalizedText(
      en: 'Tamanrasset · Online',
      fr: 'Tamanrasset · En ligne',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1527358043728-909898958ceb?auto=format&fit=crop&w=800&q=80',
    memberCount: 438,
    tags: ['Heritage', 'Music'],
  ),
  CommunitySpace(
    id: 'diaspora-stories',
    name: LocalizedText(
      en: 'Diaspora Storytellers',
      fr: 'Conteurs de la diaspora',
    ),
    description: LocalizedText(
      en: 'A space for Amazigh voices across the world to share life and art.',
      fr: 'Un espace pour les voix amazighes du monde entier.',
    ),
    location: LocalizedText(en: 'Montreal · Weekly', fr: 'Montréal · Hebdo'),
    imageUrl:
        'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?auto=format&fit=crop&w=800&q=80',
    memberCount: 1021,
    tags: ['Storytelling', 'Diaspora'],
  ),
  CommunitySpace(
    id: 'kabyle-language-lab',
    name: LocalizedText(en: 'Kabyle Language Lab', fr: 'Atelier langue kabyle'),
    description: LocalizedText(
      en: 'Casual meetups to practice Kabyle expressions and oral histories.',
      fr: 'Rencontres pour pratiquer les expressions kabyles et les récits oraux.',
    ),
    location: LocalizedText(en: 'Paris · Hybrid', fr: 'Paris · Hybride'),
    imageUrl:
        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=800&q=80',
    memberCount: 289,
    tags: ['Language', 'Education'],
  ),
];
