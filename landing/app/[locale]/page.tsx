import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";

import { LanguageSwitcher } from "@/components/language-switcher";
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
    <div className="flex min-h-screen flex-col items-center justify-center bg-[color:var(--background)] text-[color:var(--foreground)] px-6">
      <div className="absolute top-6 right-6">
        <LanguageSwitcher currentLocale={locale} ariaLabel={navigation.languageToggleAria} />
      </div>

      <main className="flex w-full max-w-lg flex-col items-center text-center">
        <div className="mb-8">
          <Image src={thalaLogo} alt="Thala" width={56} height={56} priority />
        </div>

        <span className="text-[0.65rem] font-medium uppercase tracking-[0.3em] text-[color:var(--muted-soft)]">
          {hero.eyebrow}
        </span>

        <h1 className="mt-4 text-balance text-5xl font-bold leading-[1.1] tracking-tight sm:text-6xl">
          {hero.title}
        </h1>

        <p className="mt-6 max-w-md text-lg leading-relaxed text-[color:var(--muted)]">
          {hero.description}
        </p>

        <Link
          href={hero.iosCta.href}
          className="mt-10 inline-flex items-center justify-center rounded-full bg-[color:var(--foreground)] px-8 py-4 text-base font-semibold text-[color:var(--background)] transition-all hover:scale-105 hover:opacity-95 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[color:var(--foreground)]"
        >
          {hero.iosCta.label}
        </Link>

        <p className="mt-3 text-sm text-[color:var(--muted-soft)]">
          {hero.androidNote}
        </p>

        <div className="mt-16 space-y-2 text-sm text-[color:var(--muted)]">
          {hero.highlights.map((item) => (
            <p key={item}>{item}</p>
          ))}
        </div>

        <p className="mt-12 text-xs text-[color:var(--muted-soft)]">
          {hero.footnote}
        </p>

        <footer className="mt-16 text-[0.65rem] uppercase tracking-[0.3em] text-[color:var(--muted-soft)]">
          {footer.note}
        </footer>
      </main>
    </div>
  );
}
