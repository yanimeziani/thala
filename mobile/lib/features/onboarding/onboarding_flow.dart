import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../l10n/app_translations.dart';
import '../../models/localized_text.dart';
import '../../models/onboarding_answers.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onCompleted});

  final ValueChanged<OnboardingAnswers> onCompleted;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

enum _OnboardingStep {
  intro,
  identity,
  country,
  culturalFamily,
  interest,
  discovery,
  summary,
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with SingleTickerProviderStateMixin {
  final OnboardingAnswers _answers = OnboardingAnswers();
  _OnboardingStep _step = _OnboardingStep.intro;

  ui.FragmentProgram? _program;
  String? _shaderError;
  late final Ticker _ticker;
  double _time = 0;
  final TextEditingController _discoveryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker((elapsed) {
      setState(() => _time = elapsed.inMicroseconds / 1e6);
    })..start();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/splash_intro.frag',
      );
      if (!mounted) return;
      setState(() => _program = program);
    } catch (error) {
      setState(() => _shaderError = error.toString());
    }
  }

  @override
  void dispose() {
    _discoveryController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _ShaderBackground(
              program: _program,
              time: _time,
              error: _shaderError,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _buildStep(context),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _handleSkip,
                  child: Text(
                    AppTranslations.of(context, AppText.onboardingSkip),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _OnboardingStep.intro:
        return _IntroCard(onStart: () => _goTo(_OnboardingStep.identity));
      case _OnboardingStep.identity:
        return _IdentityCard(
          onChoice: (isAmazigh) {
            _answers.isAmazigh = isAmazigh;
            _goTo(
              isAmazigh ? _OnboardingStep.country : _OnboardingStep.interest,
            );
          },
        );
      case _OnboardingStep.country:
        return _CountryCard(
          selected: _answers.country,
          onSelected: (value) => setState(() => _answers.country = value),
          onContinue: () => _goTo(_OnboardingStep.culturalFamily),
        );
      case _OnboardingStep.culturalFamily:
        return _CulturalFamilyCard(
          selected: _answers.culturalFamily,
          onSelected: (value) =>
              setState(() => _answers.culturalFamily = value),
          onContinue: () => _goTo(_OnboardingStep.summary),
        );
      case _OnboardingStep.interest:
        return _InterestCard(
          onChoice: (isInterested) {
            _answers.isInterested = isInterested;
            _goTo(_OnboardingStep.discovery);
          },
        );
      case _OnboardingStep.discovery:
        return _DiscoveryCard(
          controller: _discoveryController,
          onChanged: (value) =>
              setState(() => _answers.discoverySource = value),
          onContinue: () => _goTo(_OnboardingStep.summary),
        );
      case _OnboardingStep.summary:
        return _SummaryCard(
          answers: _answers,
          onFinish: () => widget.onCompleted(_answers),
        );
    }
  }

  void _goTo(_OnboardingStep step) {
    setState(() => _step = step);
  }

  void _handleSkip() {
    widget.onCompleted(_answers.copyWith());
  }
}

class _LocalizedOption {
  const _LocalizedOption({required this.value, required this.label});

  final String value;
  final LocalizedText label;
}

const List<_LocalizedOption> _territoryOptions = <_LocalizedOption>[
  _LocalizedOption(
    value: 'Morocco',
    label: LocalizedText(en: 'Morocco', fr: 'Maroc'),
  ),
  _LocalizedOption(
    value: 'Algeria',
    label: LocalizedText(en: 'Algeria', fr: 'Algérie'),
  ),
  _LocalizedOption(
    value: 'Tunisia',
    label: LocalizedText(en: 'Tunisia', fr: 'Tunisie'),
  ),
  _LocalizedOption(
    value: 'Libya',
    label: LocalizedText(en: 'Libya', fr: 'Libye'),
  ),
  _LocalizedOption(
    value: 'Canary Islands',
    label: LocalizedText(en: 'Canary Islands', fr: 'Îles Canaries'),
  ),
  _LocalizedOption(
    value: 'Mali',
    label: LocalizedText(en: 'Mali', fr: 'Mali'),
  ),
  _LocalizedOption(
    value: 'Niger',
    label: LocalizedText(en: 'Niger', fr: 'Niger'),
  ),
  _LocalizedOption(
    value: 'Diaspora',
    label: LocalizedText(en: 'Diaspora', fr: 'Diaspora'),
  ),
];

const List<_LocalizedOption> _familyOptions = <_LocalizedOption>[
  _LocalizedOption(
    value: 'Kabyle',
    label: LocalizedText(en: 'Kabyle', fr: 'Kabyle'),
  ),
  _LocalizedOption(
    value: 'Rifian',
    label: LocalizedText(en: 'Rifian', fr: 'Rifain'),
  ),
  _LocalizedOption(
    value: 'Shilha / Tashelhit',
    label: LocalizedText(en: 'Shilha / Tashelhit', fr: 'Chleuh / Tashelhit'),
  ),
  _LocalizedOption(
    value: 'Chaoui',
    label: LocalizedText(en: 'Chaoui', fr: 'Chaoui'),
  ),
  _LocalizedOption(
    value: 'Tuareg',
    label: LocalizedText(en: 'Tuareg', fr: 'Touareg'),
  ),
  _LocalizedOption(
    value: 'Zenata',
    label: LocalizedText(en: 'Zenata', fr: 'Zénète'),
  ),
  _LocalizedOption(
    value: 'Mozabite',
    label: LocalizedText(en: 'Mozabite', fr: 'Mozabite'),
  ),
  _LocalizedOption(
    value: 'Other / Mixed',
    label: LocalizedText(en: 'Other / Mixed', fr: 'Autre / Mixte'),
  ),
];

LocalizedText? _labelForOption(List<_LocalizedOption> options, String? value) {
  if (value == null) {
    return null;
  }
  for (final option in options) {
    if (option.value == value) {
      return option.label;
    }
  }
  return null;
}

String _resolveCountryLabel(Locale locale, String? value) {
  final label = _labelForOption(_territoryOptions, value)?.resolve(locale);
  return label ?? value ?? '';
}

String _resolveFamilyLabel(Locale locale, String? value) {
  final label = _labelForOption(_familyOptions, value)?.resolve(locale);
  return label ?? value ?? '';
}

class _ShaderBackground extends StatelessWidget {
  const _ShaderBackground({
    required this.program,
    required this.time,
    required this.error,
  });

  final ui.FragmentProgram? program;
  final double time;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (program == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF182740), Color(0xFF05060A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: error == null
            ? const CircularProgressIndicator(color: Colors.white70)
            : Text(error!, style: const TextStyle(color: Colors.white70)),
      );
    }

    return RepaintBoundary(
      child: CustomPaint(painter: _SplashPainter(program!, time)),
    );
  }
}

class _SplashPainter extends CustomPainter {
  _SplashPainter(this.program, this.time);

  final ui.FragmentProgram program;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time);
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final title = AppTranslations.of(context, AppText.onboardingWelcomeTitle);
    final body = AppTranslations.of(
      context,
      AppText.onboardingWelcomeDescription,
    );
    final begin = AppTranslations.of(context, AppText.onboardingBegin);
    return _CardShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ⵀ',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(begin),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.onChoice});

  final ValueChanged<bool> onChoice;

  @override
  Widget build(BuildContext context) {
    final question = AppTranslations.of(
      context,
      AppText.onboardingIdentityQuestion,
    );
    final yesLabel = AppTranslations.of(context, AppText.onboardingIdentityYes);
    final noLabel = AppTranslations.of(context, AppText.onboardingIdentityNo);
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _ChoiceButtons(
            yesLabel: yesLabel,
            noLabel: noLabel,
            onChoice: onChoice,
          ),
        ],
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  const _CountryCard({
    required this.selected,
    required this.onSelected,
    required this.onContinue,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final question = AppTranslations.of(
      context,
      AppText.onboardingCountryQuestion,
    );
    final continueLabel = AppTranslations.of(
      context,
      AppText.onboardingContinue,
    );
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _territoryOptions.map((option) {
              final isSelected = option.value == selected;
              return ChoiceChip(
                label: Text(option.label.resolve(locale)),
                selected: isSelected,
                onSelected: (_) => onSelected(option.value),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: Colors.orangeAccent,
                backgroundColor: Colors.white12,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: selected == null ? null : onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(continueLabel),
          ),
        ],
      ),
    );
  }
}

class _CulturalFamilyCard extends StatelessWidget {
  const _CulturalFamilyCard({
    required this.selected,
    required this.onSelected,
    required this.onContinue,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final question = AppTranslations.of(
      context,
      AppText.onboardingFamilyQuestion,
    );
    final continueLabel = AppTranslations.of(
      context,
      AppText.onboardingContinue,
    );
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _familyOptions.map((option) {
              final isSelected = option.value == selected;
              return ChoiceChip(
                label: Text(option.label.resolve(locale)),
                selected: isSelected,
                onSelected: (_) => onSelected(option.value),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: Colors.orangeAccent,
                backgroundColor: Colors.white12,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: selected == null ? null : onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(continueLabel),
          ),
        ],
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.onChoice});

  final ValueChanged<bool> onChoice;

  @override
  Widget build(BuildContext context) {
    final question = AppTranslations.of(
      context,
      AppText.onboardingInterestQuestion,
    );
    final yesLabel = AppTranslations.of(context, AppText.onboardingInterestYes);
    final noLabel = AppTranslations.of(context, AppText.onboardingInterestNo);
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _ChoiceButtons(
            yesLabel: yesLabel,
            noLabel: noLabel,
            onChoice: onChoice,
          ),
        ],
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.controller,
    required this.onChanged,
    required this.onContinue,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final question = AppTranslations.of(
      context,
      AppText.onboardingDiscoveryQuestion,
    );
    final hint = AppTranslations.of(context, AppText.onboardingDiscoveryHint);
    final continueLabel = AppTranslations.of(
      context,
      AppText.onboardingContinue,
    );
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white12,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: controller.text.trim().isEmpty
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    onContinue();
                  },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(continueLabel),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.answers, required this.onFinish});

  final OnboardingAnswers answers;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final items = <String>[];

    if (answers.isAmazigh == true) {
      final template = AppTranslations.of(
        context,
        AppText.onboardingSummaryCountry,
      );
      final countryLabel = _resolveCountryLabel(locale, answers.country);
      items.add(template.replaceFirst('{country}', countryLabel));
    }

    if (answers.culturalFamily != null && answers.culturalFamily!.isNotEmpty) {
      final template = AppTranslations.of(
        context,
        AppText.onboardingSummaryFamily,
      );
      final familyLabel = _resolveFamilyLabel(locale, answers.culturalFamily);
      items.add(template.replaceFirst('{family}', familyLabel));
    }

    if (answers.isAmazigh == false && answers.isInterested != null) {
      final key = answers.isInterested == true
          ? AppText.onboardingSummaryAllyEager
          : AppText.onboardingSummaryAllyGentle;
      items.add(AppTranslations.of(context, key));
    }

    final source = answers.discoverySource?.trim();
    if (source != null && source.isNotEmpty) {
      final template = AppTranslations.of(
        context,
        AppText.onboardingSummaryDiscovery,
      );
      items.add(template.replaceFirst('{source}', source));
    }

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppTranslations.of(context, AppText.onboardingSummaryTitle),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            Text(
              AppTranslations.of(context, AppText.onboardingSummaryEmpty),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: onFinish,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(AppTranslations.of(context, AppText.onboardingEnter)),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButtons extends StatelessWidget {
  const _ChoiceButtons({
    required this.yesLabel,
    required this.noLabel,
    required this.onChoice,
  });

  final String yesLabel;
  final String noLabel;
  final ValueChanged<bool> onChoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => onChoice(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(yesLabel),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => onChoice(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(noLabel),
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        child: child,
      ),
    );
  }
}
