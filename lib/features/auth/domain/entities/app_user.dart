class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? photoUrl;
  final int points;
  final List<String> favoriteIds;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.photoUrl,
    this.points = 0,
    this.favoriteIds = const [],
  });
}
