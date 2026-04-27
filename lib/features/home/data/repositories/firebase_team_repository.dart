import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/team_repository.dart';

class FirebaseTeamRepository implements TeamRepository {
  final FirebaseFirestore _firestore;

  FirebaseTeamRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Map<String, dynamic>>> getTeamStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  @override
  Future<void> updateTeamMember(String businessId, String memberId, Map<String, dynamic> member) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .doc(memberId)
        .update(member);
  }

  @override
  Future<void> sendWorkRequest(String businessId, String requesterId, String requesterName, String requesterAvatar) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('work_requests')
        .doc(requesterId)
        .set({
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterAvatar': requesterAvatar,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getWorkRequestsStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('work_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  @override
  Future<void> acceptWorkRequest(String businessId, String requestId) async {
    final batch = _firestore.batch();
    
    final requestRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('work_requests')
        .doc(requestId);
    
    final memberRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .doc(requestId);

    final requestDoc = await requestRef.get();
    if (!requestDoc.exists) return;

    batch.set(memberRef, {
      'userId': requestId,
      'name': requestDoc.data()?['requesterName'],
      'photoUrl': requestDoc.data()?['requesterAvatar'],
      'role': 'Professional',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    batch.delete(requestRef);
    
    await batch.commit();
  }

  @override
  Future<void> rejectWorkRequest(String businessId, String requestId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('work_requests')
        .doc(requestId)
        .delete();
  }

  @override
  Future<void> addTeamMember(String businessId, Map<String, dynamic> member) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .add(member);
  }

  @override
  Future<void> removeTeamMember(String businessId, String memberId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .doc(memberId)
        .delete();
  }

  @override
  Stream<bool> isMember(String businessId, String userId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Stream<bool> hasPendingRequest(String businessId, String userId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('work_requests')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
