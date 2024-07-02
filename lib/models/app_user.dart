class AppUser {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String? profileImageUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
