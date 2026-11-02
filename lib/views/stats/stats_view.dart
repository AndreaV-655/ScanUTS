import 'package:flutter/material.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';

class StatsView extends StatelessWidget {
  final AppProvider appProvider;
  const StatsView({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    final s = appProvider.stats;
    final recursos = s?.recursos ?? const {};
    final reportes = s?.reportes ?? const {};
    final tiempos = s?.tiempos ?? const {};
    final preventivo = s?.preventivo ?? const {};
    final fallasCategoria = s?.fallasPorCategoria ?? const [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Indicadores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                title: 'Recursos',
                value: '${recursos['total'] ?? 0}',
                subtitle: 'Disponibilidad ${recursos['tasaDisponibilidad'] ?? '100'}%',
              ),
              _StatCard(
                title: 'Pendientes',
                value: '${reportes['pendientes'] ?? 0}',
                subtitle: 'Reportes abiertos',
              ),
              _StatCard(
                title: 'En proceso',
                value: '${reportes['enProceso'] ?? 0}',
                subtitle: 'Siendo atendidos',
              ),
              _StatCard(
                title: 'Críticos',
                value: '${reportes['criticosAbiertos'] ?? 0}',
                subtitle: 'Abiertos críticos',
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                const Text('Tiempos promedio', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _Row('Respuesta (h)', tiempos['promedioRespuestaHoras']?.toString() ?? '0'),
                const Divider(),
                _Row('Resolución (h)', tiempos['promedioResolucionHoras']?.toString() ?? '0'),
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
                const Text('Mantenimiento preventivo', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _Row('Programados', '${preventivo['programados'] ?? 0}'),
                const Divider(),
                _Row('Vencidos', '${preventivo['vencidos'] ?? 0}'),
                const Divider(),
                _Row('Cumplimiento', '${preventivo['cumplimiento'] ?? '100'}%'),
              ],
            ),
          ),
          if (fallasCategoria.isNotEmpty) ...[
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
                  const Text('Fallas por categoría', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  for (final item in fallasCategoria)
                    _Row(
                      item['categoria']?.toString() ?? 'SIN_CATEGORIA',
                      '${item['total'] ?? 0}',
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  const _StatCard({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
