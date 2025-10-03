import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    this.displayName,
    this.community,
    this.pronouns,
    this.bio,
  });

  final String userId;
  final String email;
  final String? displayName;
  final String? community;
  final String? pronouns;
  final String? bio;

  static const _displayNameKey = 'full_name';
  static const _communityKey = 'community';
  static const _pronounsKey = 'pronouns';
  static const _bioKey = 'bio';

  factory UserProfile.fromUser(User user, {UserProfile? fallback}) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final displayName = _coalesceString(
      metadata[_displayNameKey],
      fallback?.displayName,
    );
    final community = _coalesceString(
      metadata[_communityKey],
      fallback?.community,
    );
    final pronouns = _coalesceString(
      metadata[_pronounsKey],
      fallback?.pronouns,
    );
    final bio = _coalesceString(metadata[_bioKey], fallback?.bio);

    return UserProfile(
      userId: user.id,
      email: user.email ?? fallback?.email ?? '',
      displayName: displayName,
      community: community,
      pronouns: pronouns,
      bio: bio,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['userId'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      displayName: _coalesceString(json['displayName']),
      community: _coalesceString(json['community']),
      pronouns: _coalesceString(json['pronouns']),
      bio: _coalesceString(json['bio']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'community': community,
      'pronouns': pronouns,
      'bio': bio,
    };
  }

  Map<String, dynamic> toMetadata() {
    final metadata = <String, dynamic>{};
    void put(String key, String? value) {
      if (value == null) {
        metadata[key] = null;
        return;
      }
      final trimmed = value.trim();
      metadata[key] = trimmed.isEmpty ? null : trimmed;
    }

    put(_displayNameKey, displayName);
    put(_communityKey, community);
    put(_pronounsKey, pronouns);
    put(_bioKey, bio);
    return metadata;
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? community,
    String? pronouns,
    String? bio,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      community: community ?? this.community,
      pronouns: pronouns ?? this.pronouns,
      bio: bio ?? this.bio,
    );
  }

  static String? _coalesceString(dynamic value, [String? fallback]) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }
    return null;
  }
}
