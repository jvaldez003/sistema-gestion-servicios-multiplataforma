class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> data) {
    return Review(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuario',
      userPhotoUrl: data['userPhotoUrl'],
      rating: (data['rating'] ?? 5.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };
}
