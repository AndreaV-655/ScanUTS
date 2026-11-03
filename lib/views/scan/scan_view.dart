import 'package:flutter/material.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';

class ScanView extends StatelessWidget {
  final AppProvider appProvider;
  const ScanView({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFF0F766E)),
                      SizedBox(height: 8),
                      Text('Escáner QR', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Apunta al código QR del recurso', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Escáner QR: pendiente de conectar la cámara')),
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Iniciar escaneo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Cómo escanear?', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _Paso(numero: '1', texto: 'Ubica el código QR pegado al recurso.'),
                _Paso(numero: '2', texto: 'Presiona "Iniciar escaneo" y permite el acceso a la cámara.'),
                _Paso(numero: '3', texto: 'Revisa los datos del recurso y reporta la avería.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final String numero;
  final String texto;
  const _Paso({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDFA),
              shape: BoxShape.circle,
            ),
            child: Text(
              numero,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
