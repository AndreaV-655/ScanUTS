// Punto de entrada de la aplicación UTS QR Mantenimiento
// Inicializa la app con el proveedor de estado global (AppProvider)

import 'package:flutter/material.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';
import 'package:uts_qr_mantenimiento/views/splash_view.dart';

void main() {
  // Ejecuta la app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Instancia única del proveedor que gestiona estado global de la app
  final AppProvider _appProvider = AppProvider();

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder escucha cambios en el AppProvider para rebuilds reactivos
    return AnimatedBuilder(
      animation: _appProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'UTS QR Mantenimiento',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            // Paleta de colores institucionales
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              primary: const Color(0xFF0F766E),
              secondary: const Color(0xFF22C55E),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF0F172A),
              elevation: 0,
              centerTitle: false,
            ),
          ),
          // Vista inicial
          home: SplashView(appProvider: _appProvider),
        );
      },
    );
  }
}
