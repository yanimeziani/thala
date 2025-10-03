'use client';

import { useEffect } from 'react';
import { useParams } from 'next/navigation';

export default function CommunityRedirect() {
  const params = useParams();
  const communityId = params.id as string;

  useEffect(() => {
    const appScheme = `app.thala://community/${communityId}`;
    const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);

    if (isMobile) {
      window.location.href = appScheme;

      setTimeout(() => {
        const isIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent);
        const isAndroid = /Android/i.test(navigator.userAgent);

        if (isIOS) {
          window.location.href = 'https://apps.apple.com/app/thala/id123456789';
        } else if (isAndroid) {
          window.location.href = 'https://play.google.com/store/apps/details?id=app.thala';
        }
      }, 2500);
    }
  }, [communityId]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-900 via-purple-800 to-indigo-900">
      <div className="text-center px-6">
        <div className="mb-8">
          <div className="w-20 h-20 mx-auto mb-4 rounded-full bg-white/10 flex items-center justify-center">
            <svg className="w-10 h-10 text-white animate-spin" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-white mb-2">Opening Thala...</h1>
          <p className="text-purple-200">Taking you to this community</p>
        </div>

        <div className="mt-8 space-y-4">
          <a
            href={`app.thala://community/${communityId}`}
            className="inline-block px-8 py-3 bg-white text-purple-900 font-semibold rounded-full hover:bg-purple-50 transition-colors"
          >
            Open in Thala App
          </a>
          <p className="text-sm text-purple-300">
            Don't have the app?{' '}
            <a href="/" className="underline hover:text-white transition-colors">
              Learn more
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
