import '../models/appointment.dart';

abstract class BookingRepository {
  Future<void> createAppointment(Appointment appointment);
  Stream<List<Appointment>> getUserAppointments(String userId);
  Stream<List<Appointment>> getBusinessAppointments(String businessId, DateTime date);
  Stream<List<Appointment>> getBusinessAppointmentsInRange(String businessId, DateTime start, DateTime end);
  Stream<List<Appointment>> getProfessionalAppointments(String professionalId);
  Future<bool> isSlotAvailable(String professionalId, DateTime dateTime, Duration duration);
  Future<void> cancelAppointment(String appointmentId);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<void> rescheduleAppointment(String appointmentId, DateTime newDateTime, String professionalId, String professionalName, List<String> serviceIds, List<String> serviceNames, double totalPrice);
}
