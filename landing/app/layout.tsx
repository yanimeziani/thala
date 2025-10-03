import type { Metadata } from "next";
import Script from "next/script";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Thala | Kabyle Heritage Companion",
  description:
    "Discover and celebrate Kabyle culture with Thala. Explore curated experiences, learn traditions, and stay connected with your heritage.",
  openGraph: {
    title: "Thala | Kabyle Heritage Companion",
    description:
      "Discover Kabyle culture, personalized recommendations, and community stories in the Thala app.",
  },
  twitter: {
    card: "summary_large_image",
    title: "Thala | Kabyle Heritage Companion",
    description:
      "Discover Kabyle culture, personalized recommendations, and community stories in the Thala app.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <Script
          data-domain="thala.app"
          src="http://thala-plausible-edba5a-89-116-170-202.traefik.me/js/script.outbound-links.js"
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
