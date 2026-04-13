import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/booking.dart';
import '../../domain/repositories/booking_repository.dart';

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore;

  FirebaseBookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createBooking(Booking booking) async {
    await _firestore.collection('bookings').add(booking.toMap());
  }

  @override
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<List<Booking>> getBusinessBookings(String businessId) {
    return _firestore
        .collection('bookings')
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status.name});
  }
}
