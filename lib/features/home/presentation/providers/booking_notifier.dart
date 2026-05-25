import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/service.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/appointment.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/repositories/booking_repository.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/booking_providers.dart';

class BookingState {
  final List<Service> selectedServices;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? professionalId;
  final String? professionalName;
  final int currentStep;
  final bool isLoading;
  final String? error;

  BookingState({
    this.selectedServices = const [],
    this.selectedDate,
    this.selectedTime,
    this.professionalId,
    this.professionalName,
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
  });

  double get totalPrice => selectedServices.fold(0, (sum, service) => sum + service.price);

  BookingState copyWith({
    List<Service>? selectedServices,
    DateTime? selectedDate,
    String? selectedTime,
    String? professionalId,
    String? professionalName,
    int? currentStep,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingNotifier(this._repository) : super(BookingState());

  void toggleService(Service service) {
    if (state.selectedServices.any((s) => s.id == service.id)) {
      state = state.copyWith(
        selectedServices: state.selectedServices.where((s) => s.id != service.id).toList(),
      );
    } else {
      state = state.copyWith(
        selectedServices: [...state.selectedServices, service],
      );
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectTime(String time) {
    state = state.copyWith(selectedTime: time);
  }

  void selectProfessional(String id, String name) {
    state = state.copyWith(professionalId: id, professionalName: name);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void reset() {
    state = BookingState();
  }

  void initializeForRescheduling(Appointment appointment) {
    // We create dummy services to satisfy the state, so we don't need to fetch the real ones
    // if the user just wants to reschedule the date/time.
    final selectedServices = List.generate(
      appointment.serviceIds.length,
      (i) => Service(
        id: appointment.serviceIds[i],
        name: appointment.serviceNames[i],
        description: '',
        price: appointment.serviceIds.isNotEmpty ? (appointment.totalPrice / appointment.serviceIds.length) : 0,
        duration: '',
      ),
    );
    
    state = BookingState(
      selectedServices: selectedServices,
      selectedDate: appointment.dateTime,
      selectedTime: "${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}",
      professionalId: appointment.professionalId,
      professionalName: appointment.professionalName,
      currentStep: 1, 
    );
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    return updateAppointmentStatus(appointmentId, 'cancelled');
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateAppointmentStatus(appointmentId, status);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> submitBooking({
    required String userId,
    required String businessId,
    required String businessName,
    String clientName = '',
    String? rescheduleAppointmentId,
  }) async {
    if (state.selectedDate == null || state.selectedTime == null || state.professionalId == null) {
      state = state.copyWith(error: 'Datos incompletos');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final appointmentDateTime = DateTime(
        state.selectedDate!.year,
        state.selectedDate!.month,
        state.selectedDate!.day,
        int.parse(state.selectedTime!.split(':')[0]),
        int.parse(state.selectedTime!.split(':')[1]),
      );

      if (rescheduleAppointmentId != null) {
        await _repository.rescheduleAppointment(
          rescheduleAppointmentId,
          appointmentDateTime,
          state.professionalId!,
          state.professionalName!,
          state.selectedServices.map((s) => s.id).toList(),
          state.selectedServices.map((s) => s.name).toList(),
          state.totalPrice,
        );
      } else {
        final appointment = Appointment(
          userId: userId,
          businessId: businessId,
          businessName: businessName,
          serviceIds: state.selectedServices.map((s) => s.id).toList(),
          serviceNames: state.selectedServices.map((s) => s.name).toList(),
          totalPrice: state.totalPrice,
          dateTime: appointmentDateTime,
          professionalId: state.professionalId!,
          professionalName: state.professionalName!,
          clientName: clientName,
          createdAt: DateTime.now(),
        );
        await _repository.createAppointment(appointment);
      }
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final bookingStateProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository);
});
