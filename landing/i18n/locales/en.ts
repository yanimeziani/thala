import type { Dictionary } from "@/i18n/types";

export const enDictionary: Dictionary = {
  metadata: {
    title: "Thala | Kabyle Heritage Companion",
    description:
      "Discover and celebrate Kabyle culture with Thala. Explore curated experiences, learn traditions, and stay connected with your heritage.",
    openGraph: {
      title: "Thala | Kabyle Heritage Companion",
      description:
        "Discover Kabyle culture, personalized recommendations, and community stories in the Thala app.",
    },
    twitter: {
      title: "Thala | Kabyle Heritage Companion",
      description:
        "Discover Kabyle culture, personalized recommendations, and community stories in the Thala app.",
    },
  },
  navigation: {
    downloadCta: "Download on iOS",
    languageToggleAria: "Change language",
  },
  hero: {
    badge: "Celebrate Amazigh Identity",
    heading:
      "Indulge in the world of living Amazigh culture and community stories.",
    description:
      "Thala is the social home for Amazigh creators, elders, and explorers. Discover daily rituals, co-create events, and form circles that bridge atlases, coasts, and diasporas.",
    primaryCta: {
      href: "https://apps.apple.com",
      preTitle: "Download on the",
      title: "App Store",
      initials: "AP",
    },
    secondaryCta: {
      preTitle: "Android version",
      title: "Coming early 2026",
      initials: "GP",
    },
    availabilityNote:
      "Thala is currently available on iOS. Android launch planned for early 2026.",
    bulletPoints: [
      { text: "Weekly rituals & shareable archives", accent: "accent" },
      { text: "Multilingual (Tamazight / French / English)", accent: "primary" },
      { text: "Built by Amazigh organizers worldwide", accent: "positive" },
    ],
  },
  phoneShowcase: {
    headerTitle: "Today in Tamazgha",
    badgeLabel: "Spotlight",
    featuredTag: "Featured",
    featuredTitle: "Tifawin Nights in Agadir",
    featuredDescription:
      "Join musicians and poets livestreaming ancestral chants under desert skies.",
    cards: [
      {
        title: "Circle Rooms",
        description: "Host bilingual dialogues on heritage, food, and identity.",
        tone: "primary",
      },
      {
        title: "Story Capsules",
        description: "Save voice notes and archive them for your clan forever.",
        tone: "accent",
      },
    ],
    tipTitle: "Tip of the week",
    tipDescription:
      "Record elders speaking Tamazight phrases - AI assists with translations for the community.",
  },
  highlights: [
    {
      title: "Explore Tribes",
      description: "Discover communities across Tamazgha, from Rif to Aures.",
    },
    {
      title: "Cultural Circles",
      description: "Host live storytelling rooms and archive them for every tribe.",
    },
    {
      title: "Marketplace",
      description: "Support Amazigh makers with verified artisan storefronts.",
    },
  ],
  gallery: {
    heading: "Peek inside Thala",
    description:
      "Scroll through a few product moments—from ritual reminders to community circles and curated marketplaces.",
    instruction: "Swipe horizontally",
    slideMetaLabel: "Live preview",
    slides: [
      {
        id: "rituals",
        tag: "Rituals",
        title: "Ritual Reminders",
        description: "Pin sunrise ceremonies and share them with your circle.",
        image: "/gallery/rituals.jpg",
      },
      {
        id: "circles",
        tag: "Circles",
        title: "Community Circles",
        description: "Listen to live storytelling rooms hosted across Tamazgha.",
        image: "/gallery/circles.jpg",
      },
      {
        id: "marketplace",
        tag: "Marketplace",
        title: "Marketplace",
        description: "Support verified artisans with curated Amazigh goods.",
        image: "/gallery/marketplace.jpg",
      },
      {
        id: "archive",
        tag: "Archive",
        title: "Living Archive",
        description: "Save oral histories with translations for future generations.",
        image: "/gallery/archive.jpg",
      },
    ],
  },
  avatars: [
    { id: "amira", label: "Amira from Tizi Ouzou" },
    { id: "ikram", label: "Ikram in Paris" },
    { id: "farid", label: "Farid curating stories" },
    { id: "lila", label: "Lila sharing art" },
    { id: "samir", label: "Samir leading circles" },
  ],
};
