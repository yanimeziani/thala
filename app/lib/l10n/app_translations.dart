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
    final language = locale.languageCode.toLowerCase() == 'fr' ? 'fr' : 'en';
    final options = _values[key];
    if (options == null) {
      return '';
    }
    return options[language] ?? options['en'] ?? '';
  }

  static const Map<AppText, Map<String, String>> _values = {
    AppText.appName: {'en': 'Thela', 'fr': 'Thela'},
    AppText.tagline: {
      'en': 'Stories of Amazigh culture in motion',
      'fr': 'Les histoires de la culture amazighe en mouvement',
    },
    AppText.feedTab: {'en': 'For You', 'fr': 'Pour toi'},
    AppText.createTab: {'en': 'Create', 'fr': 'Créer'},
    AppText.eventsTab: {'en': 'Events', 'fr': 'Événements'},
    AppText.communityTab: {'en': 'Community', 'fr': 'Communauté'},
    AppText.archiveTab: {'en': 'Archive', 'fr': 'Archive'},
    AppText.searchTab: {'en': 'Search', 'fr': 'Recherche'},
    AppText.archiveSearchPlaceholder: {
      'en': 'Search cultural treasures',
      'fr': 'Rechercher des trésors culturels',
    },
    AppText.archiveSearchEmpty: {
      'en': 'No cultural treasures match your search yet.',
      'fr': 'Aucun trésor culturel ne correspond encore à ta recherche.',
    },
    AppText.archiveResultsLabel: {
      'en': 'cultural treasures',
      'fr': 'trésors culturels',
    },
    AppText.archiveApprovalLabel: {
      'en': 'Community approval',
      'fr': 'Approbation de la communauté',
    },
    AppText.archiveThresholdLabel: {
      'en': 'Archive threshold',
      'fr': "Seuil d'archive",
    },
    AppText.exploreTab: {'en': 'Explore', 'fr': 'Explorer'},
    AppText.profileTab: {'en': 'Profile', 'fr': 'Profil'},
    AppText.keepWatching: {'en': 'Keep watching', 'fr': 'Continuer'},
    AppText.browseCommunities: {
      'en': 'Discover Amazigh communities',
      'fr': 'Découvre les communautés amazighes',
    },
    AppText.discoverArchive: {
      'en': 'Explore the cultural archive',
      'fr': "Explore l'archive culturelle",
    },
    AppText.likeAction: {'en': 'Respect', 'fr': 'Respect'},
    AppText.commentAction: {'en': 'Discuss', 'fr': 'Discuter'},
    AppText.shareAction: {'en': 'Share', 'fr': 'Partager'},
    AppText.followAction: {'en': 'Follow', 'fr': 'Suivre'},
    AppText.followingLabel: {'en': 'Following', 'fr': 'Suivi'},
    AppText.viewProfile: {'en': 'View profile', 'fr': 'Voir le profil'},
    AppText.commonClose: {'en': 'Close', 'fr': 'Fermer'},
    AppText.commonCancel: {'en': 'Cancel', 'fr': 'Annuler'},
    AppText.commonSend: {'en': 'Send', 'fr': 'Envoyer'},
    AppText.commonRequired: {'en': 'Required', 'fr': 'Requis'},
    AppText.commonInvalidEmail: {
      'en': 'Enter a valid email',
      'fr': 'Saisis un email valide',
    },
    AppText.commonCopied: {'en': 'Copied', 'fr': 'Copié'},
    AppText.languageEnglish: {'en': 'English', 'fr': 'Anglais'},
    AppText.languageFrench: {'en': 'French', 'fr': 'Français'},
    AppText.heritagePill: {'en': 'Heritage', 'fr': 'Patrimoine'},
    AppText.culturePill: {'en': 'Culture', 'fr': 'Culture'},
    AppText.learnMore: {'en': 'Learn more', 'fr': 'En savoir plus'},
    AppText.browseStories: {'en': 'Browse stories', 'fr': 'Voir les histoires'},
    AppText.eventsTitle: {
      'en': 'Upcoming events',
      'fr': 'Événements à venir',
    },
    AppText.eventsSubtitle: {
      'en':
          'Gatherings, festivals, and workshops from Amazigh communities worldwide.',
      'fr':
          'Rencontres, festivals et ateliers des communautés amazighes à travers le monde.',
    },
    AppText.eventsOnlineLabel: {'en': 'Online', 'fr': 'En ligne'},
    AppText.eventsInPersonLabel: {
      'en': 'In person',
      'fr': 'En présentiel',
    },
    AppText.eventsHybridLabel: {'en': 'Hybrid', 'fr': 'Hybride'},
    AppText.createCaptureTitle: {
      'en': 'Capture your story',
      'fr': 'Capture ton histoire',
    },
    AppText.createCaptureClose: {'en': 'Close', 'fr': 'Fermer'},
    AppText.createCaptureFlip: {'en': 'Flip camera', 'fr': 'Changer de caméra'},
    AppText.createCaptureFlash: {'en': 'Flash', 'fr': 'Flash'},
    AppText.createCaptureEffects: {'en': 'Effects', 'fr': 'Effets'},
    AppText.createCaptureMusic: {
      'en': 'Music library',
      'fr': 'Bibliothèque musicale',
    },
    AppText.createCaptureTapRecord: {
      'en': 'Tap to record',
      'fr': 'Appuie pour enregistrer',
    },
    AppText.createCaptureTapStop: {
      'en': 'Tap to stop',
      'fr': 'Appuie pour arrêter',
    },
    AppText.createCaptureGallery: {'en': 'Gallery', 'fr': 'Galerie'},
    AppText.createCaptureTimer: {'en': 'Timer', 'fr': 'Minuteur'},
    AppText.createCaptureTimerSoon: {
      'en': 'Timer coming soon',
      'fr': 'Minuteur disponible bientôt',
    },
    AppText.createCameraUnavailable: {
      'en': 'Camera unavailable',
      'fr': 'Caméra indisponible',
    },
    AppText.createCameraNotFound: {
      'en': 'No camera found on this device',
      'fr': 'Aucune caméra détectée sur cet appareil',
    },
    AppText.createCameraError: {
      'en': 'Camera error: {error}',
      'fr': 'Erreur caméra : {error}',
    },
    AppText.createCameraSingle: {
      'en': 'Only one camera detected',
      'fr': 'Une seule caméra détectée',
    },
    AppText.createFlashUnavailable: {
      'en': 'Flash unavailable: {error}',
      'fr': 'Flash indisponible : {error}',
    },
    AppText.createRecordingStartFailed: {
      'en': 'Could not start recording: {error}',
      'fr': 'Impossible de démarrer l’enregistrement : {error}',
    },
    AppText.createRecordingFailed: {
      'en': 'Recording failed: {error}',
      'fr': 'Enregistrement échoué : {error}',
    },
    AppText.createMusicSuggestionsTitle: {
      'en': 'Try these vibes',
      'fr': 'Essaie ces ambiances',
    },
    AppText.createMusicNoTrackSelected: {
      'en': 'No track selected',
      'fr': 'Aucune piste sélectionnée',
    },
    AppText.createReviewPlaceholder: {
      'en': 'Pick or record a clip',
      'fr': 'Choisis ou enregistre un clip',
    },
    AppText.createBackToCamera: {
      'en': 'Back to camera',
      'fr': 'Retour à la caméra',
    },
    AppText.createChangeTrack: {'en': 'Change track', 'fr': 'Changer de piste'},
    AppText.createReplaceClip: {
      'en': 'Replace clip',
      'fr': 'Remplacer le clip',
    },
    AppText.createPreview: {'en': 'Preview', 'fr': 'Prévisualiser'},
    AppText.feedCopyLink: {'en': 'Copy link', 'fr': 'Copier le lien'},
    AppText.feedCopyLinkSubtitle: {
      'en': 'Copy media link to share later',
      'fr': 'Copie le lien du média pour le partager plus tard',
    },
    AppText.feedCommentHint: {
      'en': 'Share your thoughts…',
      'fr': 'Partage tes pensées…',
    },
    AppText.feedCommentCancel: {'en': 'Cancel', 'fr': 'Annuler'},
    AppText.feedCommentSend: {'en': 'Send', 'fr': 'Envoyer'},
    AppText.feedAuthRequired: {
      'en': 'Sign in to continue.',
      'fr': 'Connecte-toi pour continuer.',
    },
    AppText.feedSupabaseRequired: {
      'en': 'Connect Supabase to continue.',
      'fr': 'Connecte Supabase pour continuer.',
    },
    AppText.feedPublishDeferred: {
      'en': 'Could not publish story right now. Saved locally instead.',
      'fr':
          'Impossible de publier l’histoire pour le moment. Enregistrée localement.',
    },
    AppText.feedWelcomeSwipe: {
      'en': 'Swipe up to meet creators from the Amazigh world.',
      'fr':
          'Glisse vers le haut pour rencontrer des créateurs du monde amazigh.',
    },
    AppText.feedWelcomeSwipeHandle: {
      'en': 'Swipe up to visit {handle} and more Amazigh creators.',
      'fr':
          'Glisse vers le haut pour découvrir {handle} et d’autres créateurs amazighs.',
    },
    AppText.feedWelcomeTip: {
      'en': 'Tip: tap the + button to share your own diaspora story.',
      'fr':
          'Astuce : appuie sur le bouton + pour partager ton histoire de la diaspora.',
    },
    AppText.feedLinkCopied: {
      'en': 'Link copied to clipboard',
      'fr': 'Lien copié dans le presse-papiers',
    },
    AppText.feedCommentSent: {'en': 'Comment sent', 'fr': 'Commentaire envoyé'},
    AppText.messagesTitle: {'en': 'Messages', 'fr': 'Messages'},
    AppText.messagesSubtitle: {
      'en': 'Stay in sync with your circles.',
      'fr': 'Reste en phase avec tes cercles.',
    },
    AppText.messagesEmpty: {
      'en': 'No conversations yet.',
      'fr': 'Aucune conversation pour le moment.',
    },
    AppText.messagesConnectSupabase: {
      'en': 'Connect Supabase to sync secure threads.',
      'fr': 'Connecte Supabase pour synchroniser des fils sécurisés.',
    },
    AppText.messagesLoading: {
      'en': 'Refreshing conversations...',
      'fr': 'Actualisation des conversations...',
    },
    AppText.messagesOpenHint: {
      'en': 'Open the messaging tray.',
      'fr': 'Ouvre la section messagerie.',
    },
    AppText.messagesRefresh: {
      'en': 'Refresh messages',
      'fr': 'Actualiser les messages',
    },
    AppText.messagesFallbackTitle: {
      'en': 'Community chat',
      'fr': 'Salon communautaire',
    },
    AppText.messagesThreadComingSoon: {
      'en': 'Message threads arrive soon.',
      'fr': 'Les discussions arrivent bientôt.',
    },
    AppText.feedMute: {'en': 'Mute', 'fr': 'Couper le son'},
    AppText.feedUnmute: {'en': 'Unmute', 'fr': 'Activer le son'},
    AppText.onboardingWelcomeTitle: {
      'en': 'Azul! Welcome to Thela',
      'fr': 'Azul ! Bienvenue sur Thela',
    },
    AppText.onboardingWelcomeDescription: {
      'en':
          'We are gathering Amazigh stories, rhythm, and memory. Share where you stand so we can honour your experience.',
      'fr':
          'Nous rassemblons les histoires, les rythmes et la mémoire amazighes. Partage ton point de vue pour que nous honorions ton expérience.',
    },
    AppText.onboardingBegin: {'en': 'Begin', 'fr': 'Commencer'},
    AppText.onboardingIdentityQuestion: {
      'en': 'Do you identify as Amazigh?',
      'fr': 'Te reconnais-tu comme Amazigh ?',
    },
    AppText.onboardingIdentityYes: {
      'en': 'Yes, I am Amazigh',
      'fr': 'Oui, je suis Amazigh',
    },
    AppText.onboardingIdentityNo: {
      'en': 'No, I am an ally',
      'fr': 'Non, je suis allié·e',
    },
    AppText.onboardingCountryQuestion: {
      'en': 'Which territory reflects your Amazigh roots?',
      'fr': 'Quel territoire reflète tes racines amazighes ?',
    },
    AppText.onboardingFamilyQuestion: {
      'en': 'Which Amazigh cultural family do you connect with most?',
      'fr':
          'Avec quelle famille culturelle amazighe te sens-tu le plus lié·e ?',
    },
    AppText.onboardingInterestQuestion: {
      'en': 'Are you interested in Amazigh culture?',
      'fr': 'Es-tu intéressé·e par la culture amazighe ?',
    },
    AppText.onboardingInterestYes: {
      'en': 'Yes, I want to learn and uplift',
      'fr': 'Oui, je veux apprendre et soutenir',
    },
    AppText.onboardingInterestNo: {
      'en': 'Not right now',
      'fr': 'Pas pour le moment',
    },
    AppText.onboardingDiscoveryQuestion: {
      'en': 'Where did you learn about the Amazigh people?',
      'fr': 'Où as-tu découvert le peuple amazigh ?',
    },
    AppText.onboardingDiscoveryHint: {
      'en': 'Share the story, person, or moment that introduced you to us.',
      'fr':
          'Partage l’histoire, la personne ou le moment qui t’a présenté notre culture.',
    },
    AppText.onboardingSummaryTitle: {
      'en': 'Tanemmirt! Your path is noted.',
      'fr': 'Tanemmirt ! Ton chemin est noté.',
    },
    AppText.onboardingSummaryCountry: {
      'en': 'Rooted in {country} as part of the Amazigh family.',
      'fr': 'Ancré·e en {country} au sein de la famille amazighe.',
    },
    AppText.onboardingSummaryFamily: {
      'en': 'Connected most with {family}.',
      'fr': 'Lié·e surtout à {family}.',
    },
    AppText.onboardingSummaryAllyEager: {
      'en': 'Joining as an ally who is eager to learn.',
      'fr': 'Tu rejoins la communauté comme allié·e curieux·se d’apprendre.',
    },
    AppText.onboardingSummaryAllyGentle: {
      'en': 'Visiting as an ally. We\'ll keep sharing gentle introductions.',
      'fr':
          'Tu visites en tant qu’allié·e. Nous continuerons à partager des introductions douces.',
    },
    AppText.onboardingSummaryDiscovery: {
      'en': 'Discovered Amazigh culture via: "{source}".',
      'fr': 'Tu as découvert la culture amazighe grâce à : « {source} ».',
    },
    AppText.onboardingSummaryEmpty: {
      'en':
          'We are honoured you\'re here. Explore Thela and discover new Amazigh stories.',
      'fr':
          'Nous sommes honorés de t’accueillir. Explore Thela et découvre de nouvelles histoires amazighes.',
    },
    AppText.onboardingContinue: {'en': 'Continue', 'fr': 'Continuer'},
    AppText.onboardingSkip: {'en': 'Skip', 'fr': 'Passer'},
    AppText.onboardingEnter: {'en': 'Enter Thela', 'fr': 'Entrer sur Thela'},
    AppText.createStoryTitle: {
      'en': 'Create new story',
      'fr': 'Créer une nouvelle histoire',
    },
    AppText.createStoryPublish: {'en': 'Publish', 'fr': 'Publier'},
    AppText.createStoryDetails: {'en': 'Details', 'fr': 'Détails'},
    AppText.createStoryTitleEn: {
      'en': 'Title (English)',
      'fr': 'Titre (anglais)',
    },
    AppText.createStoryTitleFrOptional: {
      'en': 'Title (French, optional)',
      'fr': 'Titre (français, optionnel)',
    },
    AppText.createStoryDescriptionEn: {
      'en': 'Description (English)',
      'fr': 'Description (anglais)',
    },
    AppText.createStoryDescriptionFrOptional: {
      'en': 'Description (French, optional)',
      'fr': 'Description (français, optionnel)',
    },
    AppText.createStoryLocationEnOptional: {
      'en': 'Location (English, optional)',
      'fr': 'Lieu (anglais, optionnel)',
    },
    AppText.createStoryLocationFrOptional: {
      'en': 'Location (French, optional)',
      'fr': 'Lieu (français, optionnel)',
    },
    AppText.createStoryCreatorNameEn: {
      'en': 'Creator name (English)',
      'fr': 'Nom du créateur ou de la créatrice (anglais)',
    },
    AppText.createStoryCreatorNameFrOptional: {
      'en': 'Creator name (French, optional)',
      'fr': 'Nom du créateur ou de la créatrice (français, optionnel)',
    },
    AppText.createStoryCreatorHandle: {
      'en': 'Creator handle',
      'fr': 'Pseudo du créateur ou de la créatrice',
    },
    AppText.createStoryHandleError: {
      'en': 'Handle cannot be empty',
      'fr': 'Le pseudo ne peut pas être vide',
    },
    AppText.createStoryMusicLibrary: {
      'en': 'Music from Thela library',
      'fr': 'Musique de la bibliothèque Thela',
    },
    AppText.createStoryNoTrack: {'en': 'No track', 'fr': 'Aucun morceau'},
    AppText.createStoryVisual: {
      'en': 'Visual treatment',
      'fr': 'Traitement visuel',
    },
    AppText.createStoryEffects: {'en': 'Effects', 'fr': 'Effets'},
    AppText.createStoryFieldRequired: {
      'en': 'Please fill this field',
      'fr': 'Merci de renseigner ce champ',
    },
    AppText.createStorySelectVideoFirst: {
      'en': 'Select or capture a video first.',
      'fr': 'Sélectionne ou capture une vidéo avant de continuer.',
    },
    AppText.createStoryDefaultLocationEn: {
      'en': 'Amazigh lands',
      'fr': 'Terres amazighes',
    },
    AppText.createStoryDefaultLocationFr: {
      'en': 'Terres amazighes',
      'fr': 'Terres amazighes',
    },
    AppText.createStoryPublishError: {
      'en': 'Could not publish story: {error}',
      'fr': 'Impossible de publier l’histoire : {error}',
    },
    AppText.createStoryChooseFromLibrary: {
      'en': 'Choose from library',
      'fr': 'Choisir depuis la galerie',
    },
    AppText.createStoryRecordWithCamera: {
      'en': 'Record with camera',
      'fr': 'Filmer avec l’appareil photo',
    },
    AppText.createStoryRecordAgain: {
      'en': 'Record again',
      'fr': 'Filmer à nouveau',
    },
    AppText.createStoryVideoSelectionError: {
      'en': 'Video selection failed: {error}',
      'fr': 'La sélection vidéo a échoué : {error}',
    },
    AppText.createStoryRemoveVideo: {
      'en': 'Remove video',
      'fr': 'Retirer la vidéo',
    },
    AppText.createStoryReplaceClip: {
      'en': 'Replace clip',
      'fr': 'Remplacer le clip',
    },
    AppText.createStoryTapToAddVideo: {
      'en': 'Tap to add a vertical video',
      'fr': 'Appuie pour ajouter une vidéo verticale',
    },
    AppText.createStoryPublishing: {'en': 'Publishing…', 'fr': 'Publication…'},
    AppText.createStoryPublishStory: {
      'en': 'Publish story',
      'fr': 'Publier l’histoire',
    },
    AppText.createStorySavedLocally: {
      'en': 'Story saved locally.',
      'fr': 'Histoire enregistrée localement.',
    },
    AppText.musicTitle: {
      'en': 'Thela Soundscapes',
      'fr': 'Paysages sonores Thela',
    },
    AppText.musicSubtitle: {
      'en': 'Live pulses from Amazigh music and voices',
      'fr': 'Vibrations en direct de la musique et des voix amazighes',
    },
    AppText.musicPlayTrack: {'en': 'Play', 'fr': 'Lire'},
    AppText.musicPauseTrack: {'en': 'Pause', 'fr': 'Pause'},
    AppText.musicNowPlaying: {'en': 'Now playing', 'fr': 'Lecture en cours'},
    AppText.musicLoading: {
      'en': 'Loading track…',
      'fr': 'Chargement du morceau…',
    },
    AppText.musicError: {
      'en': 'Unable to play track right now.',
      'fr': 'Lecture impossible pour le moment.',
    },
    AppText.languageDescription: {
      'en':
          'Choose the language for menus and cultural notes. Change takes effect instantly.',
      'fr':
          'Choisis la langue des menus et des notes culturelles. Le changement est immédiat.',
    },
    AppText.languageEnglishSubtitle: {
      'en': 'Keep the interface and stories in English.',
      'fr': 'Conserve l’interface et les récits en anglais.',
    },
    AppText.languageFrenchTitle: {'en': 'Français', 'fr': 'Français'},
    AppText.languageFrenchSubtitle: {
      'en': 'Menus and stories translated into French.',
      'fr': 'Menus et récits traduits en français.',
    },
    AppText.languageTitle: {'en': 'Language', 'fr': 'Langue'},
    AppText.rightsTitle: {'en': 'Rights & safety', 'fr': 'Droits et sécurité'},
    AppText.rightsIntro: {
      'en':
          'We honour Amazigh creators and safeguard cultural guardianship. Use this form to request removal of content you own or that harms your community.',
      'fr':
          'Nous honorons les créateurs et créatrices amazighes et protégeons la gouvernance culturelle. Utilise ce formulaire pour demander le retrait d’un contenu qui t’appartient ou qui nuit à ta communauté.',
    },
    AppText.rightsBeforeTitle: {
      'en': 'Before you submit',
      'fr': 'Avant d’envoyer',
    },
    AppText.rightsBeforeItem1: {
      'en':
          'Review the content on Thela and confirm it infringes your rights or community protocols.',
      'fr':
          'Vérifie le contenu sur Thela et confirme qu’il enfreint tes droits ou les protocoles de ta communauté.',
    },
    AppText.rightsBeforeItem2: {
      'en':
          'Gather links (URLs) to the exact stories, music, or posts you want removed.',
      'fr':
          'Rassemble les liens (URL) des histoires, musiques ou posts à retirer.',
    },
    AppText.rightsBeforeItem3: {
      'en':
          'If you represent a cultural guardian group, identify the collective and provide contact details.',
      'fr':
          'Si tu représentes un collectif gardien, identifie le groupe et fournis des coordonnées.',
    },
    AppText.rightsSendTitle: {
      'en': 'Send your takedown request',
      'fr': 'Envoyer ta demande de retrait',
    },
    AppText.rightsSendItem1: {
      'en': 'Email: rights@thela.culture',
      'fr': 'Courriel : rights@thela.culture',
    },
    AppText.rightsSendItem2: {
      'en': 'Subject line: COPYRIGHT TAKEDOWN - [Your Name / Collective]',
      'fr': 'Objet : COPYRIGHT TAKEDOWN - [Ton nom / Collectif]',
    },
    AppText.rightsSendItem3: {
      'en':
          'Include: Full name, organisation (if any), contact email, phone (optional).',
      'fr':
          'Inclure : nom complet, organisation (le cas échéant), courriel et téléphone (optionnel).',
    },
    AppText.rightsSendItem4: {
      'en': 'Provide ownership proof or cultural stewardship context.',
      'fr':
          'Fournis une preuve de titularité ou le contexte de stewardship culturel.',
    },
    AppText.rightsSendItem5: {
      'en':
          'List each infringing link and describe why it violates your rights or protocols.',
      'fr':
          'Liste chaque lien en cause et décris pourquoi il enfreint tes droits ou protocoles.',
    },
    AppText.rightsNextTitle: {
      'en': 'What happens next',
      'fr': 'Suite du processus',
    },
    AppText.rightsNextItem1: {
      'en': 'We acknowledge your request within 48 hours.',
      'fr': 'Nous accusons réception de ta demande sous 48 heures.',
    },
    AppText.rightsNextItem2: {
      'en':
          'Our cultural review circle evaluates the claim and may contact you for verification.',
      'fr':
          'Notre cercle de revue culturelle évalue la demande et peut te contacter pour vérification.',
    },
    AppText.rightsNextItem3: {
      'en':
          'If validated, the content is removed or age-restricted and noted in the cultural registry.',
      'fr':
          'Si la demande est validée, le contenu est retiré ou restreint et enregistré dans le registre culturel.',
    },
    AppText.rightsNextItem4: {
      'en':
          'We notify the uploader with anonymised details unless you request otherwise.',
      'fr':
          'Nous informons la personne qui a publié, avec des détails anonymisés sauf avis contraire.',
    },
    AppText.rightsEmergencyTitle: {
      'en': 'Emergency contact',
      'fr': 'Contact d’urgence',
    },
    AppText.rightsEmergencyDescription: {
      'en':
          'If the content presents immediate harm or contains sacred knowledge, email urgent@thela.culture with "EMERGENCY" in the subject. We will prioritise the review.',
      'fr':
          'Si le contenu cause un préjudice immédiat ou contient un savoir sacré, écris à urgent@thela.culture avec « EMERGENCY » dans l’objet. Nous prioriserons la revue.',
    },
    AppText.rightsOpenAccount: {
      'en': 'Open account settings',
      'fr': 'Ouvrir les paramètres du compte',
    },
    AppText.communitySupabaseRequired: {
      'en': 'Connect Supabase to send a request.',
      'fr': 'Connecte Supabase pour envoyer une demande.',
    },
    AppText.communityHostSuccess: {
      'en': 'Thanks! We will be in touch soon.',
      'fr': 'Tanemmirt ! Nous te recontacterons très vite.',
    },
    AppText.communityHostFailure: {
      'en': 'Could not send the request right now.',
      'fr': 'Impossible d’envoyer la demande pour le moment.',
    },
    AppText.communityEmpty: {
      'en': 'No community profiles yet.',
      'fr': 'Aucun profil de communauté pour le moment.',
    },
    AppText.communityHostAction: {
      'en': 'Host a circle',
      'fr': 'Organiser un cercle',
    },
    AppText.communityMembersLabel: {'en': 'members', 'fr': 'membres'},
    AppText.communityLanguagesLabel: {'en': 'Languages', 'fr': 'Langues'},
    AppText.communityFocusLabel: {'en': 'Focus areas', 'fr': 'Axes d’action'},
    AppText.communityHostIntro: {
      'en': 'Share a few details and we’ll reach out with next steps.',
      'fr': 'Partage quelques détails et nous reviendrons vers toi.',
    },
    AppText.communityHostName: {'en': 'Name', 'fr': 'Nom'},
    AppText.communityHostEmail: {'en': 'Email', 'fr': 'Email'},
    AppText.communityHostMessage: {
      'en': 'What would you like to host?',
      'fr': 'Que souhaites-tu organiser ?',
    },
    AppText.communityHostInvalidEmail: {
      'en': 'Enter a valid email',
      'fr': 'Saisis un email valide',
    },
  };
}
