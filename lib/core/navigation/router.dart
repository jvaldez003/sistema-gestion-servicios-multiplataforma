import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../features/auth/presentation/providers/auth_notifier.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/home/presentation/screens/business_profile_screen.dart';
import '../../../features/home/presentation/screens/booking_flow_screen.dart';
import '../../../features/home/domain/models/business.dart';
import '../../../features/home/domain/models/appointment.dart';
import '../../../features/home/presentation/screens/professional_schedule_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([
      // Add any other listenables if needed
    ]),
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/business/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final business = state.extra as Business?;
          return BusinessProfileScreen(business: business, businessId: id);
        },
        routes: [
          GoRoute(
            path: 'booking',
            builder: (context, state) {
              Business? business;
              Appointment? appointment;
              
              if (state.extra is Business) {
                business = state.extra as Business;
              } else if (state.extra is Map<String, dynamic>) {
                final extraMap = state.extra as Map<String, dynamic>;
                business = extraMap['business'] as Business?;
                appointment = extraMap['appointment'] as Appointment?;
              }
              
              return BookingFlowScreen(
                business: business ?? Business(
                  id: state.pathParameters['id']!, 
                  name: '', category: '', description: '', imageUrl: '', avatarUrl: '', 
                  rating: 0.0, totalReviews: 0, distance: 0.0, isVerified: false, isTop: false, 
                  startingPrice: 0.0, tags: [], likes: 0, comments: 0, professionalCount: 0
                ),
                appointmentToReschedule: appointment,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ProfessionalScheduleScreen(),
      ),
    ],
  );
});
