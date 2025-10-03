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
      className="flex items-center gap-1 rounded-full border border-[color:var(--border-soft)] bg-[color:var(--background)] px-1 py-1 text-[0.65rem] font-medium uppercase tracking-[0.28em] text-[color:var(--muted)] shadow-sm"
    >
      {(locales as readonly Locale[]).map((locale) => {
        const isActive = locale === currentLocale;
        const href = buildHref(pathname, locale);

        return (
          <Link
            key={locale}
            href={href}
            aria-current={isActive ? "page" : undefined}
            className={`rounded-full px-3 py-1 transition-colors focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[color:var(--foreground)] ${
              isActive
                ? "bg-[color:var(--foreground)] text-[color:var(--background)]"
                : "hover:text-[color:var(--foreground)]"
            }`}
          >
            {languageNames[locale]}
          </Link>
        );
      })}
    </nav>
  );
};
