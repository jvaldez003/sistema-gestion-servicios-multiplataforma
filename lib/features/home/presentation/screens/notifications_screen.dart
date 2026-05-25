import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking_created':
        return Icons.calendar_today_rounded;
      case 'booking_status':
        return Icons.event_available_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'booking_created':
        return AppColors.primary;
      case 'booking_status':
        return const Color(0xFF10B981);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notificaciones', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          if (currentUser != null)
            TextButton(
              onPressed: () async {
                await markAllNotificationsRead(currentUser.id);
              },
              child: const Text('Leer todas', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 64),
                  ),
                  const SizedBox(height: 24),
                  Text('No tienes notificaciones', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Te avisaremos cuando haya novedades importantes sobre tus citas.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 0),
            itemBuilder: (ctx, i) {
              final notif = notifications[i];
              final color = _colorForType(notif.type);
              return GestureDetector(
                onTap: () async {
                  if (!notif.isRead && currentUser != null) {
                    await markNotificationRead(currentUser.id, notif.id);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notif.isRead
                        ? Theme.of(ctx).cardTheme.color
                        : color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.isRead
                          ? Theme.of(ctx).dividerColor
                          : color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(_iconForType(notif.type), color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 14)),
                                ),
                                if (!notif.isRead)
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(notif.body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('d MMM, HH:mm', 'es').format(notif.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
