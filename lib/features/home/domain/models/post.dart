import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessPost {
  final String id;
  final String businessId;
  final String businessName;
  final String businessAvatar;
  final String? title;
  final String content;
  final String? imageUrl;
  final String? serviceId;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final List<String> likedByUsers;

  BusinessPost({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.businessAvatar,
    this.title,
    required this.content,
    this.imageUrl,
    this.serviceId,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.likedByUsers = const [],
  });

  factory BusinessPost.fromMap(String id, Map<String, dynamic> map, {String? businessName, String? businessAvatar}) {
    return BusinessPost(
      id: id,
      businessId: map['businessId'] ?? '',
      businessName: businessName ?? map['businessName'] ?? 'Negocio',
      businessAvatar: businessAvatar ?? map['businessAvatar'] ?? '',
      title: map['title'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      serviceId: map['serviceId'],
      likesCount: map['likesCount'] ?? (map['likedByUsers'] as List?)?.length ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      likedByUsers: List<String>.from(map['likedByUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'serviceId': serviceId,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'likedByUsers': likedByUsers,
    };
  }

  BusinessPost copyWith({
    int? likesCount,
    int? commentsCount,
    List<String>? likedByUsers,
  }) {
    return BusinessPost(
      id: id,
      businessId: businessId,
      businessName: businessName,
      businessAvatar: businessAvatar,
      title: title,
      content: content,
      imageUrl: imageUrl,
      serviceId: serviceId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      likedByUsers: likedByUsers ?? this.likedByUsers,
    );
  }
}

class PostComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
  });

  factory PostComment.fromMap(String id, Map<String, dynamic> map) {
    return PostComment(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Usuario',
      userAvatar: map['userAvatar'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
