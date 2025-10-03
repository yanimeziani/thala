export type Highlight = {
  title: string;
  description: string;
};

export type GallerySlide = {
  id: string;
  tag: string;
  title: string;
  description: string;
  image: string;
};

export type AvatarTranslation = {
  id: string;
  label: string;
};

export type FeatureCard = {
  title: string;
  description: string;
  tone: "primary" | "accent";
};

export type Dictionary = {
  metadata: {
    title: string;
    description: string;
    openGraph: {
      title: string;
      description: string;
    };
    twitter: {
      title: string;
      description: string;
    };
  };
  navigation: {
    downloadCta: string;
    languageToggleAria: string;
  };
  hero: {
    badge: string;
    heading: string;
    description: string;
    primaryCta: {
      href: string;
      preTitle: string;
      title: string;
      initials: string;
    };
    secondaryCta: {
      preTitle: string;
      title: string;
      initials: string;
    };
    availabilityNote: string;
    bulletPoints: Array<{
      text: string;
      accent: "accent" | "primary" | "positive";
    }>;
  };
  phoneShowcase: {
    headerTitle: string;
    badgeLabel: string;
    featuredTag: string;
    featuredTitle: string;
    featuredDescription: string;
    cards: FeatureCard[];
    tipTitle: string;
    tipDescription: string;
  };
  highlights: Highlight[];
  gallery: {
    heading: string;
    description: string;
    instruction: string;
    slideMetaLabel: string;
    slides: GallerySlide[];
  };
  avatars: AvatarTranslation[];
};
