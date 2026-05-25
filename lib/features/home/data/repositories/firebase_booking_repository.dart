import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/appointment.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/repositories/booking_repository.dart';

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore;

  FirebaseBookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createAppointment(Appointment appointment) async {
    final conflict = await _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: appointment.professionalId)
        .where('dateTime', isEqualTo: Timestamp.fromDate(appointment.dateTime))
        .where('status', whereIn: ['pending', 'confirmed'])
        .limit(1)
        .get();

    if (conflict.docs.isNotEmpty) {
      throw Exception('Este horario ya fue reservado. Por favor elige otro.');
    }

    await _firestore.runTransaction((transaction) async {
      final appointmentRef = _firestore.collection('appointments').doc();
      transaction.set(appointmentRef, appointment.toMap());
    });

    // Notify the user that their booking was created
    await _firestore
        .collection('users')
        .doc(appointment.userId)
        .collection('notifications')
        .add({
      'title': 'Cita agendada',
      'body': 'Tu cita de ${appointment.serviceNames.join(', ')} fue agendada exitosamente.',
      'type': 'booking_created',
      'isRead': false,
      'data': {'businessId': appointment.businessId},
      'createdAt': FieldValue.serverTimestamp(),
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
  Stream<List<Appointment>> getProfessionalAppointments(String professionalId) {
    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
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
  Stream<List<Appointment>> getBusinessAppointmentsInRange(
      String businessId, DateTime start, DateTime end) {
    return _firestore
        .collection('appointments')
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .where((appt) =>
              !appt.dateTime.isBefore(start) && appt.dateTime.isBefore(end))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
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
    await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    // Read current status before updating to detect already-completed appointments
    final docRef = _firestore.collection('appointments').doc(appointmentId);
    final currentDoc = await docRef.get();
    final wasAlreadyCompleted = currentDoc.data()?['status'] == 'completed';

    await docRef.update({'status': status});

    // Notify user of status change and grant points on completion
    try {
      final doc = await docRef.get();
      final data = doc.data();
      if (data != null) {
        final userId = data['userId'] as String?;
        final serviceNames = List<String>.from(data['serviceNames'] ?? []);
        if (userId != null && userId.isNotEmpty) {
          String title, body;
          if (status == 'confirmed') {
            title = 'Cita confirmada';
            body = 'Tu cita de ${serviceNames.join(', ')} fue confirmada.';
          } else if (status == 'cancelled') {
            title = 'Cita cancelada';
            body = 'Tu cita de ${serviceNames.join(', ')} fue cancelada.';
          } else if (status == 'completed') {
            title = 'Servicio completado';
            body = '${serviceNames.join(', ')} completado. ¡Ganaste 10 puntos de fidelidad!';
            // Only grant points if this is a new completion (not a duplicate call)
            if (!wasAlreadyCompleted) {
              await _firestore.collection('users').doc(userId).update({
                'points': FieldValue.increment(10),
              });
              await _firestore.collection('users').doc(userId).collection('points_history').add({
                'points': 10,
                'reason': 'Servicio completado: ${serviceNames.join(', ')}',
                'type': 'earned',
                'appointmentId': appointmentId,
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          } else {
            return;
          }
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .add({
            'title': title,
            'body': body,
            'type': 'booking_status',
            'isRead': false,
            'data': {'appointmentId': appointmentId},
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (_) {
      // Notification/points failure should not break the status update
    }
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
