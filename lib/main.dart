// Entry point for the application

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authNotifierProvider).status;

    return MaterialApp(
      title: 'FlowServ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8344FF)),
        textTheme: AppTypography.textTheme,
        useMaterial3: true,
      ),
      home: authStatus == AuthStatus.authenticated
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
