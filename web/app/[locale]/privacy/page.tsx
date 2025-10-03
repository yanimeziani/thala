import type { Metadata } from "next";
import Link from "next/link";

import { defaultLocale, locales, type Locale } from "@/i18n/config";
import { getDictionary } from "@/i18n/get-dictionary";
import { AnimatedBackground } from "@/components/animated-background";

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

  return {
    title: `${dictionary.privacy.title} — Thala`,
    description: dictionary.privacy.description,
  };
};

export default async function PrivacyPage({ params }: PageProps) {
  const { locale: rawLocale } = await params;
  const locale = normalizeLocale(rawLocale);
  const dictionary = getDictionary(locale);
  const { privacy } = dictionary;

  return (
    <div className="relative min-h-screen overflow-hidden text-[color:var(--foreground)] px-6 py-16">
      <AnimatedBackground />

      <div className="absolute inset-0 bg-gradient-to-b from-black/30 via-black/70 to-black/85 pointer-events-none" />

      <div className="relative z-10 mx-auto max-w-3xl">
        <Link
          href={`/${locale}`}
          className="inline-block mb-8 text-sm text-[#ff9569] hover:underline"
        >
          ← {privacy.backToHome}
        </Link>

        <div className="bg-black/55 backdrop-blur-sm rounded-3xl border border-white/10 p-8 md:p-12 shadow-2xl">
          <h1 className="text-4xl font-bold text-white mb-2">{privacy.title}</h1>
          <p className="text-sm text-[color:var(--muted-soft)] mb-8">{privacy.lastUpdated}</p>

          <div className="prose prose-invert max-w-none">
            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.section1.title}</h2>
              <p className="text-white/70 leading-relaxed mb-4">{privacy.section1.p1}</p>
              <p className="text-white/70 leading-relaxed">{privacy.section1.p2}</p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.section2.title}</h2>
              <p className="text-white/70 leading-relaxed mb-4">{privacy.section2.p1}</p>
              <ul className="list-disc list-inside text-white/70 space-y-2">
                {privacy.section2.list.map((item: string, i: number) => (
                  <li key={i}>{item}</li>
                ))}
              </ul>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.section3.title}</h2>
              <p className="text-white/70 leading-relaxed mb-4">{privacy.section3.p1}</p>
              <ul className="list-disc list-inside text-white/70 space-y-2">
                {privacy.section3.list.map((item: string, i: number) => (
                  <li key={i}>{item}</li>
                ))}
              </ul>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.section4.title}</h2>
              <p className="text-white/70 leading-relaxed">{privacy.section4.p1}</p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.section5.title}</h2>
              <p className="text-white/70 leading-relaxed mb-4">{privacy.section5.p1}</p>
              <p className="text-white/70 leading-relaxed">{privacy.section5.p2}</p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.section6.title}</h2>
              <p className="text-white/70 leading-relaxed">{privacy.section6.p1}</p>
            </section>

            <section className="mb-8">
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.section7.title}</h2>
              <p className="text-white/70 leading-relaxed">{privacy.section7.p1}</p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-white mb-4">{privacy.contact.title}</h2>
              <p className="text-white/70 leading-relaxed">
                {privacy.contact.p1}{" "}
                <a href="mailto:hello@thala.app" className="text-[#ff9569] hover:underline">
                  hello@thala.app
                </a>
              </p>
            </section>
          </div>
        </div>

        <footer className="mt-8 text-center text-xs text-[color:var(--muted-soft)]">
          <Link href={`/${locale}/terms`} className="hover:text-[#ff9569] transition-colors">
            {privacy.termsLink}
          </Link>
        </footer>
      </div>
    </div>
  );
}
