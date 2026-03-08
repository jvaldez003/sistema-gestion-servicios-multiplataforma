import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/business_repository.dart';
import '../../data/repositories/firebase_business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return FirebaseBusinessRepository();
});

final businessesStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessesStream();
});
