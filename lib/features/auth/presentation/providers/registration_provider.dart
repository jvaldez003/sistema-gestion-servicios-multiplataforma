import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationData {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  RegistrationData({
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
  });

  RegistrationData copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
  }) {
    return RegistrationData(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationData> {
  RegistrationNotifier() : super(RegistrationData());

  void updateData({
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  void reset() {
    state = RegistrationData();
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationData>((ref) {
  return RegistrationNotifier();
});
