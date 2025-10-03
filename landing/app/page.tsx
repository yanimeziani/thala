import Image from "next/image";
import Link from "next/link";
import thalaLogo from "@/public/logo.png";

const avatars = [
  { id: "amira", label: "Amira from Tizi Ouzou", initials: "AM", position: "top-24 left-10" },
  { id: "ikram", label: "Ikram in Paris", initials: "IK", position: "bottom-36 left-20" },
  { id: "farid", label: "Farid curating stories", initials: "FA", position: "top-32 right-24" },
  { id: "lila", label: "Lila sharing art", initials: "LI", position: "bottom-24 right-[18%]" },
  { id: "samir", label: "Samir leading circles", initials: "SA", position: "top-[65%] right-[10%]" },
];

const highlights = [
  {
    title: "Explore Tribes",
    description: "Discover communities across Tamazgha, from Rif to Aures.",
  },
  {
    title: "Cultural Circles",
    description: "Host live storytelling rooms and archive them for every tribe.",
  },
  {
    title: "Marketplace",
    description: "Support Amazigh makers with verified artisan storefronts.",
  },
];

const screenshots = [
  {
    id: "rituals",
    title: "Ritual Reminders",
    description: "Pin sunrise ceremonies and share them with your circle.",
    image: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "circles",
    title: "Community Circles",
    description: "Listen to live storytelling rooms hosted across Tamazgha.",
    image: "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "marketplace",
    title: "Marketplace",
    description: "Support verified artisans with curated Amazigh goods.",
    image: "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "archive",
    title: "Living Archive",
    description: "Save oral histories with translations for future generations.",
    image: "https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80",
  },
];

export default function Home() {
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
        <div className="absolute inset-0 bg-gradient-to-br from-[var(--surface-strong)] via-[var(--background)] to-[var(--background-accent)] transition-[background] duration-500" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,_var(--primary-glow),_transparent_55%)] transition-opacity duration-500" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_bottom_right,_var(--accent-glow),_transparent_52%)] transition-opacity duration-500" />
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
          <Link
            href="#download"
            className="hidden rounded-full border border-soft bg-elevated px-6 py-2 text-sm font-semibold text-ink shadow-soft transition duration-300 hover:-translate-y-[1px] hover:shadow-card sm:inline-flex"
          >
            Download on iOS
          </Link>
        </header>

        <main className="relative mt-16 flex flex-1 flex-col items-center gap-12 text-center transition-colors duration-500 lg:mt-24 lg:flex-row lg:items-start lg:text-left">
          <div className="relative z-10 flex flex-1 flex-col items-center lg:items-start">
            <span className="inline-flex items-center gap-2 rounded-full border border-soft bg-surface-translucent px-5 py-2 text-xs font-semibold uppercase tracking-[0.3em] text-primary shadow-soft transition duration-300">
              Celebrate Amazigh Identity
            </span>
            <h1 className="mt-6 max-w-xl text-balance text-4xl font-semibold leading-tight text-ink sm:text-5xl lg:text-6xl">
              Indulge in the world of living Amazigh culture and community stories.
            </h1>
            <p className="mt-5 max-w-lg text-base leading-relaxed text-muted-soft sm:text-lg">
              Thala is the social home for Amazigh creators, elders, and explorers. Discover daily
              rituals, co-create events, and form circles that bridge atlases, coasts, and diasporas.
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
              <Link
                href="https://apps.apple.com"
                className="inline-flex min-w-[210px] items-center justify-center gap-3 rounded-full bg-primary px-6 py-3 text-left text-sm font-semibold text-white shadow-primary-glow transition duration-300 hover:scale-[1.02] hover:shadow-accent-glow"
              >
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-surface-veil text-sm font-bold tracking-wide text-white/90">
                  AP
                </span>
                <span>
                  <span className="block text-[0.65rem] uppercase tracking-[0.28em] text-white/70">
                    Download on the
                  </span>
                  <span className="block text-base text-white">App Store</span>
                </span>
              </Link>
              <div className="inline-flex min-w-[210px] items-center justify-center gap-3 rounded-full border border-soft bg-surface px-6 py-3 text-left text-sm font-semibold text-muted shadow-soft transition duration-300">
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-tint text-sm font-bold tracking-wide text-positive">
                  GP
                </span>
                <span>
                  <span className="block text-[0.65rem] uppercase tracking-[0.28em] text-muted-soft">
                    Android version
                  </span>
                  <span className="block text-base text-muted">Coming early 2026</span>
                </span>
              </div>
            </div>
            <p className="mt-2 text-xs text-muted-soft">
              Thala is currently available on iOS. Android launch planned for early 2026.
            </p>
            <div className="mt-6 flex flex-wrap justify-center gap-x-12 gap-y-3 text-sm text-muted lg:justify-start">
              <div className="flex items-center gap-2">
                <span className="inline-flex h-2.5 w-2.5 rounded-full bg-[color:var(--accent-soft)]" />
                Weekly rituals &amp; shareable archives
              </div>
              <div className="flex items-center gap-2">
                <span className="inline-flex h-2.5 w-2.5 rounded-full bg-[color:var(--primary-soft)]" />
                Multilingual (Tamazight / French / English)
              </div>
              <div className="flex items-center gap-2">
                <span className="inline-flex h-2.5 w-2.5 rounded-full bg-positive" />
                Built by Amazigh organizers worldwide
              </div>
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
                    <span>Today in Tamazgha</span>
                    <span className="rounded-full bg-primary-tint px-3 py-1 text-[10px] text-primary">
                      Spotlight
                    </span>
                  </div>
                  <div className="relative flex h-40 flex-col justify-end overflow-hidden rounded-3xl">
                    <div className="absolute inset-0 bg-gradient-to-br from-[var(--primary)] via-[var(--primary-soft)] to-[var(--accent-soft)] opacity-90" />
                    <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.24),_transparent_65%)]" />
                    <div className="relative space-y-2 p-5 text-white">
                      <span className="text-[10px] uppercase tracking-[0.32em] text-white/75">Featured</span>
                      <p className="text-lg font-semibold leading-snug">
                        Tifawin Nights in Agadir
                      </p>
                      <p className="text-xs text-white/85">
                        Join musicians and poets livestreaming ancestral chants under desert skies.
                      </p>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-3 text-[11px] text-muted-soft">
                    <div className="rounded-2xl border border-soft bg-surface p-4 shadow-soft">
                      <p className="font-semibold text-primary">Circle Rooms</p>
                      <p className="mt-2 leading-relaxed">
                        Host bilingual dialogues on heritage, food, and identity.
                      </p>
                    </div>
                    <div className="rounded-2xl border border-accent-soft bg-accent-tint p-4 shadow-soft">
                      <p className="font-semibold text-accent">Story Capsules</p>
                      <p className="mt-2 leading-relaxed">
                        Save voice notes and archive them for your clan forever.
                      </p>
                    </div>
                  </div>
                  <div className="rounded-3xl border border-primary-soft bg-primary-tint p-4 text-ink">
                    <p className="text-[11px] font-semibold uppercase tracking-[0.3em] text-primary">
                      Tip of the week
                    </p>
                    <p className="mt-2 text-sm text-muted">
                      Record elders speaking Tamazight phrases - AI assists with translations for the community.
                    </p>
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
              <h2 className="text-2xl font-semibold text-ink sm:text-3xl">Peek inside Thala</h2>
              <p className="mt-3 text-sm leading-relaxed text-muted">
                Scroll through a few product moments—from ritual reminders to community circles and curated marketplaces.
              </p>
            </div>
            <div className="text-xs font-semibold uppercase tracking-[0.35em] text-muted-soft">
              Swipe horizontally
            </div>
          </div>
          <div className="relative -mx-6 mt-10 sm:-mx-10">
            <div className="pointer-events-none absolute inset-y-0 left-0 hidden w-12 bg-gradient-to-r from-[var(--background)] to-transparent sm:block" aria-hidden="true" />
            <div className="pointer-events-none absolute inset-y-0 right-0 hidden w-12 bg-gradient-to-l from-[var(--background)] to-transparent sm:block" aria-hidden="true" />
            <div className="scrollbar-none flex gap-6 overflow-x-auto px-6 pb-6 pt-1 sm:px-10 snap-x snap-mandatory">
              {screenshots.map((item) => (
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
                        {item.id}
                      </span>
                      <h3 className="mt-3 text-lg font-semibold text-ink">{item.title}</h3>
                      <p className="mt-2 text-sm leading-relaxed text-muted-soft">{item.description}</p>
                    </div>
                    <span className="text-[10px] font-semibold uppercase tracking-[0.3em] text-muted-soft">
                      Live preview
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
