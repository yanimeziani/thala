import 'package:flutter/material.dart';

import '../models/video_effect.dart';

/// Color filter matrices sourced from common LUT-style presets.
const List<double> _warmFilter = <double>[
  1.2,
  -0.05,
  0.0,
  0.0,
  0.0,
  0.0,
  1.1,
  0.0,
  0.0,
  0.0,
  0.0,
  -0.05,
  1.05,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
];

const List<double> _coolFilter = <double>[
  0.95,
  0.0,
  0.05,
  0.0,
  0.0,
  0.0,
  0.95,
  0.05,
  0.0,
  0.0,
  0.0,
  0.0,
  1.15,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
];

const List<double> _noirFilter = <double>[
  0.33,
  0.33,
  0.33,
  0.0,
  0.0,
  0.33,
  0.33,
  0.33,
  0.0,
  0.0,
  0.33,
  0.33,
  0.33,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
];

// Golden Hour - Warm, glowing, Instagram-perfect sunset vibes
const List<double> _goldenHourFilter = <double>[
  1.15,  // More red
  0.1,
  -0.05,
  0.0,
  10.0,  // Brightness lift
  0.05,
  1.08,  // Slightly more green
  0.0,
  0.0,
  8.0,
  -0.1,
  -0.05,
  0.9,   // Less blue for warmth
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
];

// Film Grain - Vintage cinematic with soft contrast
const List<double> _filmGrainFilter = <double>[
  1.05,
  0.02,
  0.0,
  0.0,
  5.0,
  0.02,
  1.03,
  0.02,
  0.0,
  3.0,
  0.0,
  0.02,
  1.05,
  0.0,
  2.0,
  0.0,
  0.0,
  0.0,
  0.98,  // Slightly muted
  0.0,
];

// Velvet - Rich, saturated, luxurious tones
const List<double> _velvetFilter = <double>[
  1.18,
  -0.08,
  0.0,
  0.0,
  -5.0,
  -0.05,
  1.15,
  -0.05,
  0.0,
  0.0,
  0.0,
  -0.08,
  1.12,
  0.0,
  5.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
];

// Crystal - Bright, airy, clean with lifted shadows
const List<double> _crystalFilter = <double>[
  1.08,
  0.0,
  0.0,
  0.0,
  18.0,  // High brightness
  0.0,
  1.06,
  0.0,
  0.0,
  15.0,
  0.0,
  0.0,
  1.1,
  0.0,
  12.0,
  0.0,
  0.0,
  0.0,
  0.96,  // Slightly faded
  0.0,
];

// Ethereal - Dreamy, soft, magical atmosphere
const List<double> _etherealFilter = <double>[
  1.02,
  0.05,
  0.08,
  0.0,
  12.0,
  0.05,
  1.05,
  0.05,
  0.0,
  10.0,
  0.08,
  0.05,
  1.08,
  0.0,
  8.0,
  0.0,
  0.0,
  0.0,
  0.94,  // Soft, faded look
  0.0,
];

final List<VideoEffect> videoEffects = <VideoEffect>[
  VideoEffect(
    id: 'original',
    name: 'Original',
    description: 'Pure, unfiltered beauty.',
  ),
  VideoEffect(
    id: 'golden_hour',
    name: 'Golden Hour',
    description: 'Warm sunset glow that makes everything look magical.',
    filter: const ColorFilter.matrix(_goldenHourFilter),
    overlay: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromRGBO(255, 200, 120, 0.08),
        Colors.transparent,
      ],
    ),
  ),
  VideoEffect(
    id: 'crystal',
    name: 'Crystal',
    description: 'Bright, clean, and airy - perfect for that fresh look.',
    filter: const ColorFilter.matrix(_crystalFilter),
    overlay: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color.fromRGBO(255, 255, 255, 0.12),
        Colors.transparent,
        Color.fromRGBO(200, 230, 255, 0.06),
      ],
    ),
  ),
  VideoEffect(
    id: 'velvet',
    name: 'Velvet',
    description: 'Rich, deep colors with luxurious vibes.',
    filter: const ColorFilter.matrix(_velvetFilter),
  ),
  VideoEffect(
    id: 'film_grain',
    name: 'Film',
    description: 'Vintage cinematic feel with timeless charm.',
    filter: const ColorFilter.matrix(_filmGrainFilter),
    overlay: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromRGBO(40, 35, 30, 0.08),
        Colors.transparent,
        Color.fromRGBO(30, 25, 20, 0.12),
      ],
    ),
  ),
  VideoEffect(
    id: 'ethereal',
    name: 'Ethereal',
    description: 'Soft, dreamy, otherworldly atmosphere.',
    filter: const ColorFilter.matrix(_etherealFilter),
    overlay: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromRGBO(255, 240, 255, 0.1),
        Colors.transparent,
        Color.fromRGBO(220, 230, 255, 0.08),
      ],
    ),
  ),
];

VideoEffect effectForId(String? id) {
  if (id == null) {
    return videoEffects.first;
  }
  return videoEffects.firstWhere(
    (effect) => effect.id == id,
    orElse: () => videoEffects.first,
  );
}
