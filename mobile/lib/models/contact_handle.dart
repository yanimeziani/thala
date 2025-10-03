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
}
