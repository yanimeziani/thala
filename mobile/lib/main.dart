import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/home_shell.dart';
import 'controllers/auth_controller.dart';
import 'controllers/events_controller.dart';
import 'controllers/localization_controller.dart';
import 'controllers/music_library.dart';
import 'data/events_repository.dart';
import 'features/auth/google_login_page.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/splash/splash_page.dart';
import 'l10n/app_translations.dart';
import 'models/onboarding_answers.dart';
import 'data/sample_tracks.dart';
import 'services/deep_link_service.dart';
import 'services/meili_search_manager.dart';
import 'services/preference_store.dart';
import 'services/recommendation_service.dart';
import 'ui/widgets/thala_snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize deep linking
  await DeepLinkService.instance.initialize();

  runApp(const ThalaBootstrap());
}

class ThalaBootstrap extends StatefulWidget {
  const ThalaBootstrap({super.key});

  @override
  State<ThalaBootstrap> createState() => _ThalaBootstrapState();
}

class _ThalaBootstrapState extends State<ThalaBootstrap> {
  late final Future<void> _initialization = _initialize();

  Future<void> _initialize() async {
    // Initialize optional services
    await MeiliSearchManager.ensureInitialized();

    // Add a small delay for splash screen visibility
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const ThalaRoot();
        }

        // Show splash screen while initializing
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildThalaLightTheme(),
          darkTheme: buildThalaDarkTheme(),
          themeMode: ThemeMode.system,
          home: const SplashPage(),
        );
      },
    );
  }
}

class ThalaRoot extends StatelessWidget {
  const ThalaRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final controller = LocalizationController(
              initialLocale: deviceLocale,
            );
            controller.loadPreferredLocale();
            return controller;
          },
        ),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
          create: (_) => MusicLibrary(fallback: sampleTracks),
        ),
        Provider(create: (_) => PreferenceStore()),
        Provider(
          create: (context) => RecommendationService(
            preferenceStore: context.read<PreferenceStore>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthController, EventsController>(
          create: (context) {
            final auth = context.read<AuthController>();
            return EventsController(
              repository: EventsRepository(accessToken: auth.accessToken),
            );
          },
          update: (context, auth, previous) {
            return EventsController(
              repository: EventsRepository(accessToken: auth.accessToken),
            );
          },
        ),
      ],
      child: const ThalaApp(),
    );
  }
}

class ThalaApp extends StatelessWidget {
  const ThalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thala',
      theme: buildThalaLightTheme(),
      darkTheme: buildThalaDarkTheme(),
      themeMode: ThemeMode.system,
      locale: localization.locale,
      supportedLocales: LocalizationController.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
      onGenerateTitle: (context) =>
          AppTranslations.of(context, AppText.appName),
      builder: (context, child) {
        final content = Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );

        return content;
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showOnboarding = false;
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _restoreOnboardingState();
    _setupDeepLinkListener();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _setupDeepLinkListener() {
    _deepLinkSubscription = DeepLinkService.instance.linkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    final route = DeepLinkService.parseUri(uri);
    if (route == null) return;

    // Handle different deep link types
    // TODO: Navigate to appropriate screens based on route.type and route.id
    if (kDebugMode) {
      debugPrint('Deep link received: $route');
    }

    // For now, just log the deep link
    // In a full implementation, you would navigate to the appropriate screen
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    switch (auth.status) {
      case AuthStatus.loading:
        return const _AuthLoadingView();
      case AuthStatus.unauthenticated:
        return const GoogleLoginPage();
      case AuthStatus.authenticated:
      case AuthStatus.guest:
        return Stack(
          children: [
            const HomeShell(),
            if (_showOnboarding)
              OnboardingFlow(
                onCompleted: (answers) {
                  final recommendationService = context
                      .read<RecommendationService>();
                  unawaited(
                    recommendationService.saveOnboardingAnswers(answers),
                  );
                  setState(() {
                    _showOnboarding = false;
                  });
                  _announceWelcome(context, answers);
                },
              ),
          ],
        );
    }
  }

  void _announceWelcome(BuildContext context, OnboardingAnswers answers) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }
      final message = _buildMessage(answers);
      messenger.showSnackBar(
        buildThalaSnackBar(
          context,
          icon: Icons.waving_hand,
          badgeColor: context.thalaPalette.surfaceStrong.withValues(
            alpha: 0.65,
          ),
          semanticsLabel: message,
        ),
      );
    });
  }

  String _buildMessage(OnboardingAnswers answers) {
    if (answers.isAmazigh == true) {
      final country = answers.country ?? 'Amazigh homelands';
      return 'Tanemmirt! Stories from $country are waiting for you.';
    }
    if (answers.isInterested == true) {
      return 'Tanemmirt! Explore and learn with the Amazigh community.';
    }
    return 'Welcome to Thala. Discover Amazigh culture at your own rhythm.';
  }

  Future<void> _restoreOnboardingState() async {
    final recommendationService = context.read<RecommendationService>();
    final storedAnswers = await recommendationService.loadOnboardingAnswers();
    if (!mounted) return;
    setState(() {
      _showOnboarding = storedAnswers == null;
    });
  }
}

class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SplashPage();
  }
}
