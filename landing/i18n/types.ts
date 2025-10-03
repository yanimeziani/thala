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
    languageToggleAria: string;
  };
  hero: {
    eyebrow: string;
    title: string;
    description: string;
    iosCta: {
      href: string;
      label: string;
    };
    androidNote: string;
    highlights: string[];
    footnote: string;
  };
  footer: {
    note: string;
  };
};
