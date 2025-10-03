import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";

import { LanguageSwitcher } from "@/components/language-switcher";
import { AndroidWaitlistForm } from "@/components/android-waitlist-form";
import { defaultLocale, locales, type Locale } from "@/i18n/config";
import { getDictionary } from "@/i18n/get-dictionary";
import thalaLogo from "@/public/logo.png";

type PageProps = {
  params: Promise<{
    locale: string;
  }>;
};

const normalizeLocale = (raw?: string): Locale => {
  return (locales as readonly string[]).includes(raw ?? "")
    ? (raw as Locale)
    : defaultLocale;
};

export const generateStaticParams = () => {
  return (locales as readonly string[]).map((locale) => ({ locale }));
};

export const generateMetadata = async ({ params }: PageProps): Promise<Metadata> => {
  const { locale: rawLocale } = await params;
  const locale = normalizeLocale(rawLocale);
  const dictionary = getDictionary(locale);

  const languageAlternates = Object.fromEntries(
    (locales as readonly string[]).map((value) => [value, `/${value}`])
  );

  return {
    title: dictionary.metadata.title,
    description: dictionary.metadata.description,
    openGraph: {
      title: dictionary.metadata.openGraph.title,
      description: dictionary.metadata.openGraph.description,
    },
    twitter: {
      card: "summary_large_image",
      title: dictionary.metadata.twitter.title,
      description: dictionary.metadata.twitter.description,
    },
    alternates: {
      languages: languageAlternates,
    },
  };
};

export default async function HomePage({ params }: PageProps) {
  const { locale: rawLocale } = await params;
  const locale = normalizeLocale(rawLocale);
  const dictionary = getDictionary(locale);
  const { navigation, hero, footer } = dictionary;

  return (
    <div className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden px-6">
      {/* Gradient background */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#0A1216] to-[#1A2329]" />

      <div className="absolute top-6 right-6 z-20">
        <LanguageSwitcher currentLocale={locale} ariaLabel={navigation.languageToggleAria} />
      </div>

      <main className="relative z-10 flex w-full max-w-md flex-col items-center text-center animate-in fade-in slide-in-from-bottom-8 duration-700">
        {/* Logo */}
        <div className="mb-6">
          <Image src={thalaLogo} alt="Thala" width={120} height={120} priority className="opacity-90" />
        </div>

        {/* Title */}
        <h1 className="text-4xl font-bold text-white tracking-tight mb-3">
          Thala
        </h1>

        {/* Subtitle */}
        <p className="text-white/60 mb-12">
          {hero.description}
        </p>

        {/* Glass card */}
        <div className="w-full bg-white/10 backdrop-blur-md rounded-3xl border border-white/20 p-8 shadow-2xl">
          <h2 className="text-xl font-semibold text-white mb-6">
            {hero.cardTitle}
          </h2>

          {/* iOS CTA */}
          <Link
            href={hero.iosCta.href}
            className="flex items-center justify-center w-full h-14 rounded-xl bg-white text-black font-semibold text-base transition-all hover:scale-[1.02] active:scale-[0.98] mb-4"
          >
            {hero.iosCta.label}
          </Link>

          {/* Android waitlist */}
          <AndroidWaitlistForm
            locale={locale}
            waitlistLabel={hero.androidWaitlistLabel}
            emailPlaceholder={hero.androidEmailPlaceholder}
            submitButton={hero.androidSubmitButton}
          />
        </div>

        <footer className="mt-12 flex flex-col items-center gap-4">
          <div className="flex gap-4 text-xs text-white/40">
            <Link href={`/${locale}/terms`} className="hover:text-[#ff9569] transition-colors">
              {footer.terms}
            </Link>
            <span>•</span>
            <Link href={`/${locale}/privacy`} className="hover:text-[#ff9569] transition-colors">
              {footer.privacy}
            </Link>
          </div>
          <div className="text-[0.65rem] uppercase tracking-[0.3em] text-white/40">
            {footer.note}
          </div>
        </footer>
      </main>
    </div>
  );
}
