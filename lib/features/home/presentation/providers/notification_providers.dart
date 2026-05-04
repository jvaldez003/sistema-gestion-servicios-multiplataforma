import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import 'booking_providers.dart';

final appointmentNotificationSyncProvider = Provider<void>((ref) {
  final appointmentsAsync = ref.watch(userAppointmentsProvider);

  appointmentsAsync.whenData((appointments) {
    final notificationService = NotificationService();
    
    for (final appointment in appointments) {
      final notificationId = appointment.id.hashCode;
      final notifyTime = appointment.dateTime.subtract(const Duration(hours: 1));
      
      if (notifyTime.isAfter(DateTime.now()) && appointment.status != 'cancelled') {
        notificationService.scheduleAppointmentNotification(
          id: notificationId,
          title: 'Cita Próxima',
          body: 'Tu cita para ${appointment.serviceNames.join(", ")} es en 1 hora.',
          scheduledTime: notifyTime,
        );
      }
    }
  });
});
