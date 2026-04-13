import '../models/booking.dart';

abstract class BookingRepository {
  Future<void> createBooking(Booking booking);
  Stream<List<Booking>> getUserBookings(String userId);
  Stream<List<Booking>> getBusinessBookings(String businessId);
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
}
