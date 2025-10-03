import 'package:flutter/material.dart';

/// Visual preset that can be applied on top of story playback.
class VideoEffect {
  const VideoEffect({
    required this.id,
    required this.name,
    required this.description,
    this.filter,
    this.overlay,
  });

  final String id;
  final String name;
  final String description;
  final ColorFilter? filter;
  final Gradient? overlay;
}
