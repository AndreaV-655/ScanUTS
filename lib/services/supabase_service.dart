import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static bool _initialized = false;
  static Object? _initError;

  /// Indica si Supabase se inicializó correctamente.
  static bool get initialized => _initialized;

  /// Error de inicialización, si ocurrió.
  static Object? get initError => _initError;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
      _initialized = true;
    } catch (e) {
      // La app debe poder abrirse aunque Supabase no esté disponible.
      _initError = e;
      _initialized = false;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}
