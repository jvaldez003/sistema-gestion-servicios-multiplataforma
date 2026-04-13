import '../models/appointment.dart';

abstract class BookingRepository {
  Future<void> createAppointment(Appointment appointment);
  Stream<List<Appointment>> getUserAppointments(String userId);
  Stream<List<Appointment>> getBusinessAppointments(String businessId, DateTime date);
  Future<bool> isSlotAvailable(String professionalId, DateTime dateTime, Duration duration);
  Future<void> cancelAppointment(String appointmentId);
}
