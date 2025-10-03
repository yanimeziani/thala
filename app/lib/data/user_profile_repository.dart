import 'dart:developer' as developer;

import '../models/user_profile.dart';

/// Repository for managing user profiles
/// Currently uses local/sample data since backend integration is not yet implemented
class UserProfileRepository {
  UserProfileRepository();

  bool get isRemoteEnabled => false;

  Future<UserProfile?> refreshProfile({UserProfile? fallback}) async {
    // Backend integration pending - return fallback
    return fallback;
  }

  Future<UserProfile?> saveProfile(UserProfile profile) async {
    // Backend integration pending - save locally
    developer.log(
      'Profile saved locally (backend integration pending)',
      name: 'UserProfileRepository',
    );
    return profile;
  }
}
