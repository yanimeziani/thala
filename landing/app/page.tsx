import Image from "next/image";
import Link from "next/link";

const features = [
  {
    badge: "Guided Journeys",
    title: "Curated cultural paths tailored to your interests",
    description:
      "Follow expertly crafted itineraries that highlight landmark villages, artisanal workshops, and the rituals that define Kabyle identity.",
  },
  {
    badge: "Smart Recommendations",
    title: "Personalized tips powered by your preferences",
    description:
      "Tell Thala what inspires you and receive recommendations on events, delicacies, and people to meet—updated as your tastes evolve.",
  },
  {
    badge: "Community Voices",
    title: "Stories from locals and the Kabyle diaspora",
    description:
      "Explore oral histories, music, and interviews that keep traditions alive and connect you with storytellers across generations.",
  },
  {
    badge: "Practical Toolkit",
    title: "Travel-ready insights for every step of the journey",
    description:
      "Access essential phrases, etiquette notes, and cultural context so you can show up with respect and confidence.",
  },
];

const previews = [
  {
    badge: "Explore",
    title: "Live discovery feed",
    description: "Scroll through featured festivals, hidden villages, and emerging artisans updated weekly.",
    gradient: "from-[#1a4aa8] via-[#3f6dd9] to-[#7397f0]",
  },
  {
    badge: "Plan",
    title: "Personalized itinerary",
    description: "Build day-by-day plans that blend cultural rituals, gastronomy, and nature escapes.",
    gradient: "from-[#23315b] via-[#1a4aa8] to-[#eb6a3b]",
  },
  {
    badge: "Connect",
    title: "Community spotlights",
    description: "Meet local hosts and diaspora mentors who share traditions and insider tips.",
    gradient: "from-[#eb6a3b] via-[#f29c6b] to-[#fbd5a7]",
  },
];

const faqs = [
  {
    question: "Who is Thala for?",
    answer:
      "Thala is built for Kabyle people across the globe, cultural explorers, and anyone curious about Amazigh traditions. Whether you're planning a trip home or discovering Kabylia for the first time, you will find guidance that respects the culture.",
  },
  {
    question: "Will Thala work offline?",
    answer:
      "Key itineraries, phrasebooks, and saved experiences will be available offline so you can stay informed even in remote mountain villages with limited coverage.",
  },
  {
    question: "How often is new content published?",
    answer:
      "Our editorial team collaborates with local experts and community contributors to release fresh guides, stories, and events every week.",
  },
  {
    question: "How can I contribute to the knowledge base?",
    answer:
      "You can apply to become a community storyteller directly in the app. Share your traditions, recipes, or recommendations—after review, your contribution will be featured to inspire others.",
  },
];

export default function Home() {
  const currentYear = new Date().getFullYear();

  return (
    <div className="flex min-h-screen flex-col bg-transparent text-[#1b1e2a]">
      <main className="flex flex-1 flex-col">
        <section className="relative isolate overflow-hidden px-6 pb-24 pt-20 sm:px-10 sm:pt-28">
          <div className="absolute inset-0 -z-10">
            <div className="absolute inset-0 bg-gradient-to-br from-white/95 via-white/88 to-[#dfe6fb]/70" />
            <Image
              src="/assets/bg.png"
              alt="Soft abstract background"
              fill
              className="object-cover opacity-20"
              sizes="100vw"
              priority
            />
          </div>
          <div className="mx-auto flex w-full max-w-6xl flex-col gap-14 lg:flex-row lg:items-center">
            <div className="flex-1 space-y-9">
              <div className="flex items-center gap-4">
                <Image
                  src="/assets/logo.png"
                  alt="Thala logo"
                  width={72}
                  height={72}
                  className="rounded-2xl shadow-lg shadow-[#1a4aa8]/20 ring-1 ring-black/5"
                  priority
                />
                <span className="text-sm font-semibold uppercase tracking-[0.28em] text-[#1a4aa8]">
                  Kabyle Heritage Companion
                </span>
              </div>
              <h1 className="text-balance text-4xl font-semibold leading-tight sm:text-5xl lg:text-6xl">
                Immerse yourself in Kabyle culture with guides built for modern explorers.
              </h1>
              <p className="max-w-xl text-base leading-relaxed text-[#3e4456] sm:text-lg">
                Thala curates stories, traditions, and experiences from the Kabyle world. Discover
                what to visit, what to taste, and how to stay connected to your roots—wherever you
                are.
              </p>
              <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
                <Link
                  href="https://apps.apple.com"
                  className="inline-flex items-center justify-center gap-3 rounded-full bg-[#1a4aa8] px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-[#1a4aa8]/30 transition hover:scale-[1.02] hover:shadow-xl hover:shadow-[#1a4aa8]/35"
                >
                  <span className="text-xs uppercase tracking-[0.3em]">Download</span>
                  <span className="text-base">App Store</span>
                </Link>
                <Link
                  href="https://play.google.com"
                  className="inline-flex items-center justify-center gap-3 rounded-full border border-[#1a4aa8]/40 bg-white/90 px-6 py-3 text-sm font-semibold text-[#1a4aa8] shadow-lg shadow-black/5 transition hover:scale-[1.02] hover:border-[#1a4aa8]/70"
                >
                  <span className="text-xs uppercase tracking-[0.3em]">Download</span>
                  <span className="text-base">Google Play</span>
                </Link>
                <span className="text-sm text-[#555b6f] sm:ml-4">Coming soon in your region.</span>
              </div>
              <div className="flex flex-wrap gap-x-8 gap-y-4 text-sm text-[#555b6f]">
                <div className="flex items-center gap-2">
                  <span className="inline-block h-2.5 w-2.5 rounded-full bg-[#eb6a3b]" />
                  Personalized cultural recommendations
                </div>
                <div className="flex items-center gap-2">
                  <span className="inline-block h-2.5 w-2.5 rounded-full bg-[#1a4aa8]" />
                  Multi-language support (Kabyle • French • English)
                </div>
                <div className="flex items-center gap-2">
                  <span className="inline-block h-2.5 w-2.5 rounded-full bg-[#2ac38d]" />
                  Offline access for saved guides
                </div>
              </div>
            </div>
            <div className="relative flex flex-1 justify-center lg:justify-end">
              <div className="relative flex w-full max-w-sm justify-center">
                <div className="absolute -left-6 top-12 h-36 w-36 rounded-full bg-[#eb6a3b]/30 blur-3xl" />
                <div className="absolute -right-6 bottom-8 h-32 w-32 rounded-full bg-[#1a4aa8]/25 blur-3xl" />
                <div className="relative h-[520px] w-[260px] rounded-[40px] border border-white/60 bg-white/95 p-6 shadow-2xl shadow-black/10">
                  <div className="absolute inset-x-16 -bottom-8 h-16 rounded-full bg-black/15 blur-xl" />
                  <div className="relative flex h-full flex-col gap-6 overflow-hidden rounded-[32px] border border-black/5 bg-gradient-to-br from-white/80 via-white/70 to-white/50 p-6">
                    <div className="flex items-center justify-between text-xs font-semibold text-[#1a4aa8]">
                      <span>Today in Kabylia</span>
                      <span className="rounded-full bg-[#1a4aa8]/10 px-3 py-1 text-[10px] text-[#1a4aa8]">
                        Discover
                      </span>
                    </div>
                    <div className="relative flex h-40 flex-col justify-end overflow-hidden rounded-3xl bg-[#1a4aa8]">
                      <Image
                        src="/assets/bg.png"
                        alt="Mountain village"
                        fill
                        className="object-cover opacity-70"
                        sizes="260px"
                      />
                      <div className="relative space-y-2 p-5 text-white">
                        <span className="text-[11px] uppercase tracking-[0.32em] text-white/70">
                          Featured Ritual
                        </span>
                        <p className="text-lg font-semibold leading-snug">
                          Yennayer celebration in Azazga
                        </p>
                        <p className="text-xs text-white/80">
                          Join families as they welcome the Amazigh new year with music and shared
                          dishes.
                        </p>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-3 text-[11px] text-[#3e4456]">
                      <div className="rounded-2xl border border-black/5 bg-white/80 p-4 shadow-sm shadow-black/5">
                        <p className="font-semibold text-[#1a4aa8]">Village Guides</p>
                        <p className="mt-2 leading-relaxed">
                          Map authentic homestays and artisans before you arrive.
                        </p>
                      </div>
                      <div className="rounded-2xl border border-black/5 bg-white/80 p-4 shadow-sm shadow-black/5">
                        <p className="font-semibold text-[#1a4aa8]">Phrasebook</p>
                        <p className="mt-2 leading-relaxed">
                          Learn essential Kabyle greetings with quick audio clips.
                        </p>
                      </div>
                    </div>
                    <div className="rounded-3xl border border-[#1a4aa8]/30 bg-[#1a4aa8]/10 p-4">
                      <p className="text-xs font-semibold uppercase tracking-[0.28em] text-[#1a4aa8]">
                        Tip of the week
                      </p>
                      <p className="mt-2 text-sm text-[#1b1e2a]">
                        Ask elders about traditional weaving patterns—they often hide family stories
                        passed through generations.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="features" className="mx-auto w-full max-w-6xl px-6 py-20 sm:py-24">
          <div className="flex flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
            <div className="max-w-2xl space-y-4">
              <span className="text-xs font-semibold uppercase tracking-[0.32em] text-[#eb6a3b]">
                Why Thala feels different
              </span>
              <h2 className="text-3xl font-semibold leading-tight text-balance sm:text-4xl">
                Everything you need to celebrate Kabyle culture with intention.
              </h2>
              <p className="text-base leading-relaxed text-[#3e4456]">
                From ancestral rituals to contemporary art, Thala collects the voices that keep our
                heritage alive. Save favourites, build itineraries, and share discoveries with your
                community in a few taps.
              </p>
            </div>
            <Link
              href="#download"
              className="inline-flex min-w-[180px] items-center justify-center rounded-full border border-[#1a4aa8] px-5 py-3 text-sm font-semibold text-[#1a4aa8] transition hover:bg-[#1a4aa8] hover:text-white"
            >
              Get the app
            </Link>
          </div>
          <div className="mt-12 grid gap-6 md:grid-cols-2">
            {features.map((feature) => (
              <article
                key={feature.title}
                className="group rounded-3xl border border-black/5 bg-white/90 p-8 shadow-lg shadow-black/5 transition hover:-translate-y-1 hover:shadow-xl"
              >
                <span className="inline-block rounded-full bg-[#eb6a3b]/15 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.28em] text-[#eb6a3b]">
                  {feature.badge}
                </span>
                <h3 className="mt-5 text-xl font-semibold leading-snug text-[#1b1e2a]">
                  {feature.title}
                </h3>
                <p className="mt-3 text-sm leading-relaxed text-[#3e4456]">
                  {feature.description}
                </p>
              </article>
            ))}
          </div>
        </section>

        <section
          id="screenshots"
          className="relative isolate overflow-hidden bg-white/60 px-6 py-24 sm:px-10"
        >
          <div className="absolute inset-0 -z-10 bg-gradient-to-b from-transparent via-white/70 to-white" />
          <div className="mx-auto flex w-full max-w-6xl flex-col items-center text-center">
            <span className="text-xs font-semibold uppercase tracking-[0.32em] text-[#1a4aa8]">
              A peek inside the app
            </span>
            <h2 className="mt-4 max-w-3xl text-balance text-3xl font-semibold leading-tight text-[#1b1e2a] sm:text-4xl">
              Screen designs that honour tradition while feeling refreshingly modern.
            </h2>
            <p className="mt-4 max-w-2xl text-base leading-relaxed text-[#3e4456]">
              Each flow in Thala pairs vibrant imagery from Kabylia with calm, legible interfaces. Here
              are a few screens captured from the latest build.
            </p>
            <div className="mt-16 flex flex-wrap justify-center gap-10">
              {previews.map((preview) => (
                <div
                  key={preview.title}
                  className="relative h-[500px] w-[250px] rounded-[40px] border border-white/60 bg-white/95 p-5 shadow-2xl shadow-black/10"
                >
                  <div className="absolute inset-x-14 -bottom-8 h-16 rounded-full bg-black/15 blur-xl" />
                  <div className="relative flex h-full flex-col overflow-hidden rounded-[32px]">
                    <div className={`absolute inset-0 bg-gradient-to-br ${preview.gradient} opacity-90`} />
                    <Image
                      src="/assets/bg.png"
                      alt="Abstract texture background"
                      fill
                      className="object-cover mix-blend-soft-light"
                      sizes="250px"
                    />
                    <div className="relative flex h-full flex-col justify-between p-6 text-white">
                      <div className="flex items-center justify-between text-[11px] font-semibold uppercase tracking-[0.32em]">
                        <span>Thala</span>
                        <span className="rounded-full bg-white/20 px-3 py-1 text-[10px] text-white">
                          {preview.badge}
                        </span>
                      </div>
                      <div>
                        <h3 className="text-left text-2xl font-semibold leading-snug">
                          {preview.title}
                        </h3>
                        <p className="mt-3 text-left text-sm text-white/80">
                          {preview.description}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section id="download" className="mx-auto w-full max-w-6xl px-6 py-20 sm:py-24">
          <div className="grid gap-12 rounded-[40px] border border-black/5 bg-white/90 p-10 shadow-xl shadow-black/10 lg:grid-cols-[1.1fr,0.9fr]">
            <div className="space-y-6">
              <span className="text-xs font-semibold uppercase tracking-[0.32em] text-[#eb6a3b]">
                Download Thala
              </span>
              <h2 className="text-balance text-3xl font-semibold leading-tight text-[#1b1e2a] sm:text-4xl">
                Experience Kabyle heritage in your pocket.
              </h2>
              <p className="text-base leading-relaxed text-[#3e4456]">
                Grab the app, synchronise your interests, and build a cultural journey that feels
                personal. If the stores are not yet live in your country, join our early access list and
                be the first to know.
              </p>
              <div className="flex flex-col gap-3 sm:flex-row">
                <Link
                  href="https://apps.apple.com"
                  className="inline-flex items-center justify-center gap-3 rounded-full bg-[#1a4aa8] px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-[#1a4aa8]/30 transition hover:scale-[1.02] hover:shadow-xl"
                >
                  <span className="text-xs uppercase tracking-[0.3em]">Download</span>
                  <span className="text-base">App Store</span>
                </Link>
                <Link
                  href="https://play.google.com"
                  className="inline-flex items-center justify-center gap-3 rounded-full border border-[#1a4aa8]/40 bg-white px-6 py-3 text-sm font-semibold text-[#1a4aa8] shadow-lg shadow-black/5 transition hover:scale-[1.02] hover:border-[#1a4aa8]/70"
                >
                  <span className="text-xs uppercase tracking-[0.3em]">Download</span>
                  <span className="text-base">Google Play</span>
                </Link>
              </div>
              <p className="text-sm text-[#555b6f]">
                Need early access? Email <a className="font-semibold text-[#1a4aa8]" href="mailto:hello@thala.app">hello@thala.app</a>
              </p>
            </div>
            <div className="space-y-6 rounded-3xl border border-[#1a4aa8]/25 bg-[#1a4aa8]/6 p-8">
              <h3 className="text-xl font-semibold text-[#1b1e2a]">
                Join the insider list
              </h3>
              <p className="text-sm leading-relaxed text-[#3e4456]">
                Receive monthly updates on new cultural guides, launch cities, and upcoming community
                gatherings.
              </p>
              <form className="flex flex-col gap-4 sm:flex-row">
                <input
                  type="email"
                  name="email"
                  placeholder="you@example.com"
                  className="h-12 flex-1 rounded-full border border-[#1a4aa8]/30 bg-white px-5 text-sm text-[#1b1e2a] placeholder:text-[#555b6f]/70 focus:border-[#1a4aa8] focus:outline-none"
                  required
                />
                <button
                  type="submit"
                  className="h-12 rounded-full bg-[#eb6a3b] px-6 text-sm font-semibold text-[#1b1e2a] shadow-lg shadow-[#eb6a3b]/30 transition hover:scale-[1.02] hover:shadow-xl"
                >
                  Notify me
                </button>
              </form>
              <p className="text-xs text-[#555b6f]">
                We respect your inbox. Expect a single email each month and you can unsubscribe at any time.
              </p>
            </div>
          </div>
        </section>

        <section id="faq" className="mx-auto w-full max-w-6xl px-6 pb-24">
          <div className="grid gap-12 lg:grid-cols-[0.9fr,1.1fr]">
            <div className="space-y-5">
              <span className="text-xs font-semibold uppercase tracking-[0.32em] text-[#1a4aa8]">
                Frequently asked
              </span>
              <h2 className="text-3xl font-semibold leading-tight text-[#1b1e2a] sm:text-4xl">
                All the details before you download the app.
              </h2>
              <p className="text-base leading-relaxed text-[#3e4456]">
                We gathered the most common questions from early beta testers. If you need anything else,
                reach out and our team will respond within a day.
              </p>
            </div>
            <div className="space-y-4">
              {faqs.map((faq) => (
                <details
                  key={faq.question}
                  className="group overflow-hidden rounded-3xl border border-black/5 bg-white/95 text-left shadow-lg shadow-black/5"
                >
                  <summary className="flex cursor-pointer list-none items-center justify-between gap-4 px-6 py-5 text-base font-semibold text-[#1b1e2a]">
                    {faq.question}
                    <span className="text-xl font-light text-[#1a4aa8] transition group-open:rotate-45">
                      +
                    </span>
                  </summary>
                  <div className="px-6 pb-6 text-sm leading-relaxed text-[#3e4456]">
                    {faq.answer}
                  </div>
                </details>
              ))}
            </div>
          </div>
        </section>
      </main>

      <footer className="border-t border-black/5 bg-white/80 py-10">
        <div className="mx-auto flex w-full max-w-6xl flex-col gap-3 px-6 text-sm text-[#555b6f] sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-3 text-[#1b1e2a]">
            <Image src="/assets/logo.png" alt="Thala logo" width={32} height={32} className="rounded-lg" />
            <span className="font-semibold">Thala</span>
          </div>
          <div className="flex flex-wrap gap-x-6 gap-y-2">
            <Link href="#features" className="hover:text-[#1a4aa8]">
              Features
            </Link>
            <Link href="#screenshots" className="hover:text-[#1a4aa8]">
              Screenshots
            </Link>
            <Link href="#download" className="hover:text-[#1a4aa8]">
              Download
            </Link>
            <a href="mailto:hello@thala.app" className="hover:text-[#1a4aa8]">
              Contact
            </a>
          </div>
          <p>© {currentYear} Thala. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
