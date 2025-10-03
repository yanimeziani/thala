import '../models/community_profile.dart';
import '../models/community_space.dart';
import '../models/localized_text.dart';

const sampleCommunityProfiles = <CommunityProfile>[
  CommunityProfile(
    space: CommunitySpace(
      id: 'fk2q',
      name: LocalizedText(
        en: 'Kabyle Forum of Québec City',
        fr: 'Forum Kabyle de la Ville de Québec',
      ),
      description: LocalizedText(
        en: '',
        fr: '',
      ),
      location: LocalizedText(en: 'Québec City, QC', fr: 'Ville de Québec, QC'),
      imageUrl:
          'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=900&q=80',
      memberCount: 420,
      tags: ['Kabyle', 'Québec', 'Diaspora', 'Culture', 'Yennayer'],
    ),
    region: 'Québec · Canada',
    languages: ['Kabyle', 'Français'],
    priority: 1.0,
    cards: [
      CommunityDetailCard(
        id: 'mission',
        kind: CommunityCardKind.mission,
        title: LocalizedText(en: 'Purpose & Mission', fr: 'But / Mission'),
        body: LocalizedText(
          en: 'Preserve and promote Amazigh and Kabyle culture in Québec through seasonal events, workshops, practical resources, and support for new arrivals.',
          fr: 'Préserver et promouvoir la culture amazighe et kabyle à Québec par des évènements, ateliers, ressources pratiques et un soutien aux nouveaux arrivants.',
        ),
      ),
      CommunityDetailCard(
        id: 'activities',
        kind: CommunityCardKind.activities,
        title: LocalizedText(
          en: 'Activity Pillars',
          fr: 'Catégories d’activités',
        ),
        items: [
          LocalizedText(
            en: 'Cultural events: Yennayer celebrations, community festivals, solidarity gatherings.',
            fr: 'Événements culturels : célébrations de Yennayer, fêtes communautaires, rencontres solidaires.',
          ),
          LocalizedText(
            en: 'Workshops: language school, Kabyle cooking, cultural heritage labs.',
            fr: 'Ateliers : école, ateliers de langue kabyle, cuisine et patrimoine.',
          ),
          LocalizedText(
            en: 'Information resources: newcomer toolkit, integration guidance, local partners.',
            fr: 'Ressources informationnelles : trousse de l’immigrant, accompagnement à l’intégration, partenaires locaux.',
          ),
          LocalizedText(
            en: 'Diaspora solidarity: fundraising drives such as Kabylie wildfire relief (2021).',
            fr: 'Solidarité diaspora : collectes de fonds, dont la campagne Feux de Kabylie (2021).',
          ),
          LocalizedText(
            en: 'Community archive: regular updates on members, elders, and ongoing initiatives.',
            fr: 'Archives communautaires : communications régulières autour des membres et initiatives.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'resources',
        kind: CommunityCardKind.resources,
        title: LocalizedText(
          en: 'Resources & Support',
          fr: 'Ressources & soutien',
        ),
        items: [
          LocalizedText(
            en: 'Newcomer welcome kit in Kabyle and French.',
            fr: 'Trousse d’accueil pour nouveaux arrivants en kabyle et en français.',
          ),
          LocalizedText(
            en: 'Integration mentorship circles with long-term residents.',
            fr: 'Cercles de mentorat pour faciliter l’intégration.',
          ),
          LocalizedText(
            en: 'Educational guides on Amazigh history for schools in Québec.',
            fr: 'Guides pédagogiques sur l’histoire amazighe pour les écoles de Québec.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'contact',
        kind: CommunityCardKind.contact,
        title: LocalizedText(en: 'Team & Contact', fr: 'Équipe & contact'),
        links: [
          CommunityLink(
            type: CommunityLinkType.email,
            label: 'Email',
            value: 'kabyles2quebec@gmail.com',
          ),
          CommunityLink(
            type: CommunityLinkType.phone,
            label: 'Téléphone',
            value: '581-XXX-XXXX',
          ),
          CommunityLink(
            type: CommunityLinkType.facebook,
            label: 'Facebook',
            value: 'facebook.com/Kabyles2quebec/',
          ),
          CommunityLink(
            type: CommunityLinkType.website,
            label: 'Site officiel',
            value: 'kabyles2quebec.com/fk2q/',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'timeline',
        kind: CommunityCardKind.timeline,
        title: LocalizedText(en: 'Key Dates', fr: 'Dates marquantes'),
        items: [
          LocalizedText(
            en: '11 Sept 2022: community board renewed (11 elected members).',
            fr: '11 septembre 2022 : renouvellement du bureau (11 membres élus).',
          ),
          LocalizedText(
            en: 'Yennayer celebrations each January, including 2975 in 2024.',
            fr: 'Grandes célébrations de Yennayer chaque janvier, dont 2975 en 2024.',
          ),
          LocalizedText(
            en: 'Seasonal gatherings: corn roast, DJ nights, solidarity fundraisers.',
            fr: 'Fêtes saisonnières : épluchette, soirées DJ, collectes solidaires.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'highlights',
        kind: CommunityCardKind.highlights,
        title: LocalizedText(en: 'Feature Stories', fr: 'Articles phares'),
        items: [
          LocalizedText(
            en: 'Tribute to Hamid Ouchen & Laou Smail (2025).',
            fr: 'Hommage à Hamid Ouchen & Laou Smail (2025).',
          ),
          LocalizedText(
            en: 'Yennayer celebrations 2975 (2024) & 2973 (2022-2023).',
            fr: 'Célébrations de Yennayer 2975 (2024) et 2973 (2022-2023).',
          ),
          LocalizedText(
            en: 'Kabylie wildfires solidarity campaign (2021).',
            fr: 'Solidarité Feux de Kabylie (2021).',
          ),
          LocalizedText(
            en: 'Immigrant toolkit for Amazigh and Kabyle newcomers.',
            fr: 'Trousse et ressources pour immigrants amazigh/kabyles.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'tags',
        kind: CommunityCardKind.tags,
        title: LocalizedText(en: 'Tags & Index', fr: 'Tags / Index'),
        items: [
          LocalizedText(en: '#Kabyle', fr: '#Kabyle'),
          LocalizedText(en: '#Amazigh', fr: '#Amazigh'),
          LocalizedText(en: '#Québec', fr: '#Québec'),
          LocalizedText(en: '#Culture', fr: '#Culture'),
          LocalizedText(en: '#Diaspora', fr: '#Diaspora'),
          LocalizedText(en: '#Yennayer', fr: '#Yennayer'),
          LocalizedText(en: '#Solidarity', fr: '#Solidarité'),
          LocalizedText(en: '#Workshops', fr: '#Ateliers'),
          LocalizedText(en: '#KabyleSchool', fr: '#ÉcoleKabyle'),
          LocalizedText(en: '#Immigration', fr: '#Immigration'),
        ],
      ),
    ],
  ),
  CommunityProfile(
    space: CommunitySpace(
      id: 'women-imzad-circle',
      name: LocalizedText(
        en: 'Women of Imzad Circle',
        fr: "Cercle des femmes de l'imzad",
      ),
      description: LocalizedText(
        en: 'Workshops and storytelling nights safeguarding Imzad music and Saharan women’s leadership.',
        fr: "Ateliers et veillées de contes pour préserver l'imzad et le leadership des femmes touarègues.",
      ),
      location: LocalizedText(
        en: 'Tamanrasset · Online',
        fr: 'Tamanrasset · En ligne',
      ),
      imageUrl:
          'https://images.unsplash.com/photo-1527358043728-909898958ceb?auto=format&fit=crop&w=900&q=80',
      memberCount: 438,
      tags: ['Heritage', 'Music', 'Women'],
    ),
    region: 'Tamanrasset · Algeria',
    languages: ['Tamasheq', 'Français'],
    priority: 0.7,
    cards: [
      CommunityDetailCard(
        id: 'mission',
        kind: CommunityCardKind.mission,
        title: LocalizedText(en: 'Purpose & Mission', fr: 'But / Mission'),
        body: LocalizedText(
          en: 'Safeguard Imzad heritage by centering women musicians, healers, and storytellers across the Sahara.',
          fr: "Sauvegarder l'héritage de l'imzad en plaçant au centre les musiciennes, soigneuses et conteuses du Sahara.",
        ),
      ),
      CommunityDetailCard(
        id: 'activities',
        kind: CommunityCardKind.activities,
        title: LocalizedText(
          en: 'Activity Pillars',
          fr: 'Catégories d’activités',
        ),
        items: [
          LocalizedText(
            en: 'Instrument labs restoring and tuning ancestral Imzad instruments.',
            fr: "Ateliers d'instruments pour restaurer et accorder l'imzad ancestral.",
          ),
          LocalizedText(
            en: 'Story circles recording elders and matriarchs in Tamasheq and French.',
            fr: 'Cercles de contes enregistrant les aînées en tamasheq et en français.',
          ),
          LocalizedText(
            en: 'Online mentorship pairing desert regions with diaspora learners.',
            fr: 'Mentorat en ligne reliant le désert aux apprenant·e·s de la diaspora.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'resources',
        kind: CommunityCardKind.resources,
        title: LocalizedText(en: 'Resources', fr: 'Ressources'),
        items: [
          LocalizedText(
            en: 'Archive of women-led Imzad recordings since 2015.',
            fr: "Archive des enregistrements d'imzad portés par des femmes depuis 2015.",
          ),
          LocalizedText(
            en: 'Micro-grants for travel and equipment upkeep.',
            fr: 'Micro-bourses pour déplacements et entretien des instruments.',
          ),
          LocalizedText(
            en: 'Educational kits for schools in Tamanrasset and abroad.',
            fr: 'Kits pédagogiques pour les écoles locales et internationales.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'contact',
        kind: CommunityCardKind.contact,
        title: LocalizedText(en: 'Reach Out', fr: 'Nous contacter'),
        links: [
          CommunityLink(
            type: CommunityLinkType.email,
            label: 'Email',
            value: 'imzad.circle@example.org',
          ),
          CommunityLink(
            type: CommunityLinkType.website,
            label: 'Website',
            value: 'imzadwomen.org',
          ),
          CommunityLink(
            type: CommunityLinkType.instagram,
            label: 'Instagram',
            value: '@imzadwomen',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'timeline',
        kind: CommunityCardKind.timeline,
        title: LocalizedText(en: 'Milestones', fr: 'Dates marquantes'),
        items: [
          LocalizedText(
            en: '2018: First cross-border Imzad residency hosted in Tamanrasset.',
            fr: '2018 : première résidence transfrontalière de l’imzad à Tamanrasset.',
          ),
          LocalizedText(
            en: '2020: Digital archive launched with 120 recordings.',
            fr: '2020 : lancement de l’archive numérique avec 120 enregistrements.',
          ),
          LocalizedText(
            en: '2023: Partnership with Sahara Conservatory for youth apprenticeships.',
            fr: '2023 : partenariat avec le Conservatoire du Sahara pour les apprentissages jeunesse.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'highlights',
        kind: CommunityCardKind.highlights,
        title: LocalizedText(en: 'Highlights', fr: 'À la une'),
        items: [
          LocalizedText(
            en: 'Imzad healing sessions featured at Festival Taragalte (2024).',
            fr: 'Sessions de guérison à l’imzad au Festival Taragalte (2024).',
          ),
          LocalizedText(
            en: 'Profiles of matriarchs Lalla Keltouma and Aïcha ag Rhissa.',
            fr: 'Portraits des matriarches Lalla Keltouma et Aïcha ag Rhissa.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'tags',
        kind: CommunityCardKind.tags,
        title: LocalizedText(en: 'Tags', fr: 'Tags'),
        items: [
          LocalizedText(en: '#Imzad', fr: '#Imzad'),
          LocalizedText(en: '#WomenLead', fr: '#FemmesEnTête'),
          LocalizedText(en: '#Sahara', fr: '#Sahara'),
          LocalizedText(en: '#Heritage', fr: '#Patrimoine'),
        ],
      ),
    ],
  ),
  CommunityProfile(
    space: CommunitySpace(
      id: 'diaspora-stories',
      name: LocalizedText(
        en: 'Diaspora Storytellers',
        fr: 'Conteurs de la diaspora',
      ),
      description: LocalizedText(
        en: 'Hybrid gatherings for Amazigh creatives across Montréal and abroad.',
        fr: 'Rencontres hybrides des créatif·ve·s amazigh·e·s à Montréal et ailleurs.',
      ),
      location: LocalizedText(
        en: 'Montreal · Hybrid',
        fr: 'Montréal · Hybride',
      ),
      imageUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80',
      memberCount: 1021,
      tags: ['Storytelling', 'Diaspora', 'Media'],
    ),
    region: 'Montréal · Canada',
    languages: ['Tamazight', 'Français', 'English'],
    priority: 0.6,
    cards: [
      CommunityDetailCard(
        id: 'mission',
        kind: CommunityCardKind.mission,
        title: LocalizedText(en: 'Purpose & Mission', fr: 'But / Mission'),
        body: LocalizedText(
          en: 'Amplify Amazigh voices by producing live salons, audio residencies, and collaborative archives across the diaspora.',
          fr: 'Amplifier les voix amazighes via des salons en direct, résidences audio et archives collaboratives à travers la diaspora.',
        ),
      ),
      CommunityDetailCard(
        id: 'activities',
        kind: CommunityCardKind.activities,
        title: LocalizedText(en: 'What We Host', fr: 'Ce que nous organisons'),
        items: [
          LocalizedText(
            en: 'Monthly salons mixing oral storytelling, music, and short films.',
            fr: 'Salons mensuels mêlant conte oral, musique et courts métrages.',
          ),
          LocalizedText(
            en: 'Podcast residencies pairing elders with emerging narrators.',
            fr: 'Résidences balado jumelant aîné·e·s et narrateur·rice·s émergent·e·s.',
          ),
          LocalizedText(
            en: 'Skill-shares on archiving, audio mixing, and multilingual captioning.',
            fr: 'Ateliers d’archivage, de mixage audio et de sous-titrage multilingue.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'contact',
        kind: CommunityCardKind.contact,
        title: LocalizedText(en: 'Stay Connected', fr: 'Rester connecté·e·s'),
        links: [
          CommunityLink(
            type: CommunityLinkType.email,
            label: 'Email',
            value: 'storytellers@diaspora.ca',
          ),
          CommunityLink(
            type: CommunityLinkType.website,
            label: 'Website',
            value: 'diasporastories.ca',
          ),
          CommunityLink(
            type: CommunityLinkType.instagram,
            label: 'Instagram',
            value: '@diaspora.stories',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'timeline',
        kind: CommunityCardKind.timeline,
        title: LocalizedText(en: 'Milestones', fr: 'Moments clés'),
        items: [
          LocalizedText(
            en: '2019: Launch partnered with Festival du Monde Arabe.',
            fr: '2019 : lancement en partenariat avec le Festival du Monde Arabe.',
          ),
          LocalizedText(
            en: '2021: Produced first bilingual audio zine featuring 14 storytellers.',
            fr: '2021 : première revue audio bilingue avec 14 conteur·se·s.',
          ),
          LocalizedText(
            en: '2024: Residency with Theatre du Nouveau Monde on Amazigh futurisms.',
            fr: '2024 : résidence avec le Théâtre du Nouveau Monde sur les futurismes amazighs.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'highlights',
        kind: CommunityCardKind.highlights,
        title: LocalizedText(en: 'Highlights', fr: 'À retenir'),
        items: [
          LocalizedText(
            en: '“Voix Plurielles” live anthology (2023).',
            fr: 'Anthologie en direct « Voix Plurielles » (2023).',
          ),
          LocalizedText(
            en: 'Mini-doc series on Amazigh radio pioneers.',
            fr: 'Mini-docs sur les pionnier·e·s de la radio amazighe.',
          ),
          LocalizedText(
            en: 'Toolkits for community media labs.',
            fr: 'Boîtes à outils pour laboratoires de médias communautaires.',
          ),
        ],
      ),
      CommunityDetailCard(
        id: 'tags',
        kind: CommunityCardKind.tags,
        title: LocalizedText(en: 'Tags', fr: 'Tags'),
        items: [
          LocalizedText(en: '#Diaspora', fr: '#Diaspora'),
          LocalizedText(en: '#Storytelling', fr: '#Conte'),
          LocalizedText(en: '#Audio', fr: '#Audio'),
          LocalizedText(en: '#Montreal', fr: '#Montréal'),
        ],
      ),
    ],
  ),
];
