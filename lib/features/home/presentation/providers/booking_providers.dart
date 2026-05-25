import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/repositories/firebase_booking_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/appointment.dart';
import '../../domain/models/business.dart';
import 'business_providers.dart';

/// Controls which tab is selected in HomeScreen (0=Explorar, 1=Citas, 2=Puntos, 3=Perfil)
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

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

final professionalAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getProfessionalAppointments(user.id);
});

final professionalBusinessesProvider = StreamProvider<List<Business>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessesByMemberId(user.id);
});

final isProfessionalProvider = Provider<bool>((ref) {
  final businesses = ref.watch(professionalBusinessesProvider).valueOrNull ?? [];
  return businesses.isNotEmpty;
});

final memberScheduleProvider = StreamProvider.family<List<Appointment>, String>((ref, professionalId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getProfessionalAppointments(professionalId);
});
