import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/repositories/firebase_booking_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/appointment.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return FirebaseBookingRepository();
});

final userAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserAppointments(user.id);
});

final businessAppointmentsProvider = StreamProvider.family<List<Appointment>, (String, DateTime)>((ref, arg) {
  final (businessId, date) = arg;
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBusinessAppointments(businessId, date);
});
