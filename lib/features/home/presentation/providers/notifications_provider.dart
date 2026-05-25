import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/app_notification.dart';

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(auth.id)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList());
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

Future<void> markNotificationRead(String userId, String notifId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .doc(notifId)
      .update({'isRead': true});
}

Future<void> markAllNotificationsRead(String userId) async {
  final batch = FirebaseFirestore.instance.batch();
  final unread = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .get();
  for (final doc in unread.docs) {
    batch.update(doc.reference, {'isRead': true});
  }
  await batch.commit();
}

Future<void> createNotificationForUser(String userId, {
  required String title,
  required String body,
  required String type,
  Map<String, dynamic> data = const {},
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .add({
    'title': title,
    'body': body,
    'type': type,
    'isRead': false,
    'data': data,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
