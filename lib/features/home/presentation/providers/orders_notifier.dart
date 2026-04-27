import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/appointment.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/business_repository.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/models/service.dart';
import '../providers/booking_providers.dart';
import '../providers/booking_notifier.dart';
import '../providers/business_providers.dart';
import '../screens/booking_flow_screen.dart';

class OrdersController extends StateNotifier<AsyncValue<void>> {
  final BookingRepository _bookingRepository;
  final BusinessRepository _businessRepository;
  final ServiceRepository _serviceRepository;
  final Ref _ref;

  OrdersController(this._bookingRepository, this._businessRepository, this._serviceRepository, this._ref) : super(const AsyncValue.data(null));

  Future<void> cancelAppointment(String appointmentId) async {
    state = const AsyncValue.loading();
    try {
      await _bookingRepository.cancelAppointment(appointmentId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startRescheduling(BuildContext context, Appointment appointment) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Get the business details
      final business = await _businessRepository.getBusinessStream(appointment.businessId).first;
      if (business == null) throw 'No se pudo encontrar el negocio';

      // 2. Get available services to initialize the state
      final services = await _serviceRepository.getServicesStream(appointment.businessId).first;

      // 3. Initialize booking state
      _ref.read(bookingStateProvider.notifier).initializeForRescheduling(appointment, services);

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingFlowScreen(
              business: business,
              appointmentToReschedule: appointment,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar reagendación: $e')),
        );
      }
    }
  }
}

final ordersControllerProvider = StateNotifierProvider<OrdersController, AsyncValue<void>>((ref) {
  final bookingRepo = ref.watch(bookingRepositoryProvider);
  final businessRepo = ref.watch(businessRepositoryProvider);
  final serviceRepo = ref.watch(serviceRepositoryProvider);
  return OrdersController(bookingRepo, businessRepo, serviceRepo, ref);
});
