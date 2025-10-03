import Script from "next/script";
import { Bricolage_Grotesque } from "next/font/google";

import { defaultLocale } from "@/i18n/config";
import "./globals.css";

const bricolage = Bricolage_Grotesque({
  variable: "--font-bricolage",
  subsets: ["latin"],
  weight: ["200", "300", "400", "500", "600", "700", "800"],
});

const plausibleDataDomain =
  process.env.NEXT_PUBLIC_PLAUSIBLE_DATA_DOMAIN ?? "thala.app";
const plausibleScriptSrc =
  process.env.NEXT_PUBLIC_PLAUSIBLE_SCRIPT_SRC ??
  "https://plausible.io/js/script.outbound-links.js";
const plausibleApiEndpoint = process.env.NEXT_PUBLIC_PLAUSIBLE_API_ENDPOINT;

type RootLayoutProps = {
  children: React.ReactNode;
};

export default function RootLayout({ children }: Readonly<RootLayoutProps>) {
  return (
    <html lang={defaultLocale}>
      <head>
        <Script
          data-domain={plausibleDataDomain}
          data-api={plausibleApiEndpoint || undefined}
          src={plausibleScriptSrc}
          strategy="afterInteractive"
        />
      </head>
      <body
        className={`${bricolage.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
