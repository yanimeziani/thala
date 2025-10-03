"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

import { languageNames, locales, type Locale } from "@/i18n/config";

type LanguageSwitcherProps = {
  currentLocale: Locale;
  ariaLabel: string;
};

const buildHref = (pathname: string, targetLocale: Locale) => {
  const segments = pathname.split("/").filter(Boolean);

  if (segments.length === 0) {
    segments.push(targetLocale);
  } else {
    segments[0] = targetLocale;
  }

  return `/${segments.join("/")}`;
};

export const LanguageSwitcher = ({ currentLocale, ariaLabel }: LanguageSwitcherProps) => {
  const pathname = usePathname() || "/";

  return (
    <nav
      aria-label={ariaLabel}
      className="flex items-center gap-1 rounded-full border border-soft bg-surface-translucent p-1 text-xs font-semibold uppercase tracking-[0.3em] text-muted"
    >
      {(locales as readonly Locale[]).map((locale) => {
        const isActive = locale === currentLocale;
        const href = buildHref(pathname, locale);

        return (
          <Link
            key={locale}
            href={href}
            aria-current={isActive ? "page" : undefined}
            className={`rounded-full px-3 py-1 transition ${
              isActive ? "bg-primary text-white shadow-primary-glow" : "hover:bg-surface"
            }`}
          >
            {languageNames[locale]}
          </Link>
        );
      })}
    </nav>
  );
};
