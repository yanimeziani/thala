class ContactHandle {
  const ContactHandle({
    required this.handle,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.location,
    this.isVerified = false,
  });

  final String handle;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final bool isVerified;

  factory ContactHandle.fromJson(Map<String, dynamic> json) {
    return ContactHandle(
      handle: json['handle'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['handle'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
