import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class Booking {
  final String id;
  final String businessId;
  final String businessName;
  final String userId;
  final String userName;
  final String serviceName;
  final double price;
  final DateTime date;
  final String time;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.userId,
    required this.userName,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.time,
    this.status = BookingStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'businessName': businessName,
      'userId': userId,
      'userName': userName,
      'serviceName': serviceName,
      'price': price,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      businessId: map['businessId'] ?? '',
      businessName: map['businessName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
