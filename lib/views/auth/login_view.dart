// Vista de login
// Autenticación contra tabla usuarios en Supabase
// Incluye acceso demo local para probar sin conexión


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uts_qr_mantenimiento/models/types.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';
import 'package:uts_qr_mantenimiento/services/supabase_service.dart';
import '../main_shell.dart';

class LoginView extends StatefulWidget {
  final AppProvider appProvider;
  const LoginView({super.key, required this.appProvider});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  static const _demoReportante = 'docente1@uts.edu.co';
  static const _demoSoporte = 'soporte1@uts.edu.co';

  bool _esUsuarioDemo(String email) =>
      email == _demoReportante || email == _demoSoporte;

  Future<void> _login({String? email, String? pass}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final finalEmail = (email ?? _emailCtrl.text).trim().toLowerCase();
    final finalPass = pass ?? _passCtrl.text;
    if (finalEmail.isEmpty || finalPass.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Por favor ingrese email y contraseña';
      });
      return;
    }
    if (!SupabaseService.initialized) {
      if (_esUsuarioDemo(finalEmail)) {
        _entrarDemo(finalEmail);
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Supabase no está disponible. Usa un acceso demo sin conexión.';
      });
      return;
    }
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('usuarios')
          .select()
          .eq('correo', finalEmail)
          .maybeSingle();
      if (res == null) {
        setState(() {
          _loading = false;
          _error = 'Usuario no encontrado en la base de datos';
        });
        return;
      }
      final nombre = res['nombre']?.toString() ?? 'Usuario';
      final rolStr = (res['rol']?.toString() ?? 'REPORTANTE').toUpperCase();
      final id = res['id']?.toString() ?? finalEmail;
      Role role = Role.reportante;
      if (rolStr == 'SOPORTE_TECNICO' || rolStr.contains('SOPORTE')) {
        role = Role.soporteTecnico;
      }
      widget.appProvider.setUser(UserSession(
        id: id,
        name: nombre,
        email: finalEmail,
        role: role,
      ));
      await widget.appProvider.loadFromSupabase();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShell(appProvider: widget.appProvider)),
      );
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString();
      final esErrorRed = mensaje.contains('SocketException') ||
          mensaje.contains('ClientException') ||
          mensaje.contains('Failed host lookup') ||
          mensaje.contains('No address associated');
      if (esErrorRed && _esUsuarioDemo(finalEmail)) {
        _entrarDemo(finalEmail);
        return;
      }
      setState(() {
        _loading = false;
        _error = esErrorRed
            ? 'No se pudo conectar con Supabase. Revisa la URL del proyecto o usa un acceso demo sin conexión.'
            : 'Error al iniciar sesión: $e';
      });
    }
  }

  /// Inicia sesión con datos de ejemplo locales, sin tocar la red.
  void _entrarDemo(String email) {
    final esSoporte = email.toLowerCase().startsWith('soporte');
    widget.appProvider.setUser(UserSession(
      id: esSoporte ? 'demo-soporte' : 'demo-reportante',
      name: esSoporte ? 'Soporte Técnico' : 'Docente / Estudiante',
      email: email,
      role: esSoporte ? Role.soporteTecnico : Role.reportante,
      area: esSoporte ? 'Sistemas' : 'Aulas',
    ));
    widget.appProvider.loadDemoData();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainShell(appProvider: widget.appProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F766E), Color(0xFF134E4A), Color(0xFF052E16)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        // Logo
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, size: 36, color: Color(0xFF0F766E)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'UTS QR Mantenimiento',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestión de recursos institucionales',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        // Card de login
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 20))
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF0F766E)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ACCESO INSTITUCIONAL',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Ingresa con tus credenciales para gestionar los recursos del aula.',
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                const SizedBox(height: 16),
                                const Text('Correo institucional', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    hintText: 'usuario@uts.edu.co',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text('Contraseña', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _loading ? null : _login(),
                                  decoration: InputDecoration(
                                    hintText: '********',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                    ),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFFECACA)),
                                    ),
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : () => _login(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F766E),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 0,
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Text('Ingresar', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'ACCESO RÁPIDO DEMO',
                                        style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: Colors.grey.shade600),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Botones demo: funcionan sin conexión
                                _DemoBtn(
                                  icon: Icons.school_outlined,
                                  label: 'Estudiante o Docente',
                                  subtitle: 'Escanea QR y reporta averías',
                                  onTap: () => _entrarDemo(_demoReportante),
                                ),
                                const SizedBox(height: 8),
                                _DemoBtn(
                                  icon: Icons.headset_mic_outlined,
                                  label: 'Soporte Técnico',
                                  subtitle: 'Atiende órdenes y genera códigos QR',
                                  onTap: () => _entrarDemo(_demoSoporte),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'El acceso demo es local y no requiere conexión ni contraseña.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Botón para acceso demo
class _DemoBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _DemoBtn({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF0F766E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
