import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/music_library.dart';
import '../../l10n/app_translations.dart';
import '../../models/music_track.dart';
import '../../ui/widgets/section_header.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../../ui/widgets/thala_snackbar.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  String? _shaderError;
  late final Ticker _ticker;
  double _time = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSession? _audioSession;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _audioError;
  String? _activeTrackId;
  bool _isAudioLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    _configureAudioSession();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMicroseconds / 1e6;
      });
    });
    _ticker.start();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/amazigh_wave.frag',
      );
      if (!mounted) return;
      setState(() => _program = program);
    } catch (error) {
      setState(() => _shaderError = error.toString());
    }
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _audioSession = session;
    } catch (error) {
      debugPrint('Failed to configure audio session: $error');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<MusicLibrary>();
    final tracks = library.tracks;
    String tr(AppText key) => AppTranslations.of(context, key);
    final title = tr(AppText.musicTitle);
    final subtitle = tr(AppText.musicSubtitle);
    final nowPlayingLabel = tr(AppText.musicNowPlaying);
    final loadingLabel = tr(AppText.musicLoading);
    final activeTrack = library.trackById(_activeTrackId);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visualEnergy = _energyFromTime(_time);

    if (library.isLoading && tracks.isEmpty) {
      return const Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tracks.isEmpty) {
      final palette = context.thalaPalette;
      final message = library.error ??
          'No tracks available yet. Add music via Supabase to energise this space.';
      return Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: ThalaPageBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _musicBackgroundGradient(colorScheme),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThalaGlassSurface(
                        enableBorder: false,
                        cornerRadius: 24,
                        backgroundOpacity: theme.brightness == Brightness.dark
                            ? 0.18
                            : 0.48,
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                        child: SectionHeader(
                          leading: const _MusicGlyph(),
                          title: Text(title),
                          subtitle: Text(subtitle),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ThalaGlassSurface(
                        enableBorder: false,
                        cornerRadius: 24,
                        backgroundOpacity: theme.brightness == Brightness.dark
                            ? 0.16
                            : 0.32,
                        padding: const EdgeInsets.all(10),
                        child: _MusicVisualizer(
                          program: _program,
                          shaderError: _shaderError,
                          time: _time,
                          energyLevel: visualEnergy,
                        ),
                      ),
                      if (_activeTrackId != null && activeTrack != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ThalaGlassSurface(
                            enableBorder: false,
                            cornerRadius: 24,
                            backgroundOpacity:
                                theme.brightness == Brightness.dark
                                ? 0.22
                                : 0.42,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.headphones,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isAudioLoading
                                        ? loadingLabel
                                        : '$nowPlayingLabel · ${activeTrack?.title ?? ''}',
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_audioError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _audioError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _TrackTile(
                      track: track,
                      visualEnergy: _energyFromTime(_time + index),
                      isActive: _isTrackActive(track.id),
                      isPlaying: _isTrackPlaying(track.id),
                      isLoading: _isTrackActive(track.id) && _isAudioLoading,
                      onPressed: () => _toggleTrack(track),
                      playLabel: tr(AppText.musicPlayTrack),
                      pauseLabel: tr(AppText.musicPauseTrack),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemCount: tracks.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _energyFromTime(double value) {
    return 0.5 + 0.4 * math.sin(value * 1.3) + 0.1 * math.cos(value * 0.7);
  }

  bool _isTrackActive(String trackId) => _activeTrackId == trackId;

  bool _isTrackPlaying(String trackId) {
    if (!_isTrackActive(trackId)) {
      return false;
    }
    return _audioPlayer.playing;
  }

  Future<void> _toggleTrack(MusicTrack track) async {
    if (_isTrackActive(track.id)) {
      final state = _audioPlayer.processingState;
      if (state == ProcessingState.loading ||
          state == ProcessingState.buffering) {
        return;
      }
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        await _audioSession?.setActive(false);
      } else {
        await _audioSession?.setActive(true);
        await _audioPlayer.play();
      }
      if (mounted) {
        setState(() {});
      }
      return;
    }

    setState(() {
      _isAudioLoading = true;
      _audioError = null;
      _activeTrackId = track.id;
    });

    final previewUrl = track.previewUrl;
    if (previewUrl == null || previewUrl.isEmpty) {
      final message = AppTranslations.of(context, AppText.musicError);
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        buildThalaSnackBar(
          context,
          icon: Icons.music_off,
          iconColor: Theme.of(context).colorScheme.error,
          badgeColor: Theme.of(
            context,
          ).colorScheme.error.withValues(alpha: 0.22),
          semanticsLabel: message,
        ),
      );
      if (mounted) {
        setState(() {
          _audioError = message;
          _isAudioLoading = false;
          _activeTrackId = null;
        });
      }
      return;
    }

    try {
      final uri = Uri.parse(previewUrl);
      await _audioSession?.setActive(true);
      await _audioPlayer.setAudioSource(AudioSource.uri(uri));
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(1);
      await _audioPlayer.play();
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    } catch (error) {
      final message = AppTranslations.of(context, AppText.musicError);
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        buildThalaSnackBar(
          context,
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          badgeColor: Theme.of(
            context,
          ).colorScheme.error.withValues(alpha: 0.24),
          semanticsLabel: message,
        ),
      );
      await _audioPlayer.stop();
      await _audioSession?.setActive(false);
      if (mounted) {
        setState(() {
          _audioError = error.toString();
          _isAudioLoading = false;
          _activeTrackId = null;
        });
      }
    }
  }
}

class _MusicGlyph extends StatelessWidget {
  const _MusicGlyph();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withOpacity(0.14),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.graphic_eq, color: accent, size: 22),
    );
  }
}

class _MusicVisualizer extends StatelessWidget {
  const _MusicVisualizer({
    required this.program,
    required this.shaderError,
    required this.time,
    required this.energyLevel,
  });

  final ui.FragmentProgram? program;
  final String? shaderError;
  final double time;
  final double energyLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 260,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: program != null
            ? RepaintBoundary(
                child: CustomPaint(
                  painter: _VisualizerPainter(
                    program: program!,
                    time: time,
                    energyLevel: energyLevel,
                  ),
                  child: const SizedBox.expand(),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondaryContainer,
                      colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: shaderError == null
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.secondary,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Shader unavailable\n$shaderError',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  _VisualizerPainter({
    required this.program,
    required this.time,
    required this.energyLevel,
  });

  final ui.FragmentProgram program;
  final double time;
  final double energyLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, energyLevel.toDouble());

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.energyLevel != energyLevel;
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.track,
    required this.visualEnergy,
    required this.isActive,
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
    required this.playLabel,
    required this.pauseLabel,
  });

  final MusicTrack track;
  final double visualEnergy;
  final bool isActive;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;
  final String playLabel;
  final String pauseLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalized = (visualEnergy % 1).abs();
    final accent = Color.lerp(
      colorScheme.secondary,
      colorScheme.tertiary,
      normalized,
    )!;

    return ThalaGlassSurface(
      enableBorder: false,
      cornerRadius: 20,
      backgroundOpacity: isActive ? 0.32 : 0.18,
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.network(
                      track.artworkUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.music_note,
                            color: colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        track.artist,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  )
                else
                  IconButton(
                    iconSize: 28,
                    splashRadius: 20,
                    tooltip: isPlaying ? pauseLabel : playLabel,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onPressed();
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: accent,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

LinearGradient _musicBackgroundGradient(ColorScheme scheme) {
  if (scheme.brightness == Brightness.dark) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [scheme.surfaceVariant.withOpacity(0.28), scheme.background],
    );
  }
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [scheme.surfaceVariant.withOpacity(0.55), scheme.background],
  );
}
