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
    <div className="relative flex min-h-screen flex-col items-center overflow-hidden">
      {/* Warm sunset gradient background */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#1a0f0a] via-[#2d1810] to-[#0a0604]" />

      {/* Sunset glow - multiple layers for depth */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1200px] h-[1200px] bg-gradient-radial from-[#ff8844]/15 via-[#ff6633]/8 to-transparent blur-3xl pointer-events-none" />
      <div className="absolute bottom-0 right-0 w-[800px] h-[800px] bg-gradient-radial from-[#ffaa66]/10 via-transparent to-transparent blur-3xl pointer-events-none" />
      <div className="absolute top-1/3 left-0 w-[600px] h-[600px] bg-gradient-radial from-[#ff9569]/12 via-transparent to-transparent blur-3xl pointer-events-none" />

      <div className="absolute top-4 sm:top-6 right-4 sm:right-6 z-20">
        <LanguageSwitcher currentLocale={locale} ariaLabel={navigation.languageToggleAria} />
      </div>

      <main className="relative z-10 flex w-full max-w-lg flex-col items-center text-center px-5 sm:px-6 py-12 sm:py-16 animate-in fade-in slide-in-from-bottom-6 duration-1000 ease-out">
        {/* Logo with gentle animation */}
        <div className="mb-8 sm:mb-10 animate-in fade-in zoom-in-95 duration-700 delay-150">
          <Image
            src={thalaLogo}
            alt="Thala"
            width={100}
            height={100}
            priority
            className="opacity-95 drop-shadow-2xl w-[80px] h-[80px] sm:w-[100px] sm:h-[100px]"
          />
        </div>

        {/* Title with breathing room */}
        <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white tracking-tight mb-4 sm:mb-5 leading-tight max-w-sm animate-in fade-in slide-in-from-bottom-4 duration-700 delay-300">
          {hero.title}
        </h1>

        {/* Subtitle - warm and inviting */}
        <p className="text-base sm:text-lg text-white/70 mb-10 sm:mb-14 max-w-md leading-relaxed animate-in fade-in slide-in-from-bottom-3 duration-700 delay-500">
          {hero.description}
        </p>

        {/* Glass card - softer, more welcoming */}
        <div className="w-full bg-white/[0.06] backdrop-blur-xl rounded-[28px] border border-white/10 p-6 sm:p-8 md:p-10 shadow-2xl shadow-black/40 animate-in fade-in slide-in-from-bottom-2 duration-700 delay-700">
          <h2 className="text-lg sm:text-xl font-semibold text-white/95 mb-6 sm:mb-8 tracking-tight">
            {hero.cardTitle}
          </h2>

          {/* iOS CTA - warm sunset gradient */}
          <Link
            href={hero.iosCta.href}
            className="flex items-center justify-center w-full h-12 sm:h-14 rounded-2xl bg-gradient-to-br from-[#ffaa66] via-[#ff8844] to-[#ff7733] text-white font-semibold text-sm sm:text-base transition-all duration-300 hover:scale-[1.02] hover:shadow-xl hover:shadow-[#ff8844]/40 active:scale-[0.98] mb-4 sm:mb-5"
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

        {/* Spacer for better mobile spacing */}
        <div className="flex-grow min-h-8 sm:min-h-12" />

        {/* Footer - softer and more grounded */}
        <footer className="mt-auto pt-8 sm:pt-12 flex flex-col items-center gap-3 sm:gap-4 w-full">
          <div className="flex flex-wrap justify-center gap-3 sm:gap-4 text-xs sm:text-sm text-white/40">
            <Link href={`/${locale}/terms`} className="hover:text-[#ff9569] transition-colors duration-200">
              {footer.terms}
            </Link>
            <span className="text-white/20">•</span>
            <Link href={`/${locale}/privacy`} className="hover:text-[#ff9569] transition-colors duration-200">
              {footer.privacy}
            </Link>
          </div>
          <div className="text-[0.6rem] sm:text-[0.65rem] uppercase tracking-[0.3em] text-white/30 font-light">
            {footer.note}
          </div>
        </footer>
      </main>
    </div>
  );
}
