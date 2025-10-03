import type { Dictionary } from "@/i18n/types";

export const frDictionary: Dictionary = {
  metadata: {
    title: "Thala | Compagnon du patrimoine kabyle",
    description:
      "Découvrez et célébrez la culture kabyle avec Thala. Explorez des expériences sélectionnées, apprenez les traditions et restez connecté à votre héritage.",
    openGraph: {
      title: "Thala | Compagnon du patrimoine kabyle",
      description:
        "Découvrez la culture kabyle, des recommandations personnalisées et des récits communautaires dans l'application Thala.",
    },
    twitter: {
      title: "Thala | Compagnon du patrimoine kabyle",
      description:
        "Découvrez la culture kabyle, des recommandations personnalisées et des récits communautaires dans l'application Thala.",
    },
  },
  navigation: {
    downloadCta: "Télécharger sur iOS",
    languageToggleAria: "Changer de langue",
  },
  hero: {
    badge: "Célébrez l'identité amazighe",
    heading:
      "Plongez dans l'univers de la culture amazighe vivante et de ses histoires communautaires.",
    description:
      "Thala est le foyer social des créateurs, aînés et explorateurs amazighs. Découvrez les rituels quotidiens, co-créez des événements et formez des cercles qui relient atlas, littoraux et diasporas.",
    primaryCta: {
      href: "https://apps.apple.com",
      preTitle: "Télécharger sur l'",
      title: "App Store",
      initials: "AP",
    },
    secondaryCta: {
      preTitle: "Version Android",
      title: "Arrive début 2026",
      initials: "GP",
    },
    availabilityNote:
      "Thala est disponible sur iOS. Lancement Android prévu début 2026.",
    bulletPoints: [
      { text: "Rituels hebdomadaires et archives partageables", accent: "accent" },
      { text: "Multilingue (tamazight / français / anglais)", accent: "primary" },
      { text: "Créé par des organisateurs amazighs partout dans le monde", accent: "positive" },
    ],
  },
  phoneShowcase: {
    headerTitle: "Aujourd'hui en Tamazgha",
    badgeLabel: "À l'honneur",
    featuredTag: "À la une",
    featuredTitle: "Nuits Tifawin à Agadir",
    featuredDescription:
      "Rejoignez musiciens et poètes qui diffusent en direct des chants ancestraux sous le ciel du désert.",
    cards: [
      {
        title: "Salons Cercle",
        description: "Animez des dialogues bilingues sur le patrimoine, la cuisine et l'identité.",
        tone: "primary",
      },
      {
        title: "Capsules d'histoires",
        description: "Enregistrez des notes vocales et archivez-les pour votre clan à jamais.",
        tone: "accent",
      },
    ],
    tipTitle: "Conseil de la semaine",
    tipDescription:
      "Enregistrez les aînés prononçant des expressions en tamazight - l'IA aide à les traduire pour la communauté.",
  },
  highlights: [
    {
      title: "Explorez les tribus",
      description: "Découvrez les communautés de tout le Tamazgha, du Rif aux Aurès.",
    },
    {
      title: "Cercles culturels",
      description: "Organisez des salons de narration en direct et archivez-les pour chaque tribu.",
    },
    {
      title: "Marché",
      description: "Soutenez les artisans amazighs avec des boutiques vérifiées.",
    },
  ],
  gallery: {
    heading: "Découvrez Thala de l'intérieur",
    description:
      "Parcourez quelques moments produit - des rappels de rituels aux cercles communautaires et marchés sélectionnés.",
    instruction: "Balayez horizontalement",
    slideMetaLabel: "Aperçu en direct",
    slides: [
      {
        id: "rituals",
        tag: "Rituels",
        title: "Rappels de rituels",
        description: "Épinglez les cérémonies à l'aube et partagez-les avec votre cercle.",
        image:
          "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80",
      },
      {
        id: "circles",
        tag: "Cercles",
        title: "Cercles communautaires",
        description: "Écoutez des salons de narration en direct animés à travers le Tamazgha.",
        image:
          "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?auto=format&fit=crop&w=600&q=80",
      },
      {
        id: "marketplace",
        tag: "Marché",
        title: "Marché",
        description: "Soutenez des artisans vérifiés avec des créations amazighes sélectionnées.",
        image:
          "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&w=600&q=80",
      },
      {
        id: "archive",
        tag: "Archive",
        title: "Archive vivante",
        description: "Sauvegardez des histoires orales avec des traductions pour les générations futures.",
        image:
          "https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
  avatars: [
    { id: "amira", label: "Amira de Tizi Ouzou" },
    { id: "ikram", label: "Ikram à Paris" },
    { id: "farid", label: "Farid qui soigne les récits" },
    { id: "lila", label: "Lila partage son art" },
    { id: "samir", label: "Samir qui anime les cercles" },
  ],
};
