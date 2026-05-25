import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/appointment.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/business.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/service.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/booking_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/auth/presentation/providers/auth_notifier.dart';

final adminBusinessProvider = StreamProvider<Business?>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  final userId = ref.watch(authNotifierProvider.select((s) => s.user?.id));

  if (userId == null) return Stream.value(null);

  return repository.getBusinessByOwnerIdStream(userId);
});

final adminServicesProvider = StreamProvider<List<Service>>((ref) {
  final repository = ref.watch(serviceRepositoryProvider);
  final businessAsync = ref.watch(adminBusinessProvider);

  return businessAsync.when(
    data: (business) {
      if (business == null) return Stream.value([]);
      return repository.getServicesStream(business.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

final adminProductsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  final businessAsync = ref.watch(adminBusinessProvider);

  return businessAsync.when(
    data: (business) {
      if (business == null) return Stream.value([]);
      return repository.getProductsStream(business.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

final adminPostsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  final businessAsync = ref.watch(adminBusinessProvider);

  return businessAsync.when(
    data: (business) {
      if (business == null) return Stream.value([]);
      return repository.getPostsStream(business.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

// Derives today's KPIs from the existing appointments stream — no extra Firestore query.
final adminTodayStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final business = ref.watch(adminBusinessProvider).valueOrNull;
  if (business == null) {
    return {'citas': 0, 'canceladas': 0, 'ingresos': 0.0};
  }

  final appointments =
      ref.watch(businessAppointmentsProvider((business.id, DateTime.now()))).valueOrNull ?? [];

  int citas = 0;
  int canceladas = 0;
  double ingresos = 0.0;

  for (final appt in appointments) {
    if (appt.status == 'cancelled') {
      canceladas++;
    } else {
      citas++;
      ingresos += appt.totalPrice;
    }
  }

  return {'citas': citas, 'canceladas': canceladas, 'ingresos': ingresos};
});

final adminFinancesProvider = StreamProvider.family<List<Appointment>, (String, DateTime, DateTime)>((ref, args) {
  final (businessId, start, end) = args;
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBusinessAppointmentsInRange(businessId, start, end);
});

// Pending work requests (solicitudes de ingreso al equipo)
final adminWorkRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final business = ref.watch(adminBusinessProvider).valueOrNull;
  if (business == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('businesses')
      .doc(business.id)
      .collection('work_requests')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
});

// Pending appointments (not yet confirmed) for today
final adminPendingTodayProvider = Provider<int>((ref) {
  final business = ref.watch(adminBusinessProvider).valueOrNull;
  if (business == null) return 0;
  final appointments =
      ref.watch(businessAppointmentsProvider((business.id, DateTime.now()))).valueOrNull ?? [];
  return appointments.where((a) => a.status == 'pending').length;
});
