import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";

import { LanguageSwitcher } from "@/components/language-switcher";
import { defaultLocale, locales, type Locale } from "@/i18n/config";
import { getDictionary } from "@/i18n/get-dictionary";
import thalaLogo from "@/public/logo.png";

const AVATAR_LAYOUT = [
  { id: "amira", initials: "AM", position: "top-24 left-10" },
  { id: "ikram", initials: "IK", position: "bottom-36 left-20" },
  { id: "farid", initials: "FA", position: "top-32 right-24" },
  { id: "lila", initials: "LI", position: "bottom-24 right-[18%]" },
  { id: "samir", initials: "SA", position: "top-[65%] right-[10%]" },
] as const;

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
  const { navigation, hero, phoneShowcase, highlights, gallery } = dictionary;

  const avatarLabels = new Map(dictionary.avatars.map((entry) => [entry.id, entry.label]));
  const avatars = AVATAR_LAYOUT.map((avatar) => ({
    ...avatar,
    label: avatarLabels.get(avatar.id) ?? avatar.initials,
  }));

  const bulletToneClass: Record<"accent" | "primary" | "positive", string> = {
    accent: "bg-[color:var(--accent-soft)]",
    primary: "bg-[color:var(--primary-soft)]",
    positive: "bg-positive",
  };

  return (
    <div className="relative min-h-screen overflow-hidden bg-[var(--background)] text-ink transition-colors duration-500">
      <div className="absolute inset-0 -z-30 overflow-hidden" aria-hidden="true">
        <video
          className="h-full w-full scale-110 object-cover blur-sm brightness-[0.7]"
          autoPlay
          loop
          muted
          playsInline
          preload="auto"
          poster="/bg.png"
          src="/bg.mp4"
        />
      </div>
      <div className="absolute inset-0 -z-20">
        <div className="absolute inset-0 bg-gradient-to-br from-[var(--surface-strong)] via-[var(--background)] to-[var(--background-accent)] opacity-80 transition-[background] duration-500" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,_var(--primary-glow),_transparent_55%)] opacity-60 transition-opacity duration-500" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_bottom_right,_var(--accent-glow),_transparent_52%)] opacity-50 transition-opacity duration-500" />
        <svg
          viewBox="0 0 1440 900"
          className="absolute inset-0 h-full w-full stroke-[color:var(--grid-stroke)] transition-colors duration-500"
          fill="none"
          aria-hidden="true"
        >
          <path
            strokeWidth="1"
            strokeLinecap="round"
            d="M0 150h140l60-60 60 60h140l60 60 60-60h140l60-60 60 60h140l60 60 60-60h140l60-60 60 60h140"
            opacity="0.45"
          />
          <path
            strokeWidth="1"
            strokeLinecap="round"
            d="M0 420h140l60-60 60 60h140l60 60 60-60h140l60-60 60 60h140l60 60 60-60h140l60-60 60 60h140"
            opacity="0.35"
          />
          <path
            strokeWidth="1"
            strokeLinecap="round"
            d="M0 690h140l60-60 60 60h140l60 60 60-60h140l60-60 60 60h140l60 60 60-60h140l60-60 60 60h140"
            opacity="0.28"
          />
        </svg>
      </div>

      <div className="relative mx-auto flex w-full max-w-6xl flex-col px-6 pb-32 pt-8 sm:px-10 lg:pb-36">
        <header className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Image
              src={thalaLogo}
              alt="Thala logo"
              width={40}
              height={40}
              className="rounded-xl shadow-primary-glow transition-shadow duration-300"
              priority
            />
            <span className="text-lg font-semibold tracking-[0.22em] uppercase text-primary transition-colors duration-500">
              Thala
            </span>
          </div>
          <div className="flex items-center gap-3">
            <LanguageSwitcher currentLocale={locale} ariaLabel={navigation.languageToggleAria} />
            <Link
              href="#download"
              className="hidden rounded-full border border-soft bg-elevated px-6 py-2 text-sm font-semibold text-ink shadow-soft transition duration-300 hover:-translate-y-[1px] hover:shadow-card sm:inline-flex"
            >
              {navigation.downloadCta}
            </Link>
          </div>
        </header>

        <main className="relative mt-16 flex flex-1 flex-col items-center gap-12 text-center transition-colors duration-500 lg:mt-24 lg:flex-row lg:items-start lg:text-left">
          <div className="relative z-10 flex flex-1 flex-col items-center lg:items-start">
            <span className="inline-flex items-center gap-2 rounded-full border border-soft bg-surface-translucent px-5 py-2 text-xs font-semibold uppercase tracking-[0.3em] text-primary shadow-soft transition duration-300">
              {hero.badge}
            </span>
            <h1 className="mt-6 max-w-xl text-balance text-4xl font-semibold leading-tight text-ink sm:text-5xl lg:text-6xl">
              {hero.heading}
            </h1>
            <p className="mt-5 max-w-lg text-base leading-relaxed text-muted-soft sm:text-lg">
              {hero.description}
            </p>
            <div id="download" className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
              <Link
                href={hero.primaryCta.href}
                className="inline-flex min-w-[210px] items-center justify-center gap-3 rounded-full bg-primary px-6 py-3 text-left text-sm font-semibold text-white shadow-primary-glow transition duration-300 hover:scale-[1.02] hover:shadow-accent-glow"
              >
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-surface-veil text-sm font-bold tracking-wide text-white/90">
                  {hero.primaryCta.initials}
                </span>
                <span>
                  <span className="block text-[0.65rem] uppercase tracking-[0.28em] text-white/70">
                    {hero.primaryCta.preTitle}
                  </span>
                  <span className="block text-base text-white">{hero.primaryCta.title}</span>
                </span>
              </Link>
              <div className="inline-flex min-w-[210px] items-center justify-center gap-3 rounded-full border border-soft bg-surface px-6 py-3 text-left text-sm font-semibold text-muted shadow-soft transition duration-300">
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-tint text-sm font-bold tracking-wide text-positive">
                  {hero.secondaryCta.initials}
                </span>
                <span>
                  <span className="block text-[0.65rem] uppercase tracking-[0.28em] text-muted-soft">
                    {hero.secondaryCta.preTitle}
                  </span>
                  <span className="block text-base text-muted">{hero.secondaryCta.title}</span>
                </span>
              </div>
            </div>
            <p className="mt-2 text-xs text-muted-soft">{hero.availabilityNote}</p>
            <div className="mt-6 flex flex-wrap justify-center gap-x-12 gap-y-3 text-sm text-muted lg:justify-start">
              {hero.bulletPoints.map(({ text, accent }) => (
                <div key={text} className="flex items-center gap-2">
                  <span className={`inline-flex h-2.5 w-2.5 rounded-full ${bulletToneClass[accent]}`} />
                  {text}
                </div>
              ))}
            </div>
          </div>

          <div className="relative z-10 flex flex-1 justify-center lg:justify-end">
            <div className="relative flex w-full max-w-md justify-center">
              <div className="absolute -left-12 top-32 h-40 w-40 rounded-full bg-primary-tint blur-3xl" />
              <div className="absolute -right-8 bottom-16 h-36 w-36 rounded-full bg-sunrise-tint blur-3xl" />
              <div className="relative h-[520px] w-[260px] rounded-[45px] border border-strong bg-surface-strong p-5 shadow-card transition-colors duration-500">
                <div className="absolute inset-x-10 -bottom-10 h-16 rounded-full bg-surface-translucent blur-xl" />
                <div className="relative flex h-full flex-col gap-5 overflow-hidden rounded-[36px] border border-soft bg-gradient-to-br from-[var(--surface-strong)] via-[var(--surface)] to-[var(--background-elevated)] p-5 transition-colors duration-500">
                  <div className="flex items-center justify-between text-xs font-semibold text-muted">
                    <span>{phoneShowcase.headerTitle}</span>
                    <span className="rounded-full bg-primary-tint px-3 py-1 text-[10px] text-primary">
                      {phoneShowcase.badgeLabel}
                    </span>
                  </div>
                  <div className="relative flex h-40 flex-col justify-end overflow-hidden rounded-3xl">
                    <div className="absolute inset-0 bg-gradient-to-br from-[var(--primary)] via-[var(--primary-soft)] to-[var(--accent-soft)] opacity-90" />
                    <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.24),_transparent_65%)]" />
                    <div className="relative space-y-2 p-5 text-white">
                      <span className="text-[10px] uppercase tracking-[0.32em] text-white/75">{phoneShowcase.featuredTag}</span>
                      <p className="text-lg font-semibold leading-snug">{phoneShowcase.featuredTitle}</p>
                      <p className="text-xs text-white/85">{phoneShowcase.featuredDescription}</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-3 text-[11px] text-muted-soft">
                    {phoneShowcase.cards.map((card) => (
                      <div
                        key={card.title}
                        className={`rounded-2xl border ${
                          card.tone === "accent"
                            ? "border-accent-soft bg-accent-tint"
                            : "border-soft bg-surface"
                        } p-4 shadow-soft`}
                      >
                        <p
                          className={`font-semibold ${
                            card.tone === "accent" ? "text-accent" : "text-primary"
                          }`}
                        >
                          {card.title}
                        </p>
                        <p className="mt-2 leading-relaxed">{card.description}</p>
                      </div>
                    ))}
                  </div>
                  <div className="rounded-3xl border border-primary-soft bg-primary-tint p-4 text-ink">
                    <p className="text-[11px] font-semibold uppercase tracking-[0.3em] text-primary">
                      {phoneShowcase.tipTitle}
                    </p>
                    <p className="mt-2 text-sm text-muted">{phoneShowcase.tipDescription}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>

        <section className="relative z-10 mt-24 grid gap-6 rounded-[36px] border border-strong bg-elevated p-8 shadow-card transition-colors duration-500 lg:grid-cols-3">
          {highlights.map((item) => (
            <div
              key={item.title}
              className="rounded-3xl border border-soft bg-surface p-6 text-left transition-colors duration-500"
            >
              <h3 className="text-lg font-semibold text-ink">{item.title}</h3>
              <p className="mt-3 text-sm leading-relaxed text-muted-soft">{item.description}</p>
            </div>
          ))}
        </section>

        <section className="relative z-10 mt-24">
          <div className="flex flex-col items-center justify-between gap-6 text-center lg:flex-row lg:text-left">
            <div className="max-w-xl">
              <h2 className="text-2xl font-semibold text-ink sm:text-3xl">{gallery.heading}</h2>
              <p className="mt-3 text-sm leading-relaxed text-muted">{gallery.description}</p>
            </div>
            <div className="text-xs font-semibold uppercase tracking-[0.35em] text-muted-soft">
              {gallery.instruction}
            </div>
          </div>
          <div className="relative -mx-6 mt-10 sm:-mx-10">
            <div className="pointer-events-none absolute inset-y-0 left-0 hidden w-12 bg-gradient-to-r from-[var(--background)] to-transparent sm:block" aria-hidden="true" />
            <div className="pointer-events-none absolute inset-y-0 right-0 hidden w-12 bg-gradient-to-l from-[var(--background)] to-transparent sm:block" aria-hidden="true" />
            <div className="scrollbar-none flex gap-6 overflow-x-auto px-6 pb-6 pt-1 sm:px-10 snap-x snap-mandatory">
              {gallery.slides.map((item) => (
                <article
                  key={item.id}
                  className="group relative flex w-[280px] shrink-0 snap-start flex-col overflow-hidden rounded-[28px] border border-strong bg-surface shadow-card transition-transform duration-300 hover:-translate-y-1 sm:w-[320px]"
                >
                  <div className="relative h-52 w-full overflow-hidden">
                    <Image
                      src={item.image}
                      alt={item.title}
                      fill
                      sizes="(max-width: 768px) 280px, 320px"
                      className="object-cover transition-transform duration-500 group-hover:scale-[1.05]"
                    />
                  </div>
                  <div className="flex flex-1 flex-col justify-between gap-4 p-5 text-left">
                    <div>
                      <span className="text-xs font-semibold uppercase tracking-[0.32em] text-primary-soft">
                        {item.tag}
                      </span>
                      <h3 className="mt-3 text-lg font-semibold text-ink">{item.title}</h3>
                      <p className="mt-2 text-sm leading-relaxed text-muted-soft">{item.description}</p>
                    </div>
                    <span className="text-[10px] font-semibold uppercase tracking-[0.3em] text-muted-soft">
                      {gallery.slideMetaLabel}
                    </span>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>
      </div>

      <div className="pointer-events-none absolute inset-x-0 top-24 -z-10 hidden h-[480px] w-full max-w-6xl translate-x-[-50%] lg:left-1/2 lg:block">
        <div className="relative h-full w-full">
          {avatars.map((avatar) => (
            <div
              key={avatar.id}
              className={`absolute ${avatar.position} flex h-16 w-16 items-center justify-center rounded-full border border-soft bg-elevated text-base font-semibold tracking-wide text-primary shadow-float transition-colors duration-500`}
            >
              <span aria-hidden="true">{avatar.initials}</span>
              <span className="sr-only">{avatar.label}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
