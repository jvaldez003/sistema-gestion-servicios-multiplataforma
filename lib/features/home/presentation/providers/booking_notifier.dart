import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/service.dart';

class BookingState {
  final List<Service> selectedServices;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? professionalId;
  final String? professionalName;
  final int currentStep;

  BookingState({
    this.selectedServices = const [],
    this.selectedDate,
    this.selectedTime,
    this.professionalId,
    this.professionalName,
    this.currentStep = 0,
  });

  double get totalPrice => selectedServices.fold(0, (sum, service) => sum + service.price);

  BookingState copyWith({
    List<Service>? selectedServices,
    DateTime? selectedDate,
    String? selectedTime,
    String? professionalId,
    String? professionalName,
    int? currentStep,
  }) {
    return BookingState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

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
}

final bookingStateProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
