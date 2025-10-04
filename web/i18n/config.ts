export const locales = ["en", "fr", "ar"] as const;

export type Locale = (typeof locales)[number];

export const defaultLocale: Locale = "en";

export const languageNames: Record<Locale, string> = {
  en: "English",
  fr: "Français",
  ar: "العربية",
};
