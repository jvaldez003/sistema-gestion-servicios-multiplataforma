class Business {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String avatarUrl;
  final double rating;
  final int totalReviews;
  final double distance;
  final double startingPrice;
  final bool isOpen;
  final bool isVerified;
  final bool isTop;
  final String description;
  final List<String> tags;
  final int likes;
  final int comments;
  final int professionalCount;
  final int followerCount;
  final List<String> galleryImages;
  final String? address;
  final String? phone;
  final String? openingHours;

  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.avatarUrl,
    required this.rating,
    required this.totalReviews,
    required this.distance,
    required this.startingPrice,
    this.isOpen = true,
    this.isVerified = false,
    this.isTop = false,
    required this.description,
    required this.tags,
    this.likes = 0,
    this.comments = 0,
    this.professionalCount = 1,
    this.followerCount = 0,
    this.galleryImages = const [],
    this.address,
    this.phone,
    this.openingHours,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Business && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
