import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import 'business_providers.dart';
import '../../domain/models/business.dart';
import '../../domain/models/service.dart';

final businessStreamProvider = StreamProvider.family<Business?, String>((ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessStream(businessId);
});

final businessServicesProvider =
    StreamProvider.family<List<Service>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getServicesStream(businessId).map((list) =>
      list.map((map) => Service.fromMap(map, map['id'])).toList());
});

final businessProductsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getProductsStream(businessId);
});

final businessPostsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getPostsStream(businessId);
});

final businessTeamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getTeamStream(businessId);
});

final isFollowingBusinessProvider = StreamProvider.family<bool, String>((ref, businessId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);
  final repository = ref.watch(businessRepositoryProvider);
  return repository.isFollowingBusiness(businessId, user.id);
});

final businessWorkRequestsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getWorkRequestsStream(businessId);
});

final sendWorkRequestProvider =
    FutureProvider.family<void, (String, String, String, String)>(
        (ref, params) async {
  final repository = ref.watch(businessRepositoryProvider);
  final (businessId, requesterId, requesterName, requesterAvatar) = params;
  await repository.sendWorkRequest(
      businessId, requesterId, requesterName, requesterAvatar);
});

final acceptWorkRequestProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final repository = ref.watch(businessRepositoryProvider);
  final (businessId, requestId) = params;
  await repository.acceptWorkRequest(businessId, requestId);
});

final rejectWorkRequestProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final repository = ref.watch(businessRepositoryProvider);
  final (businessId, requestId) = params;
  await repository.rejectWorkRequest(businessId, requestId);
});
final isUserMemberProvider =
    StreamProvider.family<bool, String>((ref, businessId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);
  final repository = ref.watch(businessRepositoryProvider);
  return repository.isMember(businessId, user.id);
});

final hasUserPendingRequestProvider =
    StreamProvider.family<bool, String>((ref, businessId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);
  final repository = ref.watch(businessRepositoryProvider);
  return repository.hasPendingRequest(businessId, user.id);
});

enum MembershipStatus { accepted, pending, none }

final userMembershipStatusProvider =
    Provider.family<MembershipStatus, String>((ref, businessId) {
  final isMember = ref.watch(isUserMemberProvider(businessId)).value ?? false;
  final hasPending =
      ref.watch(hasUserPendingRequestProvider(businessId)).value ?? false;

  if (isMember) return MembershipStatus.accepted;
  if (hasPending) return MembershipStatus.pending;
  return MembershipStatus.none;
});
