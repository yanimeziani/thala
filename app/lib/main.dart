import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/home_shell.dart';
import 'controllers/auth_controller.dart';
import 'controllers/localization_controller.dart';
import 'features/auth/email_password_login_page.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'l10n/app_translations.dart';
import 'models/onboarding_answers.dart';
import 'services/preference_store.dart';
import 'services/recommendation_service.dart';
import 'services/supabase_manager.dart';
import 'ui/widgets/thala_snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThalaBootstrap());
}

class ThalaBootstrap extends StatefulWidget {
  const ThalaBootstrap({super.key});

  @override
  State<ThalaBootstrap> createState() => _ThalaBootstrapState();
}

class _ThalaBootstrapState extends State<ThalaBootstrap> {
  late final Future<void> _initialization = SupabaseManager.ensureInitialized();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const ThalaRoot();
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildThalaLightTheme(),
            darkTheme: buildThalaDarkTheme(),
            themeMode: ThemeMode.system,
            home: Builder(
              builder: (context) {
                final palette = context.thalaPalette;
                final textTheme = Theme.of(context).textTheme;
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Unable to reach Supabase. Check your credentials or network and restart the app.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildThalaLightTheme(),
          darkTheme: buildThalaDarkTheme(),
          themeMode: ThemeMode.system,
          home: Builder(
            builder: (context) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
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
        Provider(create: (_) => PreferenceStore()),
        Provider(
          create: (context) => RecommendationService(
            preferenceStore: context.read<PreferenceStore>(),
          ),
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

  @override
  void initState() {
    super.initState();
    _restoreOnboardingState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    switch (auth.status) {
      case AuthStatus.loading:
        return const _AuthLoadingView();
      case AuthStatus.unavailable:
        return const _AuthUnavailableView();
      case AuthStatus.unauthenticated:
        return const EmailPasswordLoginPage();
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _AuthUnavailableView extends StatelessWidget {
  const _AuthUnavailableView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Remote login is disabled. Provide Supabase credentials (SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY) using --dart-define to enable sign-in.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
