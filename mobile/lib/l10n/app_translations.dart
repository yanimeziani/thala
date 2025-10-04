import 'package:flutter/widgets.dart';

enum AppText {
  appName,
  tagline,
  feedTab,
  createTab,
  eventsTab,
  communityTab,
  archiveTab,
  searchTab,
  archiveSearchPlaceholder,
  archiveSearchEmpty,
  archiveResultsLabel,
  archiveApprovalLabel,
  archiveThresholdLabel,
  exploreTab,
  profileTab,
  profileStoriesTab,
  profileLikedTab,
  profileMediaTab,
  profileStoriesCountLabel,
  profileAppreciationsCountLabel,
  profileSharesCountLabel,
  profileStoriesEmptyTitle,
  profileStoriesEmptyMessage,
  profileLikedEmptyTitle,
  profileLikedEmptyMessage,
  profileMediaEmptyTitle,
  profileMediaEmptyMessage,
  profileMessageAction,
  keepWatching,
  browseCommunities,
  discoverArchive,
  feedCopyLink,
  feedCopyLinkSubtitle,
  feedCommentHint,
  feedCommentCancel,
  feedCommentSend,
  feedAuthRequired,
  feedSupabaseRequired,
  feedLinkCopied,
  feedCommentSent,
  messagesTitle,
  messagesSubtitle,
  messagesEmpty,
  messagesConnectSupabase,
  messagesLoading,
  messagesOpenHint,
  messagesRefresh,
  messagesFallbackTitle,
  messagesThreadComingSoon,
  feedMute,
  feedUnmute,
  feedPublishDeferred,
  feedWelcomeSwipe,
  feedWelcomeSwipeHandle,
  feedWelcomeTip,
  likeAction,
  commentAction,
  shareAction,
  followAction,
  followingLabel,
  viewProfile,
  commonClose,
  commonCancel,
  commonSend,
  commonRequired,
  commonInvalidEmail,
  commonCopied,
  languageEnglish,
  languageFrench,
  heritagePill,
  culturePill,
  learnMore,
  browseStories,
  eventsTitle,
  eventsSubtitle,
  eventsOnlineLabel,
  eventsInPersonLabel,
  eventsHybridLabel,
  createCaptureTitle,
  createCaptureClose,
  createCaptureFlip,
  createCaptureFlash,
  createCaptureEffects,
  createCaptureMusic,
  createCaptureTapRecord,
  createCaptureTapStop,
  createCaptureGallery,
  createCaptureTimer,
  createCaptureTimerSoon,
  createCameraUnavailable,
  createCameraNotFound,
  createCameraError,
  createCameraSingle,
  createFlashUnavailable,
  createRecordingStartFailed,
  createRecordingFailed,
  createMusicSuggestionsTitle,
  createMusicNoTrackSelected,
  createReviewPlaceholder,
  createBackToCamera,
  createChangeTrack,
  createReplaceClip,
  createPreview,
  onboardingWelcomeTitle,
  onboardingWelcomeDescription,
  onboardingBegin,
  onboardingIdentityQuestion,
  onboardingIdentityYes,
  onboardingIdentityNo,
  onboardingCountryQuestion,
  onboardingFamilyQuestion,
  onboardingInterestQuestion,
  onboardingInterestYes,
  onboardingInterestNo,
  onboardingDiscoveryQuestion,
  onboardingDiscoveryHint,
  onboardingSummaryTitle,
  onboardingSummaryCountry,
  onboardingSummaryFamily,
  onboardingSummaryAllyEager,
  onboardingSummaryAllyGentle,
  onboardingSummaryDiscovery,
  onboardingSummaryEmpty,
  onboardingContinue,
  onboardingSkip,
  onboardingEnter,
  createStoryTitle,
  createStoryPublish,
  createStoryDetails,
  createStoryTitleEn,
  createStoryTitleFrOptional,
  createStoryDescriptionEn,
  createStoryDescriptionFrOptional,
  createStoryLocationEnOptional,
  createStoryLocationFrOptional,
  createStoryCreatorNameEn,
  createStoryCreatorNameFrOptional,
  createStoryCreatorHandle,
  createStoryHandleError,
  createStoryMusicLibrary,
  createStoryNoTrack,
  createStoryVisual,
  createStoryEffects,
  createStoryFieldRequired,
  createStorySelectVideoFirst,
  createStoryDefaultLocationEn,
  createStoryDefaultLocationFr,
  createStoryPublishError,
  createStoryChooseFromLibrary,
  createStoryRecordWithCamera,
  createStoryRecordAgain,
  createStoryVideoSelectionError,
  createStoryRemoveVideo,
  createStoryReplaceClip,
  createStoryTapToAddVideo,
  createStoryPublishing,
  createStoryPublishStory,
  createStorySavedLocally,
  musicTitle,
  musicSubtitle,
  musicPlayTrack,
  musicPauseTrack,
  musicNowPlaying,
  musicLoading,
  musicError,
  languageDescription,
  languageEnglishSubtitle,
  languageFrenchTitle,
  languageFrenchSubtitle,
  languageTitle,
  rightsTitle,
  rightsIntro,
  rightsBeforeTitle,
  rightsBeforeItem1,
  rightsBeforeItem2,
  rightsBeforeItem3,
  rightsSendTitle,
  rightsSendItem1,
  rightsSendItem2,
  rightsSendItem3,
  rightsSendItem4,
  rightsSendItem5,
  rightsNextTitle,
  rightsNextItem1,
  rightsNextItem2,
  rightsNextItem3,
  rightsNextItem4,
  rightsEmergencyTitle,
  rightsEmergencyDescription,
  rightsOpenAccount,
  communitySupabaseRequired,
  communityHostSuccess,
  communityHostFailure,
  communityEmpty,
  communityHostAction,
  communityMembersLabel,
  communityLanguagesLabel,
  communityFocusLabel,
  communityHostIntro,
  communityHostName,
  communityHostEmail,
  communityHostMessage,
  communityHostInvalidEmail,
  feedbackTitle,
  feedbackBugReport,
  feedbackFeatureRequest,
  feedbackGeneralFeedback,
  feedbackTitleHint,
  feedbackDescriptionHint,
  feedbackEmailHint,
  feedbackNameHint,
  feedbackSubmit,
  feedbackSuccess,
  feedbackError,
  feedbackTypeLabel,
  feedbackTitleLabel,
  feedbackDescriptionLabel,
  feedbackContactLabel,
  feedbackOptionalContact,
}

/// Lightweight translation helper backed by in-memory maps.
class AppTranslations {
  static String of(BuildContext context, AppText key) {
    return fromLocale(
      Localizations.maybeLocaleOf(context) ?? const Locale('en'),
      key,
    );
  }

  static String fromLocale(Locale locale, AppText key) {
    final languageCode = locale.languageCode.toLowerCase();
    final language = languageCode == 'fr' ? 'fr' :
                     languageCode == 'ar' ? 'ar' : 'en';
    final options = _values[key];
    if (options == null) {
      return '';
    }
    return options[language] ?? options['en'] ?? '';
  }

  static const Map<AppText, Map<String, String>> _values = {
    AppText.appName: {'en': 'Thala', 'fr': 'Thala', 'ar': 'ثالا'},
    AppText.tagline: {
      'en': 'Stories of Amazigh culture in motion',
      'fr': 'Les histoires de la culture amazighe en mouvement',
      'ar': 'قصص الثقافة الأمازيغية في حركة',
    },
    AppText.feedTab: {'en': 'For You', 'fr': 'Pour toi', 'ar': 'لك'},
    AppText.createTab: {'en': 'Create', 'fr': 'Créer', 'ar': 'إنشاء'},
    AppText.eventsTab: {'en': 'Events', 'fr': 'Événements', 'ar': 'الفعاليات'},
    AppText.communityTab: {'en': 'Community', 'fr': 'Communauté', 'ar': 'المجتمع'},
    AppText.archiveTab: {'en': 'Archive', 'fr': 'Archive', 'ar': 'الأرشيف'},
    AppText.searchTab: {'en': 'Search', 'fr': 'Recherche', 'ar': 'بحث'},
    AppText.archiveSearchPlaceholder: {
      'en': 'Search cultural treasures',
      'fr': 'Rechercher des trésors culturels',
      'ar': 'ابحث عن الكنوز الثقافية',
    },
    AppText.archiveSearchEmpty: {
      'en': 'No cultural treasures match your search yet.',
      'fr': 'Aucun trésor culturel ne correspond encore à ta recherche.',
      'ar': 'لا توجد كنوز ثقافية تطابق بحثك حتى الآن.',
    },
    AppText.archiveResultsLabel: {
      'en': 'cultural treasures',
      'fr': 'trésors culturels',
      'ar': 'كنوز ثقافية',
    },
    AppText.archiveApprovalLabel: {
      'en': 'Community approval',
      'fr': 'Approbation de la communauté',
      'ar': 'موافقة المجتمع',
    },
    AppText.archiveThresholdLabel: {
      'en': 'Archive threshold',
      'fr': "Seuil d'archive",
      'ar': 'عتبة الأرشيف',
    },
    AppText.exploreTab: {'en': 'Explore', 'fr': 'Explorer', 'ar': 'استكشف'},
    AppText.profileTab: {'en': 'Profile', 'fr': 'Profil', 'ar': 'الملف الشخصي'},
    AppText.profileStoriesTab: {'en': 'Stories', 'fr': 'Histoires', 'ar': 'القصص'},
    AppText.profileLikedTab: {'en': 'Liked', 'fr': 'Appréciés', 'ar': 'المفضلة'},
    AppText.profileMediaTab: {'en': 'Media', 'fr': 'Médias', 'ar': 'الوسائط'},
    AppText.profileStoriesCountLabel: {'en': 'Stories', 'fr': 'Histoires', 'ar': 'القصص'},
    AppText.profileAppreciationsCountLabel: {
      'en': 'Appreciations',
      'fr': 'Appréciations',
      'ar': 'التقديرات',
    },
    AppText.profileSharesCountLabel: {'en': 'Shares', 'fr': 'Partages', 'ar': 'المشاركات'},
    AppText.profileStoriesEmptyTitle: {
      'en': 'No stories yet',
      'fr': "Pas encore d'histoires",
      'ar': 'لا توجد قصص بعد',
    },
    AppText.profileStoriesEmptyMessage: {
      'en': 'This creator has not shared any stories yet.',
      'fr': "Ce créateur n'a pas encore partagé d'histoires.",
      'ar': 'لم يشارك هذا المبدع أي قصص بعد.',
    },
    AppText.profileLikedEmptyTitle: {
      'en': 'Nothing liked yet',
      'fr': 'Aucun contenu apprécié pour le moment',
      'ar': 'لا توجد إعجابات بعد',
    },
    AppText.profileLikedEmptyMessage: {
      'en':
          'Once you celebrate a story, it will appear here for quick reference.',
      'fr':
          'Lorsque tu célèbres une histoire, elle apparaîtra ici pour la retrouver facilement.',
      'ar':
          'عندما تحتفي بقصة، ستظهر هنا للرجوع إليها بسهولة.',
    },
    AppText.profileMediaEmptyTitle: {
      'en': 'No media yet',
      'fr': 'Pas encore de médias',
      'ar': 'لا توجد وسائط بعد',
    },
    AppText.profileMediaEmptyMessage: {
      'en':
          'As soon as this creator adds galleries or slides, they will appear here.',
      'fr':
          'Dès que ce créateur ajoutera des galeries ou des diaporamas, ils apparaîtront ici.',
      'ar':
          'بمجرد أن يضيف هذا المبدع معارض أو شرائح، ستظهر هنا.',
    },
    AppText.profileMessageAction: {'en': 'Message', 'fr': 'Message', 'ar': 'رسالة'},
    AppText.keepWatching: {'en': 'Keep watching', 'fr': 'Continuer', 'ar': 'واصل المشاهدة'},
    AppText.browseCommunities: {
      'en': 'Discover Amazigh communities',
      'fr': 'Découvre les communautés amazighes',
      'ar': 'اكتشف المجتمعات الأمازيغية',
    },
    AppText.discoverArchive: {
      'en': 'Explore the cultural archive',
      'fr': "Explore l'archive culturelle",
      'ar': 'استكشف الأرشيف الثقافي',
    },
    AppText.likeAction: {'en': 'Respect', 'fr': 'Respect', 'ar': 'احترام'},
    AppText.commentAction: {'en': 'Discuss', 'fr': 'Discuter', 'ar': 'ناقش'},
    AppText.shareAction: {'en': 'Share', 'fr': 'Partager', 'ar': 'شارك'},
    AppText.followAction: {'en': 'Follow', 'fr': 'Suivre', 'ar': 'متابعة'},
    AppText.followingLabel: {'en': 'Following', 'fr': 'Suivi', 'ar': 'متابَع'},
    AppText.viewProfile: {'en': 'View profile', 'fr': 'Voir le profil', 'ar': 'عرض الملف الشخصي'},
    AppText.commonClose: {'en': 'Close', 'fr': 'Fermer', 'ar': 'إغلاق'},
    AppText.commonCancel: {'en': 'Cancel', 'fr': 'Annuler', 'ar': 'إلغاء'},
    AppText.commonSend: {'en': 'Send', 'fr': 'Envoyer', 'ar': 'إرسال'},
    AppText.commonRequired: {'en': 'Required', 'fr': 'Requis', 'ar': 'مطلوب'},
    AppText.commonInvalidEmail: {
      'en': 'Enter a valid email',
      'fr': 'Saisis un email valide',
      'ar': 'أدخل بريداً إلكترونياً صالحاً',
    },
    AppText.commonCopied: {'en': 'Copied', 'fr': 'Copié', 'ar': 'تم النسخ'},
    AppText.languageEnglish: {'en': 'English', 'fr': 'Anglais', 'ar': 'الإنجليزية'},
    AppText.languageFrench: {'en': 'French', 'fr': 'Français', 'ar': 'الفرنسية'},
    AppText.heritagePill: {'en': 'Heritage', 'fr': 'Patrimoine', 'ar': 'التراث'},
    AppText.culturePill: {'en': 'Culture', 'fr': 'Culture', 'ar': 'الثقافة'},
    AppText.learnMore: {'en': 'Learn more', 'fr': 'En savoir plus', 'ar': 'اعرف المزيد'},
    AppText.browseStories: {'en': 'Browse stories', 'fr': 'Voir les histoires', 'ar': 'تصفح القصص'},
    AppText.eventsTitle: {
      'en': 'Upcoming events',
      'fr': 'Événements à venir',
      'ar': 'الفعاليات القادمة',
    },
    AppText.eventsSubtitle: {
      'en':
          'Gatherings, festivals, and workshops from Amazigh communities worldwide.',
      'fr':
          'Rencontres, festivals et ateliers des communautés amazighes à travers le monde.',
      'ar':
          'لقاءات ومهرجانات وورش عمل من المجتمعات الأمازيغية حول العالم.',
    },
    AppText.eventsOnlineLabel: {'en': 'Online', 'fr': 'En ligne', 'ar': 'عبر الإنترنت'},
    AppText.eventsInPersonLabel: {
      'en': 'In person',
      'fr': 'En présentiel',
      'ar': 'حضورياً',
    },
    AppText.eventsHybridLabel: {'en': 'Hybrid', 'fr': 'Hybride', 'ar': 'مختلط'},
    AppText.createCaptureTitle: {
      'en': 'Capture your story',
      'fr': 'Capture ton histoire',
      'ar': 'التقط قصتك',
    },
    AppText.createCaptureClose: {'en': 'Close', 'fr': 'Fermer', 'ar': 'إغلاق'},
    AppText.createCaptureFlip: {'en': 'Flip camera', 'fr': 'Changer de caméra', 'ar': 'قلب الكاميرا'},
    AppText.createCaptureFlash: {'en': 'Flash', 'fr': 'Flash', 'ar': 'فلاش'},
    AppText.createCaptureEffects: {'en': 'Effects', 'fr': 'Effets', 'ar': 'تأثيرات'},
    AppText.createCaptureMusic: {
      'en': 'Music library',
      'fr': 'Bibliothèque musicale',
      'ar': 'مكتبة الموسيقى',
    },
    AppText.createCaptureTapRecord: {
      'en': 'Tap to record',
      'fr': 'Appuie pour enregistrer',
      'ar': 'اضغط للتسجيل',
    },
    AppText.createCaptureTapStop: {
      'en': 'Tap to stop',
      'fr': 'Appuie pour arrêter',
      'ar': 'اضغط للإيقاف',
    },
    AppText.createCaptureGallery: {'en': 'Gallery', 'fr': 'Galerie', 'ar': 'المعرض'},
    AppText.createCaptureTimer: {'en': 'Timer', 'fr': 'Minuteur', 'ar': 'مؤقت'},
    AppText.createCaptureTimerSoon: {
      'en': 'Timer coming soon',
      'fr': 'Minuteur disponible bientôt',
      'ar': 'المؤقت قريباً',
    },
    AppText.createCameraUnavailable: {
      'en': 'Camera unavailable',
      'fr': 'Caméra indisponible',
      'ar': 'الكاميرا غير متاحة',
    },
    AppText.createCameraNotFound: {
      'en': 'No camera found on this device',
      'fr': 'Aucune caméra détectée sur cet appareil',
      'ar': 'لم يتم العثور على كاميرا على هذا الجهاز',
    },
    AppText.createCameraError: {
      'en': 'Camera error: {error}',
      'fr': 'Erreur caméra : {error}',
      'ar': 'خطأ في الكاميرا: {error}',
    },
    AppText.createCameraSingle: {
      'en': 'Only one camera detected',
      'fr': 'Une seule caméra détectée',
      'ar': 'تم اكتشاف كاميرا واحدة فقط',
    },
    AppText.createFlashUnavailable: {
      'en': 'Flash unavailable: {error}',
      'fr': 'Flash indisponible : {error}',
      'ar': 'الفلاش غير متاح: {error}',
    },
    AppText.createRecordingStartFailed: {
      'en': 'Could not start recording: {error}',
      'fr': 'Impossible de démarrer l'enregistrement : {error}',
      'ar': 'تعذر بدء التسجيل: {error}',
    },
    AppText.createRecordingFailed: {
      'en': 'Recording failed: {error}',
      'fr': 'Enregistrement échoué : {error}',
      'ar': 'فشل التسجيل: {error}',
    },
    AppText.createMusicSuggestionsTitle: {
      'en': 'Try these vibes',
      'fr': 'Essaie ces ambiances',
      'ar': 'جرب هذه الأجواء',
    },
    AppText.createMusicNoTrackSelected: {
      'en': 'No track selected',
      'fr': 'Aucune piste sélectionnée',
      'ar': 'لم يتم اختيار مقطع',
    },
    AppText.createReviewPlaceholder: {
      'en': 'Pick or record a clip',
      'fr': 'Choisis ou enregistre un clip',
      'ar': 'اختر أو سجل مقطعاً',
    },
    AppText.createBackToCamera: {
      'en': 'Back to camera',
      'fr': 'Retour à la caméra',
      'ar': 'العودة إلى الكاميرا',
    },
    AppText.createChangeTrack: {'en': 'Change track', 'fr': 'Changer de piste', 'ar': 'تغيير المقطع'},
    AppText.createReplaceClip: {
      'en': 'Replace clip',
      'fr': 'Remplacer le clip',
      'ar': 'استبدال المقطع',
    },
    AppText.createPreview: {'en': 'Preview', 'fr': 'Prévisualiser', 'ar': 'معاينة'},
    AppText.feedCopyLink: {'en': 'Copy link', 'fr': 'Copier le lien', 'ar': 'نسخ الرابط'},
    AppText.feedCopyLinkSubtitle: {
      'en': 'Copy media link to share later',
      'fr': 'Copie le lien du média pour le partager plus tard',
      'ar': 'انسخ رابط الوسائط لمشاركته لاحقاً',
    },
    AppText.feedCommentHint: {
      'en': 'Share your thoughts…',
      'fr': 'Partage tes pensées…',
      'ar': 'شارك أفكارك…',
    },
    AppText.feedCommentCancel: {'en': 'Cancel', 'fr': 'Annuler', 'ar': 'إلغاء'},
    AppText.feedCommentSend: {'en': 'Send', 'fr': 'Envoyer', 'ar': 'إرسال'},
    AppText.feedAuthRequired: {
      'en': 'Sign in to continue.',
      'fr': 'Connecte-toi pour continuer.',
      'ar': 'سجل الدخول للمتابعة.',
    },
    AppText.feedSupabaseRequired: {
      'en': 'Connect Supabase to continue.',
      'fr': 'Connecte Supabase pour continuer.',
      'ar': 'اتصل بـ Supabase للمتابعة.',
    },
    AppText.feedPublishDeferred: {
      'en': 'Could not publish story right now. Saved locally instead.',
      'fr':
          'Impossible de publier l'histoire pour le moment. Enregistrée localement.',
      'ar':
          'تعذر نشر القصة الآن. تم حفظها محلياً بدلاً من ذلك.',
    },
    AppText.feedWelcomeSwipe: {
      'en': 'Swipe up to meet creators from the Amazigh world.',
      'fr':
          'Glisse vers le haut pour rencontrer des créateurs du monde amazigh.',
      'ar':
          'اسحب للأعلى لمقابلة المبدعين من العالم الأمازيغي.',
    },
    AppText.feedWelcomeSwipeHandle: {
      'en': 'Swipe up to visit {handle} and more Amazigh creators.',
      'fr':
          'Glisse vers le haut pour découvrir {handle} et d'autres créateurs amazighs.',
      'ar':
          'اسحب للأعلى لزيارة {handle} والمزيد من المبدعين الأمازيغ.',
    },
    AppText.feedWelcomeTip: {
      'en': 'Tip: tap the + button to share your own diaspora story.',
      'fr':
          'Astuce : appuie sur le bouton + pour partager ton histoire de la diaspora.',
      'ar':
          'نصيحة: اضغط على زر + لمشاركة قصة الشتات الخاصة بك.',
    },
    AppText.feedLinkCopied: {
      'en': 'Link copied to clipboard',
      'fr': 'Lien copié dans le presse-papiers',
      'ar': 'تم نسخ الرابط إلى الحافظة',
    },
    AppText.feedCommentSent: {'en': 'Comment sent', 'fr': 'Commentaire envoyé', 'ar': 'تم إرسال التعليق'},
    AppText.messagesTitle: {'en': 'Messages', 'fr': 'Messages', 'ar': 'الرسائل'},
    AppText.messagesSubtitle: {
      'en': 'Stay in sync with your circles.',
      'fr': 'Reste en phase avec tes cercles.',
      'ar': 'ابق متزامناً مع دوائرك.',
    },
    AppText.messagesEmpty: {
      'en': 'No conversations yet.',
      'fr': 'Aucune conversation pour le moment.',
      'ar': 'لا توجد محادثات بعد.',
    },
    AppText.messagesConnectSupabase: {
      'en': 'Connect Supabase to sync secure threads.',
      'fr': 'Connecte Supabase pour synchroniser des fils sécurisés.',
      'ar': 'اتصل بـ Supabase لمزامنة المحادثات الآمنة.',
    },
    AppText.messagesLoading: {
      'en': 'Refreshing conversations...',
      'fr': 'Actualisation des conversations...',
      'ar': 'جارٍ تحديث المحادثات...',
    },
    AppText.messagesOpenHint: {
      'en': 'Open the messaging tray.',
      'fr': 'Ouvre la section messagerie.',
      'ar': 'افتح صندوق الرسائل.',
    },
    AppText.messagesRefresh: {
      'en': 'Refresh messages',
      'fr': 'Actualiser les messages',
      'ar': 'تحديث الرسائل',
    },
    AppText.messagesFallbackTitle: {
      'en': 'Community chat',
      'fr': 'Salon communautaire',
      'ar': 'دردشة المجتمع',
    },
    AppText.messagesThreadComingSoon: {
      'en': 'Message threads arrive soon.',
      'fr': 'Les discussions arrivent bientôt.',
      'ar': 'سلاسل الرسائل قريباً.',
    },
    AppText.feedMute: {'en': 'Mute', 'fr': 'Couper le son', 'ar': 'كتم الصوت'},
    AppText.feedUnmute: {'en': 'Unmute', 'fr': 'Activer le son', 'ar': 'إلغاء كتم الصوت'},
    AppText.onboardingWelcomeTitle: {
      'en': 'Azul! Welcome to Thala',
      'fr': 'Azul ! Bienvenue sur Thala',
      'ar': 'أزول! مرحباً بك في ثالا',
    },
    AppText.onboardingWelcomeDescription: {
      'en':
          'We are gathering Amazigh stories, rhythm, and memory. Share where you stand so we can honour your experience.',
      'fr':
          'Nous rassemblons les histoires, les rythmes et la mémoire amazighes. Partage ton point de vue pour que nous honorions ton expérience.',
      'ar':
          'نحن نجمع القصص والإيقاعات والذاكرة الأمازيغية. شارك موقفك حتى نتمكن من تكريم تجربتك.',
    },
    AppText.onboardingBegin: {'en': 'Begin', 'fr': 'Commencer', 'ar': 'ابدأ'},
    AppText.onboardingIdentityQuestion: {
      'en': 'Do you identify as Amazigh?',
      'fr': 'Te reconnais-tu comme Amazigh ?',
      'ar': 'هل تعرّف نفسك كأمازيغي؟',
    },
    AppText.onboardingIdentityYes: {
      'en': 'Yes, I am Amazigh',
      'fr': 'Oui, je suis Amazigh',
      'ar': 'نعم، أنا أمازيغي',
    },
    AppText.onboardingIdentityNo: {
      'en': 'No, I am an ally',
      'fr': 'Non, je suis allié·e',
      'ar': 'لا، أنا حليف',
    },
    AppText.onboardingCountryQuestion: {
      'en': 'Which territory reflects your Amazigh roots?',
      'fr': 'Quel territoire reflète tes racines amazighes ?',
      'ar': 'أي إقليم يعكس جذورك الأمازيغية؟',
    },
    AppText.onboardingFamilyQuestion: {
      'en': 'Which Amazigh cultural family do you connect with most?',
      'fr':
          'Avec quelle famille culturelle amazighe te sens-tu le plus lié·e ?',
      'ar':
          'مع أي عائلة ثقافية أمازيغية ترتبط أكثر؟',
    },
    AppText.onboardingInterestQuestion: {
      'en': 'Are you interested in Amazigh culture?',
      'fr': 'Es-tu intéressé·e par la culture amazighe ?',
      'ar': 'هل أنت مهتم بالثقافة الأمازيغية؟',
    },
    AppText.onboardingInterestYes: {
      'en': 'Yes, I want to learn and uplift',
      'fr': 'Oui, je veux apprendre et soutenir',
      'ar': 'نعم، أريد أن أتعلم وأدعم',
    },
    AppText.onboardingInterestNo: {
      'en': 'Not right now',
      'fr': 'Pas pour le moment',
      'ar': 'ليس الآن',
    },
    AppText.onboardingDiscoveryQuestion: {
      'en': 'Where did you learn about the Amazigh people?',
      'fr': 'Où as-tu découvert le peuple amazigh ?',
      'ar': 'أين تعرفت على الشعب الأمازيغي؟',
    },
    AppText.onboardingDiscoveryHint: {
      'en': 'Share the story, person, or moment that introduced you to us.',
      'fr':
          'Partage l'histoire, la personne ou le moment qui t'a présenté notre culture.',
      'ar':
          'شارك القصة أو الشخص أو اللحظة التي عرّفتك بنا.',
    },
    AppText.onboardingSummaryTitle: {
      'en': 'Tanemmirt! Your path is noted.',
      'fr': 'Tanemmirt ! Ton chemin est noté.',
      'ar': 'تانميرت! تم تسجيل مسارك.',
    },
    AppText.onboardingSummaryCountry: {
      'en': 'Rooted in {country} as part of the Amazigh family.',
      'fr': 'Ancré·e en {country} au sein de la famille amazighe.',
      'ar': 'متجذر في {country} كجزء من العائلة الأمازيغية.',
    },
    AppText.onboardingSummaryFamily: {
      'en': 'Connected most with {family}.',
      'fr': 'Lié·e surtout à {family}.',
      'ar': 'مرتبط أكثر بـ {family}.',
    },
    AppText.onboardingSummaryAllyEager: {
      'en': 'Joining as an ally who is eager to learn.',
      'fr': 'Tu rejoins la communauté comme allié·e curieux·se d'apprendre.',
      'ar': 'انضمامك كحليف متلهف للتعلم.',
    },
    AppText.onboardingSummaryAllyGentle: {
      'en': 'Visiting as an ally. We\'ll keep sharing gentle introductions.',
      'fr':
          'Tu visites en tant qu'allié·e. Nous continuerons à partager des introductions douces.',
      'ar':
          'زيارتك كحليف. سنستمر في مشاركة المقدمات اللطيفة.',
    },
    AppText.onboardingSummaryDiscovery: {
      'en': 'Discovered Amazigh culture via: "{source}".',
      'fr': 'Tu as découvert la culture amazighe grâce à : « {source} ».',
      'ar': 'اكتشفت الثقافة الأمازيغية عبر: "{source}".',
    },
    AppText.onboardingSummaryEmpty: {
      'en':
          'We are honoured you\'re here. Explore Thala and discover new Amazigh stories.',
      'fr':
          'Nous sommes honorés de t'accueillir. Explore Thala et découvre de nouvelles histoires amazighes.',
      'ar':
          'يشرفنا وجودك هنا. استكشف ثالا واكتشف قصصاً أمازيغية جديدة.',
    },
    AppText.onboardingContinue: {'en': 'Continue', 'fr': 'Continuer', 'ar': 'متابعة'},
    AppText.onboardingSkip: {'en': 'Skip', 'fr': 'Passer', 'ar': 'تخطي'},
    AppText.onboardingEnter: {'en': 'Enter Thala', 'fr': 'Entrer sur Thala', 'ar': 'ادخل إلى ثالا'},
    AppText.createStoryTitle: {
      'en': 'Create new story',
      'fr': 'Créer une nouvelle histoire',
      'ar': 'إنشاء قصة جديدة',
    },
    AppText.createStoryPublish: {'en': 'Publish', 'fr': 'Publier', 'ar': 'نشر'},
    AppText.createStoryDetails: {'en': 'Details', 'fr': 'Détails', 'ar': 'التفاصيل'},
    AppText.createStoryTitleEn: {
      'en': 'Title (English)',
      'fr': 'Titre (anglais)',
      'ar': 'العنوان (بالإنجليزية)',
    },
    AppText.createStoryTitleFrOptional: {
      'en': 'Title (French, optional)',
      'fr': 'Titre (français, optionnel)',
      'ar': 'العنوان (بالفرنسية، اختياري)',
    },
    AppText.createStoryDescriptionEn: {
      'en': 'Description (English)',
      'fr': 'Description (anglais)',
      'ar': 'الوصف (بالإنجليزية)',
    },
    AppText.createStoryDescriptionFrOptional: {
      'en': 'Description (French, optional)',
      'fr': 'Description (français, optionnel)',
      'ar': 'الوصف (بالفرنسية، اختياري)',
    },
    AppText.createStoryLocationEnOptional: {
      'en': 'Location (English, optional)',
      'fr': 'Lieu (anglais, optionnel)',
      'ar': 'الموقع (بالإنجليزية، اختياري)',
    },
    AppText.createStoryLocationFrOptional: {
      'en': 'Location (French, optional)',
      'fr': 'Lieu (français, optionnel)',
      'ar': 'الموقع (بالفرنسية، اختياري)',
    },
    AppText.createStoryCreatorNameEn: {
      'en': 'Creator name (English)',
      'fr': 'Nom du créateur ou de la créatrice (anglais)',
      'ar': 'اسم المبدع (بالإنجليزية)',
    },
    AppText.createStoryCreatorNameFrOptional: {
      'en': 'Creator name (French, optional)',
      'fr': 'Nom du créateur ou de la créatrice (français, optionnel)',
      'ar': 'اسم المبدع (بالفرنسية، اختياري)',
    },
    AppText.createStoryCreatorHandle: {
      'en': 'Creator handle',
      'fr': 'Pseudo du créateur ou de la créatrice',
      'ar': 'معرّف المبدع',
    },
    AppText.createStoryHandleError: {
      'en': 'Handle cannot be empty',
      'fr': 'Le pseudo ne peut pas être vide',
      'ar': 'لا يمكن أن يكون المعرّف فارغاً',
    },
    AppText.createStoryMusicLibrary: {
      'en': 'Music from Thala library',
      'fr': 'Musique de la bibliothèque Thala',
      'ar': 'موسيقى من مكتبة ثالا',
    },
    AppText.createStoryNoTrack: {'en': 'No track', 'fr': 'Aucun morceau', 'ar': 'لا يوجد مقطع'},
    AppText.createStoryVisual: {
      'en': 'Visual treatment',
      'fr': 'Traitement visuel',
      'ar': 'المعالجة البصرية',
    },
    AppText.createStoryEffects: {'en': 'Effects', 'fr': 'Effets', 'ar': 'تأثيرات'},
    AppText.createStoryFieldRequired: {
      'en': 'Please fill this field',
      'fr': 'Merci de renseigner ce champ',
      'ar': 'يرجى ملء هذا الحقل',
    },
    AppText.createStorySelectVideoFirst: {
      'en': 'Select or capture a video first.',
      'fr': 'Sélectionne ou capture une vidéo avant de continuer.',
      'ar': 'حدد أو التقط فيديو أولاً.',
    },
    AppText.createStoryDefaultLocationEn: {
      'en': 'Amazigh lands',
      'fr': 'Terres amazighes',
      'ar': 'أراضي الأمازيغ',
    },
    AppText.createStoryDefaultLocationFr: {
      'en': 'Terres amazighes',
      'fr': 'Terres amazighes',
      'ar': 'أراضي الأمازيغ',
    },
    AppText.createStoryPublishError: {
      'en': 'Could not publish story: {error}',
      'fr': 'Impossible de publier l'histoire : {error}',
      'ar': 'تعذر نشر القصة: {error}',
    },
    AppText.createStoryChooseFromLibrary: {
      'en': 'Choose from library',
      'fr': 'Choisir depuis la galerie',
      'ar': 'اختر من المكتبة',
    },
    AppText.createStoryRecordWithCamera: {
      'en': 'Record with camera',
      'fr': 'Filmer avec l'appareil photo',
      'ar': 'سجل بالكاميرا',
    },
    AppText.createStoryRecordAgain: {
      'en': 'Record again',
      'fr': 'Filmer à nouveau',
      'ar': 'سجل مرة أخرى',
    },
    AppText.createStoryVideoSelectionError: {
      'en': 'Video selection failed: {error}',
      'fr': 'La sélection vidéo a échoué : {error}',
      'ar': 'فشل اختيار الفيديو: {error}',
    },
    AppText.createStoryRemoveVideo: {
      'en': 'Remove video',
      'fr': 'Retirer la vidéo',
      'ar': 'إزالة الفيديو',
    },
    AppText.createStoryReplaceClip: {
      'en': 'Replace clip',
      'fr': 'Remplacer le clip',
      'ar': 'استبدال المقطع',
    },
    AppText.createStoryTapToAddVideo: {
      'en': 'Tap to add a vertical video',
      'fr': 'Appuie pour ajouter une vidéo verticale',
      'ar': 'اضغط لإضافة فيديو عمودي',
    },
    AppText.createStoryPublishing: {'en': 'Publishing…', 'fr': 'Publication…', 'ar': 'جارٍ النشر…'},
    AppText.createStoryPublishStory: {
      'en': 'Publish story',
      'fr': 'Publier l'histoire',
      'ar': 'نشر القصة',
    },
    AppText.createStorySavedLocally: {
      'en': 'Story saved locally.',
      'fr': 'Histoire enregistrée localement.',
      'ar': 'تم حفظ القصة محلياً.',
    },
    AppText.musicTitle: {
      'en': 'Thala Soundscapes',
      'fr': 'Paysages sonores Thala',
      'ar': 'مناظر ثالا الصوتية',
    },
    AppText.musicSubtitle: {
      'en': 'Live pulses from Amazigh music and voices',
      'fr': 'Vibrations en direct de la musique et des voix amazighes',
      'ar': 'نبضات حية من الموسيقى والأصوات الأمازيغية',
    },
    AppText.musicPlayTrack: {'en': 'Play', 'fr': 'Lire', 'ar': 'تشغيل'},
    AppText.musicPauseTrack: {'en': 'Pause', 'fr': 'Pause', 'ar': 'إيقاف مؤقت'},
    AppText.musicNowPlaying: {'en': 'Now playing', 'fr': 'Lecture en cours', 'ar': 'قيد التشغيل'},
    AppText.musicLoading: {
      'en': 'Loading track…',
      'fr': 'Chargement du morceau…',
      'ar': 'جارٍ تحميل المقطع…',
    },
    AppText.musicError: {
      'en': 'Unable to play track right now.',
      'fr': 'Lecture impossible pour le moment.',
      'ar': 'تعذر تشغيل المقطع الآن.',
    },
    AppText.languageDescription: {
      'en':
          'Choose the language for menus and cultural notes. Change takes effect instantly.',
      'fr':
          'Choisis la langue des menus et des notes culturelles. Le changement est immédiat.',
      'ar':
          'اختر اللغة للقوائم والملاحظات الثقافية. يتم تطبيق التغيير فوراً.',
    },
    AppText.languageEnglishSubtitle: {
      'en': 'Keep the interface and stories in English.',
      'fr': 'Conserve l'interface et les récits en anglais.',
      'ar': 'احتفظ بالواجهة والقصص باللغة الإنجليزية.',
    },
    AppText.languageFrenchTitle: {'en': 'Français', 'fr': 'Français', 'ar': 'الفرنسية'},
    AppText.languageFrenchSubtitle: {
      'en': 'Menus and stories translated into French.',
      'fr': 'Menus et récits traduits en français.',
      'ar': 'القوائم والقصص مترجمة إلى الفرنسية.',
    },
    AppText.languageTitle: {'en': 'Language', 'fr': 'Langue', 'ar': 'اللغة'},
    AppText.rightsTitle: {'en': 'Rights & safety', 'fr': 'Droits et sécurité', 'ar': 'الحقوق والسلامة'},
    AppText.rightsIntro: {
      'en':
          'We honour Amazigh creators and safeguard cultural guardianship. Use this form to request removal of content you own or that harms your community.',
      'fr':
          'Nous honorons les créateurs et créatrices amazighes et protégeons la gouvernance culturelle. Utilise ce formulaire pour demander le retrait d'un contenu qui t'appartient ou qui nuit à ta communauté.',
      'ar':
          'نحن نكرم المبدعين الأمازيغ ونحمي الحماية الثقافية. استخدم هذا النموذج لطلب إزالة محتوى تملكه أو يضر بمجتمعك.',
    },
    AppText.rightsBeforeTitle: {
      'en': 'Before you submit',
      'fr': 'Avant d'envoyer',
      'ar': 'قبل الإرسال',
    },
    AppText.rightsBeforeItem1: {
      'en':
          'Review the content on Thala and confirm it infringes your rights or community protocols.',
      'fr':
          'Vérifie le contenu sur Thala et confirme qu'il enfreint tes droits ou les protocoles de ta communauté.',
      'ar':
          'راجع المحتوى على ثالا وتأكد من أنه ينتهك حقوقك أو بروتوكولات مجتمعك.',
    },
    AppText.rightsBeforeItem2: {
      'en':
          'Gather links (URLs) to the exact stories, music, or posts you want removed.',
      'fr':
          'Rassemble les liens (URL) des histoires, musiques ou posts à retirer.',
      'ar':
          'اجمع الروابط (URLs) للقصص أو الموسيقى أو المنشورات التي تريد إزالتها.',
    },
    AppText.rightsBeforeItem3: {
      'en':
          'If you represent a cultural guardian group, identify the collective and provide contact details.',
      'fr':
          'Si tu représentes un collectif gardien, identifie le groupe et fournis des coordonnées.',
      'ar':
          'إذا كنت تمثل مجموعة حراس ثقافية، حدد المجموعة وقدم تفاصيل الاتصال.',
    },
    AppText.rightsSendTitle: {
      'en': 'Send your takedown request',
      'fr': 'Envoyer ta demande de retrait',
      'ar': 'أرسل طلب الإزالة',
    },
    AppText.rightsSendItem1: {
      'en': 'Email: rights@thala.culture',
      'fr': 'Courriel : rights@thala.culture',
      'ar': 'البريد الإلكتروني: rights@thala.culture',
    },
    AppText.rightsSendItem2: {
      'en': 'Subject line: COPYRIGHT TAKEDOWN - [Your Name / Collective]',
      'fr': 'Objet : COPYRIGHT TAKEDOWN - [Ton nom / Collectif]',
      'ar': 'سطر الموضوع: COPYRIGHT TAKEDOWN - [اسمك / المجموعة]',
    },
    AppText.rightsSendItem3: {
      'en':
          'Include: Full name, organisation (if any), contact email, phone (optional).',
      'fr':
          'Inclure : nom complet, organisation (le cas échéant), courriel et téléphone (optionnel).',
      'ar':
          'يشمل: الاسم الكامل، المنظمة (إن وجدت)، البريد الإلكتروني، الهاتف (اختياري).',
    },
    AppText.rightsSendItem4: {
      'en': 'Provide ownership proof or cultural stewardship context.',
      'fr':
          'Fournis une preuve de titularité ou le contexte de stewardship culturel.',
      'ar':
          'قدم دليل الملكية أو سياق الوصاية الثقافية.',
    },
    AppText.rightsSendItem5: {
      'en':
          'List each infringing link and describe why it violates your rights or protocols.',
      'fr':
          'Liste chaque lien en cause et décris pourquoi il enfreint tes droits ou protocoles.',
      'ar':
          'اسرد كل رابط منتهك ووصف لماذا ينتهك حقوقك أو بروتوكولاتك.',
    },
    AppText.rightsNextTitle: {
      'en': 'What happens next',
      'fr': 'Suite du processus',
      'ar': 'ما الذي يحدث بعد ذلك',
    },
    AppText.rightsNextItem1: {
      'en': 'We acknowledge your request within 48 hours.',
      'fr': 'Nous accusons réception de ta demande sous 48 heures.',
      'ar': 'نقر باستلام طلبك في غضون 48 ساعة.',
    },
    AppText.rightsNextItem2: {
      'en':
          'Our cultural review circle evaluates the claim and may contact you for verification.',
      'fr':
          'Notre cercle de revue culturelle évalue la demande et peut te contacter pour vérification.',
      'ar':
          'تقوم دائرة المراجعة الثقافية بتقييم الطلب وقد تتصل بك للتحقق.',
    },
    AppText.rightsNextItem3: {
      'en':
          'If validated, the content is removed or age-restricted and noted in the cultural registry.',
      'fr':
          'Si la demande est validée, le contenu est retiré ou restreint et enregistré dans le registre culturel.',
      'ar':
          'في حالة التحقق، تتم إزالة المحتوى أو تقييده حسب العمر وتسجيله في السجل الثقافي.',
    },
    AppText.rightsNextItem4: {
      'en':
          'We notify the uploader with anonymised details unless you request otherwise.',
      'fr':
          'Nous informons la personne qui a publié, avec des détails anonymisés sauf avis contraire.',
      'ar':
          'نبلغ الناشر بتفاصيل مجهولة المصدر ما لم تطلب خلاف ذلك.',
    },
    AppText.rightsEmergencyTitle: {
      'en': 'Emergency contact',
      'fr': 'Contact d'urgence',
      'ar': 'جهة اتصال الطوارئ',
    },
    AppText.rightsEmergencyDescription: {
      'en':
          'If the content presents immediate harm or contains sacred knowledge, email urgent@thala.culture with "EMERGENCY" in the subject. We will prioritise the review.',
      'fr':
          'Si le contenu cause un préjudice immédiat ou contient un savoir sacré, écris à urgent@thala.culture avec « EMERGENCY » dans l'objet. Nous prioriserons la revue.',
      'ar':
          'إذا كان المحتوى يمثل ضرراً فورياً أو يحتوي على معرفة مقدسة، راسل urgent@thala.culture مع كلمة "EMERGENCY" في الموضوع. سنعطي الأولوية للمراجعة.',
    },
    AppText.rightsOpenAccount: {
      'en': 'Open account settings',
      'fr': 'Ouvrir les paramètres du compte',
      'ar': 'فتح إعدادات الحساب',
    },
    AppText.communitySupabaseRequired: {
      'en': 'Connect Supabase to send a request.',
      'fr': 'Connecte Supabase pour envoyer une demande.',
      'ar': 'اتصل بـ Supabase لإرسال طلب.',
    },
    AppText.communityHostSuccess: {
      'en': 'Thanks! We will be in touch soon.',
      'fr': 'Tanemmirt ! Nous te recontacterons très vite.',
      'ar': 'شكراً! سنتواصل معك قريباً.',
    },
    AppText.communityHostFailure: {
      'en': 'Could not send the request right now.',
      'fr': 'Impossible d'envoyer la demande pour le moment.',
      'ar': 'تعذر إرسال الطلب الآن.',
    },
    AppText.communityEmpty: {
      'en': 'No community profiles yet.',
      'fr': 'Aucun profil de communauté pour le moment.',
      'ar': 'لا توجد ملفات تعريف المجتمع بعد.',
    },
    AppText.communityHostAction: {
      'en': 'Host a circle',
      'fr': 'Organiser un cercle',
      'ar': 'استضف دائرة',
    },
    AppText.communityMembersLabel: {'en': 'members', 'fr': 'membres', 'ar': 'الأعضاء'},
    AppText.communityLanguagesLabel: {'en': 'Languages', 'fr': 'Langues', 'ar': 'اللغات'},
    AppText.communityFocusLabel: {'en': 'Focus areas', 'fr': 'Axes d'action', 'ar': 'مجالات التركيز'},
    AppText.communityHostIntro: {
      'en': 'Share a few details and we'll reach out with next steps.',
      'fr': 'Partage quelques détails et nous reviendrons vers toi.',
      'ar': 'شارك بعض التفاصيل وسنتواصل معك بالخطوات التالية.',
    },
    AppText.communityHostName: {'en': 'Name', 'fr': 'Nom', 'ar': 'الاسم'},
    AppText.communityHostEmail: {'en': 'Email', 'fr': 'Email', 'ar': 'البريد الإلكتروني'},
    AppText.communityHostMessage: {
      'en': 'What would you like to host?',
      'fr': 'Que souhaites-tu organiser ?',
      'ar': 'ماذا تريد أن تستضيف؟',
    },
    AppText.communityHostInvalidEmail: {
      'en': 'Enter a valid email',
      'fr': 'Saisis un email valide',
      'ar': 'أدخل بريداً إلكترونياً صالحاً',
    },
    AppText.feedbackTitle: {
      'en': 'Send Feedback',
      'fr': 'Envoyer un retour',
      'ar': 'إرسال ملاحظات',
    },
    AppText.feedbackBugReport: {
      'en': 'Report a Bug',
      'fr': 'Signaler un bug',
      'ar': 'الإبلاغ عن خطأ',
    },
    AppText.feedbackFeatureRequest: {
      'en': 'Request a Feature',
      'fr': 'Demander une fonctionnalité',
      'ar': 'طلب ميزة',
    },
    AppText.feedbackGeneralFeedback: {
      'en': 'General Feedback',
      'fr': 'Retour général',
      'ar': 'ملاحظات عامة',
    },
    AppText.feedbackTitleHint: {
      'en': 'Brief summary of your feedback',
      'fr': 'Résumé bref de votre retour',
      'ar': 'ملخص موجز لملاحظاتك',
    },
    AppText.feedbackDescriptionHint: {
      'en': 'Describe your feedback in detail',
      'fr': 'Décrivez votre retour en détail',
      'ar': 'صف ملاحظاتك بالتفصيل',
    },
    AppText.feedbackEmailHint: {
      'en': 'Your email (optional)',
      'fr': 'Votre email (optionnel)',
      'ar': 'بريدك الإلكتروني (اختياري)',
    },
    AppText.feedbackNameHint: {
      'en': 'Your name (optional)',
      'fr': 'Votre nom (optionnel)',
      'ar': 'اسمك (اختياري)',
    },
    AppText.feedbackSubmit: {
      'en': 'Submit Feedback',
      'fr': 'Envoyer le retour',
      'ar': 'إرسال الملاحظات',
    },
    AppText.feedbackSuccess: {
      'en': 'Thank you! Your feedback has been submitted.',
      'fr': 'Merci ! Votre retour a été envoyé.',
      'ar': 'شكراً! تم إرسال ملاحظاتك.',
    },
    AppText.feedbackError: {
      'en': 'Could not submit feedback. Please try again.',
      'fr': 'Impossible d\'envoyer le retour. Veuillez réessayer.',
      'ar': 'تعذر إرسال الملاحظات. يرجى المحاولة مرة أخرى.',
    },
    AppText.feedbackTypeLabel: {
      'en': 'Feedback Type',
      'fr': 'Type de retour',
      'ar': 'نوع الملاحظات',
    },
    AppText.feedbackTitleLabel: {
      'en': 'Title',
      'fr': 'Titre',
      'ar': 'العنوان',
    },
    AppText.feedbackDescriptionLabel: {
      'en': 'Description',
      'fr': 'Description',
      'ar': 'الوصف',
    },
    AppText.feedbackContactLabel: {
      'en': 'Contact Information',
      'fr': 'Informations de contact',
      'ar': 'معلومات الاتصال',
    },
    AppText.feedbackOptionalContact: {
      'en': 'Optional - We may contact you for follow-up',
      'fr': 'Optionnel - Nous pouvons vous contacter pour un suivi',
      'ar': 'اختياري - قد نتواصل معك للمتابعة',
    },
  };
}
