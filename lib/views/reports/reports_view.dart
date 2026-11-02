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
        final reportes = appProvider.reportes;
        final recursosPorId = {for (final r in appProvider.recursos) r.id: r};

        return RefreshIndicator(
          onRefresh: appProvider.loadFromSupabase,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Reportes de avería', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${reportes.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Desliza hacia abajo para actualizar',
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
              if (appProvider.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    appProvider.error!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (reportes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 40, color: Colors.black26),
                      SizedBox(height: 8),
                      Text('No hay reportes registrados', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                )
              else
                ...reportes.map((reporte) {
                  final recurso = recursosPorId[reporte.recursoId];
                  return _ReportCard(reporte: reporte, recurso: recurso);
                }),
            ],
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReporteAveria reporte;
  final Recurso? recurso;
  const _ReportCard({required this.reporte, this.recurso});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reporte.codigo.isNotEmpty ? reporte.codigo : 'Sin código',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              _Badge(
                label: _estadoLabel(reporte.estado),
                color: _estadoColor(reporte.estado),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            recurso?.nombre ?? 'Recurso no encontrado',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            reporte.descripcion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Badge(
                label: reporte.prioridad.isNotEmpty ? reporte.prioridad : 'MEDIA',
                color: _prioridadColor(reporte.prioridad),
              ),
              const SizedBox(width: 8),
              Text(
                _fecha(reporte.fechaReporte),
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fecha(DateTime value) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(value.day)}/${dos(value.month)}/${value.year} ${dos(value.hour)}:${dos(value.minute)}';
  }

  String _estadoLabel(EstadoReporte estado) {
    switch (estado) {
      case EstadoReporte.pendiente:
        return 'PENDIENTE';
      case EstadoReporte.enProceso:
        return 'EN PROCESO';
      case EstadoReporte.atendido:
        return 'ATENDIDO';
      case EstadoReporte.reabierto:
        return 'REABIERTO';
      case EstadoReporte.cerrado:
        return 'CERRADO';
      case EstadoReporte.aceptado:
        return 'ACEPTADO';
      case EstadoReporte.enAtencion:
        return 'EN ATENCIÓN';
      case EstadoReporte.resuelto:
        return 'RESUELTO';
    }
  }

  Color _estadoColor(EstadoReporte estado) {
    switch (estado) {
      case EstadoReporte.pendiente:
        return const Color(0xFFB45309);
      case EstadoReporte.reabierto:
        return const Color(0xFFB91C1C);
      case EstadoReporte.cerrado:
      case EstadoReporte.resuelto:
      case EstadoReporte.atendido:
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF0F766E);
    }
  }

  Color _prioridadColor(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'CRITICO':
      case 'CRÍTICO':
        return const Color(0xFFB91C1C);
      case 'ALTO':
        return const Color(0xFFC2410C);
      case 'BAJO':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFFB45309);
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: color),
      ),
    );
  }
}
