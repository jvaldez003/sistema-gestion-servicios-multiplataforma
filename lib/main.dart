// Entry point for the application

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Gestión de Servicios',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(body: Center(child: Text('¡Bienvenido!'))),
    );
  }
}
