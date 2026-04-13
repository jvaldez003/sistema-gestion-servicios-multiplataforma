import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/data/repositories/firebase_booking_repository.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/booking.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/auth/presentation/providers/auth_providers.dart';

final bookingRepositoryProvider = Provider<FirebaseBookingRepository>((ref) {
  return FirebaseBookingRepository();
});

final userBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(bookingRepositoryProvider).getUserBookings(user.id);
});

final businessBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, businessId) {
  return ref.watch(bookingRepositoryProvider).getBusinessBookings(businessId);
});
