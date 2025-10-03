import Script from "next/script";
import { Geist, Geist_Mono } from "next/font/google";

import { defaultLocale, locales, type Locale } from "@/i18n/config";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const plausibleDataDomain =
  process.env.NEXT_PUBLIC_PLAUSIBLE_DATA_DOMAIN ?? "thala.app";
const plausibleScriptSrc =
  process.env.NEXT_PUBLIC_PLAUSIBLE_SCRIPT_SRC ??
  "https://plausible.io/js/script.outbound-links.js";
const plausibleApiEndpoint = process.env.NEXT_PUBLIC_PLAUSIBLE_API_ENDPOINT;

type RootLayoutProps = {
  children: React.ReactNode;
  params: {
    locale?: string;
  };
};

const resolveLocale = (raw?: string): Locale => {
  return (locales as readonly string[]).includes(raw ?? "")
    ? (raw as Locale)
    : defaultLocale;
};

export default function RootLayout({
  children,
  params,
}: Readonly<RootLayoutProps>) {
  const locale = resolveLocale(params.locale);

  return (
    <html lang={locale}>
      <head>
        <Script
          data-domain={plausibleDataDomain}
          data-api={plausibleApiEndpoint || undefined}
          src={plausibleScriptSrc}
          strategy="afterInteractive"
        />
      </head>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
