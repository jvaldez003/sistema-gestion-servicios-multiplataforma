import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/business.dart';
import '../../domain/repositories/business_repository.dart';
import './business_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class BusinessRegistrationState {
  final int currentStep;
  final String name;
  final String category;
  final String ownerName;
  final String email;
  final String phone;
  final String employeeCount;
  final bool hasPhysicalLocation;
  final String address;
  final String city;
  final String description;
  final bool isLoading;
  final String? errorMessage;

  BusinessRegistrationState({
    this.currentStep = 1,
    this.name = '',
    this.category = '',
    this.ownerName = '',
    this.email = '',
    this.phone = '',
    this.employeeCount = '',
    this.hasPhysicalLocation = true,
    this.address = '',
    this.city = '',
    this.description = '',
    this.isLoading = false,
    this.errorMessage,
  });

  BusinessRegistrationState copyWith({
    int? currentStep,
    String? name,
    String? category,
    String? ownerName,
    String? email,
    String? phone,
    String? employeeCount,
    bool? hasPhysicalLocation,
    String? address,
    String? city,
    String? description,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BusinessRegistrationState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      category: category ?? this.category,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employeeCount: employeeCount ?? this.employeeCount,
      hasPhysicalLocation: hasPhysicalLocation ?? this.hasPhysicalLocation,
      address: address ?? this.address,
      city: city ?? this.city,
      description: description ?? this.description,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class BusinessRegistrationNotifier
    extends StateNotifier<BusinessRegistrationState> {
  BusinessRegistrationNotifier() : super(BusinessRegistrationState());

  void updateStep(int step) => state = state.copyWith(currentStep: step);

  void updateBasicInfo({String? name, String? category}) {
    state = state.copyWith(
      name: name ?? state.name,
      category: category ?? state.category,
    );
  }

  void updateContactInfo({
    String? ownerName,
    String? email,
    String? phone,
    String? employeeCount,
  }) {
    state = state.copyWith(
      ownerName: ownerName ?? state.ownerName,
      email: email ?? state.email,
      phone: phone ?? state.phone,
      employeeCount: employeeCount ?? state.employeeCount,
    );
  }

  void updateLocationDetails({
    bool? hasPhysicalLocation,
    String? address,
    String? city,
    String? description,
  }) {
    state = state.copyWith(
      hasPhysicalLocation: hasPhysicalLocation ?? state.hasPhysicalLocation,
      address: address ?? state.address,
      city: city ?? state.city,
      description: description ?? state.description,
    );
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    try {
      // Logic to save to Firebase would go here
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() => state = BusinessRegistrationState();
}

final businessRegistrationProvider = StateNotifierProvider<
    BusinessRegistrationNotifier, BusinessRegistrationState>((ref) {
  return BusinessRegistrationNotifier();
});
