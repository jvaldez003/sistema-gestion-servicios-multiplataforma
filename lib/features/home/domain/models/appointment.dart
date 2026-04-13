import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String? id;
  final String userId;
  final String businessId;
  final String businessName;
  final List<String> serviceIds;
  final List<String> serviceNames;
  final double totalPrice;
  final DateTime dateTime;
  final String professionalId;
  final String professionalName;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;

  Appointment({
    this.id,
    required this.userId,
    required this.businessId,
    required this.businessName,
    required this.serviceIds,
    required this.serviceNames,
    required this.totalPrice,
    required this.dateTime,
    required this.professionalId,
    required this.professionalName,
    this.status = 'pending',
    required this.createdAt,
  });

  factory Appointment.fromMap(Map<String, dynamic> map, String id) {
    return Appointment(
      id: id,
      userId: map['userId'] ?? '',
      businessId: map['businessId'] ?? '',
      businessName: map['businessName'] ?? '',
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
      serviceNames: List<String>.from(map['serviceNames'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      professionalId: map['professionalId'] ?? '',
      professionalName: map['professionalName'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessId': businessId,
      'businessName': businessName,
      'serviceIds': serviceIds,
      'serviceNames': serviceNames,
      'totalPrice': totalPrice,
      'dateTime': Timestamp.fromDate(dateTime),
      'professionalId': professionalId,
      'professionalName': professionalName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
