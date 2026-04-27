abstract class TeamRepository {
  Stream<List<Map<String, dynamic>>> getTeamStream(String businessId);
  Future<void> updateTeamMember(String businessId, String memberId, Map<String, dynamic> member);
  Future<void> sendWorkRequest(
      String businessId, String requesterId, String requesterName, String requesterAvatar);
  Stream<List<Map<String, dynamic>>> getWorkRequestsStream(String businessId);
  Future<void> acceptWorkRequest(String businessId, String requestId);
  Future<void> rejectWorkRequest(String businessId, String requestId);
  Future<void> addTeamMember(String businessId, Map<String, dynamic> member);
  Future<void> removeTeamMember(String businessId, String memberId);
  Stream<bool> isMember(String businessId, String userId);
  Stream<bool> hasPendingRequest(String businessId, String userId);
}
