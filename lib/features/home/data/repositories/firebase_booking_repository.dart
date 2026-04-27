import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/appointment.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/repositories/booking_repository.dart';

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore;

  FirebaseBookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createAppointment(Appointment appointment) async {
    // We use a transaction to ensure no double booking if we implement slot validation here
    await _firestore.runTransaction((transaction) async {
      // Create the appointment document
      final appointmentRef = _firestore.collection('appointments').doc();
      transaction.set(appointmentRef, appointment.toMap());
      
      // We could also mark the slot as occupied in a sub-collection for faster lookup
      // businesses/{businessId}/slots/{date}/{slotId}
    });
  }

  @override
  Stream<List<Appointment>> getUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort in memory to avoid Firestore index requirement
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      
      return appointments;
    });
  }

  @override
  Stream<List<Appointment>> getBusinessAppointments(String businessId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('appointments')
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .where((appt) {
            // Filter by date in memory to avoid Firestore index requirement
            return appt.dateTime.isAtSameMomentAs(startOfDay) || 
                   (appt.dateTime.isAfter(startOfDay) && appt.dateTime.isBefore(endOfDay));
          })
          .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  @override
  Future<bool> isSlotAvailable(String professionalId, DateTime dateTime, Duration duration) async {
    final endDateTime = dateTime.add(duration);

    // Query for overlapping appointments
    final query = await _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where('status', whereIn: ['pending', 'confirmed'])
        .where('dateTime', isLessThan: Timestamp.fromDate(endDateTime))
        .get();

    for (final doc in query.docs) {
      final existingAppt = Appointment.fromMap(doc.data(), doc.id);
      final existingStart = existingAppt.dateTime;
      // We'd need to know the duration of the existing appointment to be precise, 
      // but for now let's assume all appointments occupy their slot.
      // In a real scenario, we'd store the endTime too.
      if (existingStart.isBefore(endDateTime)) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': 'cancelled'});
  }

  @override
  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
    String professionalId,
    String professionalName,
    List<String> serviceIds,
    List<String> serviceNames,
    double totalPrice,
  ) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'dateTime': Timestamp.fromDate(newDateTime),
      'professionalId': professionalId,
      'professionalName': professionalName,
      'serviceIds': serviceIds,
      'serviceNames': serviceNames,
      'totalPrice': totalPrice,
      'status': 'confirmed',
    });
  }
}
