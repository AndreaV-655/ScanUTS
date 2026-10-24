import 'package:flutter/material.dart';
import 'providers/app_provider.dart';
import 'services/supabase_service.dart';
import 'views/splash_view.dart' as splash;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppProvider _appProvider = AppProvider();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'UTS QR Mantenimiento',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
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
          home: splash.SplashView(appProvider: _appProvider),
        );
      },
    );
  }
}
