import 'package:flutter/material.dart';
import 'package:uts_qr_mantenimiento/logic/types.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';

class ReportsView extends StatelessWidget {
  final AppProvider appProvider;
  const ReportsView({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appProvider,
      builder: (context, _) {
        final user = appProvider.user;
        final isSoporte = user?.role == Role.soporteTecnico;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF22C55E)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF0F766E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSoporte ? 'Panel de Soporte Técnico' : 'Reporta averías escaneando el QR',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Acciones rápidas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  if (!isSoporte)
                    _ActionCard(
                      icon: Icons.qr_code_scanner,
                      title: 'Escanear QR',
                      subtitle: 'Identificar recurso',
                      onTap: () => appProvider.setActiveTab('scan'),
                    ),
                  if (isSoporte)
                    _ActionCard(
                      icon: Icons.qr_code,
                      title: 'Generar QR',
                      subtitle: 'Crear código',
                      onTap: () => appProvider.setActiveTab('generate-qr'),
                    ),
                  _ActionCard(
                    icon: Icons.assignment,
                    title: 'Reportes',
                    subtitle: 'Ver mis órdenes',
                    onTap: () => appProvider.setActiveTab('reports'),
                  ),
                  if (isSoporte)
                    _ActionCard(
                      icon: Icons.build,
                      title: 'Mantenimiento',
                      subtitle: 'Órdenes de trabajo',
                      onTap: () => appProvider.setActiveTab('maint'),
                    ),
                  if (isSoporte)
                    _ActionCard(
                      icon: Icons.bar_chart,
                      title: 'Indicadores',
                      subtitle: 'Estadísticas',
                      onTap: () => appProvider.setActiveTab('stats'),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Resumen', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('Ver todo', style: TextStyle(fontSize: 12, color: Colors.teal.shade700)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _StatRow(label: 'Recursos totales', value: ''),
                    const Divider(),
                    _StatRow(label: 'Operativos', value: ''),
                    const Divider(),
                    _StatRow(label: 'Reportes pendientes', value: ''),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
