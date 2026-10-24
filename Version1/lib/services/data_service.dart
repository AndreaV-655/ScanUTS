// Servicio de datos base (sin inyección externa)
// Actualmente usa listas vacías; se puede ampliar con lógica local

import '../logic/types.dart';

class DataService {
  static List<Resource> getResources() {
    return [];
  }

  static List<ReporteAveria> getReports({Role? role, String? userId}) {
    return [];
  }

  static Stats getStats() {
    return Stats(
      recursos: const {'total': 0, 'operativos': 0, 'enMantenimiento': 0, 'fueraServicio': 0, 'tasaDisponibilidad': '100'},
      reportes: const {'total': 0, 'pendientes': 0, 'enProceso': 0, 'atendidos': 0, 'cerrados': 0, 'reabiertos': 0, 'criticosAbiertos': 0, 'ultimaSemana': 0},
      tiempos: const {'promedioRespuestaHoras': '0', 'promedioResolucionHoras': '0'},
      fallasPorTipo: const [],
      fallasPorCategoria: const [],
      preventivo: const {'total': 0, 'vencidos': 0, 'programados': 0, 'cumplimiento': '100'},
    );
  }
}
