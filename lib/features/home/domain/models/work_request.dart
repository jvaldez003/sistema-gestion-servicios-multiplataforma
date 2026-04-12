class WorkRequest {
  final String id;
  final String businessId;
  final String requesterId; // ID del usuario que solicita
  final String requesterName;
  final String requesterAvatar;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  WorkRequest({
    required this.id,
    required this.businessId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterAvatar,
    required this.status,
    required this.createdAt,
  });

  factory WorkRequest.fromMap(Map<String, dynamic> map, String id) {
    return WorkRequest(
      id: id,
      businessId: map['businessId'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterAvatar: map['requesterAvatar'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterAvatar': requesterAvatar,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
