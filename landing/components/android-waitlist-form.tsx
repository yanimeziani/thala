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
    <div className="pt-6 border-t border-white/10">
      <p className="text-sm text-white/70 mb-3">{waitlistLabel}</p>
      <form className="flex gap-2" onSubmit={handleSubmit}>
        <input
          type="email"
          name="email"
          placeholder={emailPlaceholder}
          className="flex-1 h-12 px-4 bg-white/5 border border-white/20 rounded-lg text-white placeholder:text-white/40 focus:outline-none focus:border-[#ff9569] transition-colors disabled:opacity-50"
          required
          disabled={isSubmitting || isSuccess}
        />
        <input type="hidden" name="locale" value={locale} />
        <button
          type="submit"
          disabled={isSubmitting || isSuccess}
          className="px-6 h-12 rounded-lg bg-[#ff9569]/20 border border-[#ff9569]/40 text-[#ff9569] font-medium hover:bg-[#ff9569]/30 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSuccess ? "✓" : submitButton}
        </button>
      </form>
    </div>
  );
}
