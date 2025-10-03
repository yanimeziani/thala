"use client";

import { FormEvent, useState } from "react";

type AndroidWaitlistFormProps = {
  locale: string;
  waitlistLabel: string;
  emailPlaceholder: string;
  submitButton: string;
};

export function AndroidWaitlistForm({
  locale,
  waitlistLabel,
  emailPlaceholder,
  submitButton,
}: AndroidWaitlistFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);

    const formData = new FormData(e.currentTarget);
    const email = formData.get("email") as string;
    const userLocale = formData.get("locale") as string;

    // TODO: Send to backend/email service
    console.log("Android waitlist submission:", { email, locale: userLocale });

    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 1000));

    setIsSubmitting(false);
    setIsSuccess(true);

    // Reset form after 3 seconds
    setTimeout(() => {
      setIsSuccess(false);
      (e.target as HTMLFormElement).reset();
    }, 3000);
  };

  return (
    <div className="pt-5 sm:pt-6 border-t border-white/[0.08]">
      <p className="text-xs sm:text-sm text-white/60 mb-3 sm:mb-4 font-light">{waitlistLabel}</p>
      <form className="flex flex-col sm:flex-row gap-2 sm:gap-2.5" onSubmit={handleSubmit}>
        <input
          type="email"
          name="email"
          placeholder={emailPlaceholder}
          className="flex-1 h-11 sm:h-12 px-4 bg-white/[0.04] border border-white/10 rounded-xl text-sm sm:text-base text-white placeholder:text-white/30 focus:outline-none focus:border-[#ff9569]/50 focus:bg-white/[0.06] transition-all duration-200 disabled:opacity-40"
          required
          disabled={isSubmitting || isSuccess}
        />
        <input type="hidden" name="locale" value={locale} />
        <button
          type="submit"
          disabled={isSubmitting || isSuccess}
          className="h-11 sm:h-12 px-5 sm:px-6 rounded-xl bg-[#ff9569]/10 border border-[#ff9569]/30 text-[#ff9569] text-sm sm:text-base font-medium hover:bg-[#ff9569]/20 hover:border-[#ff9569]/40 transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed whitespace-nowrap"
        >
          {isSuccess ? "✓" : submitButton}
        </button>
      </form>
    </div>
  );
}
