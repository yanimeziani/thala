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
    <div className="flex min-h-screen flex-col bg-[color:var(--background)] text-[color:var(--foreground)]">
      <header className="flex items-center justify-between px-5 pt-6 sm:px-6 md:px-8">
        <div className="flex items-center gap-2">
          <Image src={thalaLogo} alt="Thala" width={32} height={32} priority />
          <span className="text-xs font-semibold uppercase tracking-[0.4em]">Thala</span>
        </div>
        <LanguageSwitcher currentLocale={locale} ariaLabel={navigation.languageToggleAria} />
      </header>

      <main className="flex flex-1 flex-col px-5 pb-12 pt-10 sm:px-6 md:px-8">
        <div className="mx-auto flex w-full max-w-sm flex-1 flex-col">
          <section className="flex flex-1 flex-col">
            <span className="text-[0.65rem] font-semibold uppercase tracking-[0.45em] text-[color:var(--muted-soft)]">
              {hero.eyebrow}
            </span>
            <h1 className="mt-6 text-balance text-4xl font-semibold leading-tight sm:text-5xl">{hero.title}</h1>
            <p className="mt-4 text-base leading-relaxed text-[color:var(--muted)]">{hero.description}</p>
            <Link
              href={hero.iosCta.href}
              className="mt-8 inline-flex items-center justify-center rounded-full bg-[color:var(--foreground)] px-6 py-3 text-sm font-semibold text-[color:var(--background)] transition hover:opacity-90 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[color:var(--foreground)]"
            >
              {hero.iosCta.label}
            </Link>
            <p className="mt-3 text-sm text-[color:var(--muted-soft)]">{hero.androidNote}</p>
            <ul className="mt-8 space-y-3 text-sm text-[color:var(--muted)]">
              {hero.highlights.map((item) => (
                <li key={item} className="flex items-start gap-3">
                  <span
                    className="mt-1 inline-block h-2 w-2 rounded-full bg-[color:var(--foreground)]"
                    aria-hidden="true"
                  />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
            <p className="mt-8 text-xs text-[color:var(--muted-soft)]">{hero.footnote}</p>
          </section>

          <footer className="mt-16 border-t border-[color:var(--border-soft)] pt-6 text-xs uppercase tracking-[0.32em] text-[color:var(--muted-soft)]">
            {footer.note}
          </footer>
        </div>
      </main>
    </div>
  );
}
