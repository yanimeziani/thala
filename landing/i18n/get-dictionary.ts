import { defaultLocale, type Locale } from "@/i18n/config";
import type { Dictionary } from "@/i18n/types";
import { enDictionary } from "@/i18n/locales/en";
import { frDictionary } from "@/i18n/locales/fr";

const dictionaries: Record<Locale, Dictionary> = {
  en: enDictionary,
  fr: frDictionary,
};

export const getDictionary = (locale: Locale): Dictionary => {
  return dictionaries[locale] ?? dictionaries[defaultLocale];
};

export const availableDictionaries = dictionaries;
