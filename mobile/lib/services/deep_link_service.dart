import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Service to handle deep links and universal links
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService _instance = DeepLinkService._();
  static DeepLinkService get instance => _instance;

  final AppLinks _appLinks = AppLinks();
  final StreamController<Uri> _linkStreamController = StreamController<Uri>.broadcast();

  Stream<Uri> get linkStream => _linkStreamController.stream;
  StreamSubscription<Uri>? _subscription;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Get the initial link that opened the app
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _linkStreamController.add(initialUri);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get initial link: $e');
      }
    }

    // Listen to link updates while app is running
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _linkStreamController.add(uri);
      },
      onError: (err) {
        if (kDebugMode) {
          debugPrint('Deep link error: $err');
        }
      },
    );
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _linkStreamController.close();
  }

  /// Parse a deep link URI and extract route information
  static DeepLinkRoute? parseUri(Uri uri) {
    // Handle both https://thala.app/... and app.thala://... schemes
    if (uri.scheme != 'https' && uri.scheme != 'app.thala') {
      return null;
    }

    if (uri.scheme == 'https' && uri.host != 'thala.app') {
      return null;
    }

    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      return null;
    }

    // Parse different route types
    switch (pathSegments[0]) {
      case 'events':
      case 'event':
        if (pathSegments.length >= 2) {
          return DeepLinkRoute(
            type: DeepLinkType.event,
            id: pathSegments[1],
          );
        }
        break;

      case 'profile':
      case 'u':
        if (pathSegments.length >= 2) {
          return DeepLinkRoute(
            type: DeepLinkType.profile,
            id: pathSegments[1],
          );
        }
        break;

      case 'video':
      case 'v':
        if (pathSegments.length >= 2) {
          return DeepLinkRoute(
            type: DeepLinkType.video,
            id: pathSegments[1],
          );
        }
        break;

      case 'community':
      case 'c':
        if (pathSegments.length >= 2) {
          return DeepLinkRoute(
            type: DeepLinkType.community,
            id: pathSegments[1],
          );
        }
        break;
    }

    return null;
  }
}

/// Types of deep links supported
enum DeepLinkType {
  event,
  profile,
  video,
  community,
}

/// Parsed deep link route information
class DeepLinkRoute {
  final DeepLinkType type;
  final String id;

  DeepLinkRoute({
    required this.type,
    required this.id,
  });

  @override
  String toString() => 'DeepLinkRoute(type: $type, id: $id)';
}
