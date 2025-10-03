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

final List<VideoEffect> videoEffects = <VideoEffect>[
  VideoEffect(
    id: 'original',
    name: 'Original',
    description: 'No additional treatment.',
  ),
  VideoEffect(
    id: 'warm_glow',
    name: 'Warm Glow',
    description: 'Adds golden tones for sunset moods.',
    filter: const ColorFilter.matrix(_warmFilter),
  ),
  VideoEffect(
    id: 'cool_mist',
    name: 'Cool Mist',
    description: 'Soft cyan lift with a gentle haze.',
    filter: const ColorFilter.matrix(_coolFilter),
    overlay: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromRGBO(255, 255, 255, 0.08),
        Colors.transparent,
        Color.fromRGBO(96, 125, 139, 0.1),
      ],
    ),
  ),
  VideoEffect(
    id: 'noir',
    name: 'Noir',
    description: 'High-contrast monochrome.',
    filter: const ColorFilter.matrix(_noirFilter),
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
