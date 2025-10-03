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
    cardTitle: string;
    iosCta: {
      href: string;
      label: string;
    };
    androidWaitlistLabel: string;
    androidEmailPlaceholder: string;
    androidSubmitButton: string;
    androidNote: string;
    highlights: string[];
    footnote: string;
  };
  footer: {
    note: string;
    terms: string;
    privacy: string;
  };
  terms: {
    title: string;
    description: string;
    lastUpdated: string;
    backToHome: string;
    privacyLink: string;
    section1: {
      title: string;
      p1: string;
      p2: string;
    };
    section2: {
      title: string;
      p1: string;
      p2: string;
    };
    section3: {
      title: string;
      p1: string;
      list: string[];
      p2: string;
    };
    section4: {
      title: string;
      p1: string;
    };
    section5: {
      title: string;
      p1: string;
      p2: string;
    };
    section6: {
      title: string;
      p1: string;
    };
    contact: {
      title: string;
      p1: string;
    };
  };
  privacy: {
    title: string;
    description: string;
    lastUpdated: string;
    backToHome: string;
    termsLink: string;
    section1: {
      title: string;
      p1: string;
      p2: string;
    };
    section2: {
      title: string;
      p1: string;
      list: string[];
    };
    section3: {
      title: string;
      p1: string;
      list: string[];
    };
    section4: {
      title: string;
      p1: string;
    };
    section5: {
      title: string;
      p1: string;
      p2: string;
    };
    section6: {
      title: string;
      p1: string;
    };
    section7: {
      title: string;
      p1: string;
    };
    contact: {
      title: string;
      p1: string;
    };
  };
};
