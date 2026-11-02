// Proveedor de estado global usando ChangeNotifier
// Centraliza usuario, navegación por tabs, datos y estado de UI
// Los datos se cargan en memoria desde Supabase

import 'package:flutter/foundation.dart';
import '../logic/types.dart';
import '../services/supabase_data_service.dart';

class AppProvider extends ChangeNotifier {
  UserSession? _user;
  List<AppUser> _usuarios = [];
  List<Recurso> _recursos = [];
  List<ReporteAveria> _reportes = [];
  final List<MantenimientoPreventivo> _mantenimientosPreventivos = [];
  final List<HistorialMantenimiento> _historial = [];
  String _activeTab = 'home';
  bool _loading = false;
  String? _error;

  UserSession? get user => _user;
  List<AppUser> get usuarios => _usuarios;
  List<Recurso> get recursos => _recursos;
  List<ReporteAveria> get reportes => _reportes;
  List<MantenimientoPreventivo> get mantenimientosPreventivos =>
      _mantenimientosPreventivos;
  List<HistorialMantenimiento> get historial => _historial;
  String get activeTab => _activeTab;
  bool get loading => _loading;
  String? get error => _error;

  int get recursosOperativos =>
      _recursos.where((r) => r.estado == RecursoEstado.operativo).length;

  int get reportesPendientes => _reportes
      .where((r) => r.estado == EstadoReporte.pendiente)
      .length;

  void setActiveTab(String tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  void setUser(UserSession? user) {
    _user = user;
    notifyListeners();
  }

  /// Estadísticas calculadas a partir de los datos cargados.
  Stats? get stats {
    final totalRecursos = _recursos.length;
    final operativos = _recursos
        .where((r) => r.estado == RecursoEstado.operativo)
        .length;
    final enMantenimiento = _recursos
        .where((r) => r.estado == RecursoEstado.mantenimiento)
        .length;
    final fueraServicio = _recursos
        .where((r) => r.estado == RecursoEstado.fueraServicio)
        .length;
    final disponibilidad = totalRecursos == 0
        ? '100'
        : ((operativos / totalRecursos) * 100).toStringAsFixed(1);

    final ahora = DateTime.now();
    final semanaAtras = ahora.subtract(const Duration(days: 7));

    final pendientes = _reportes
        .where((r) => r.estado == EstadoReporte.pendiente)
        .length;
    final enProceso = _reportes
        .where((r) =>
            r.estado == EstadoReporte.enProceso ||
            r.estado == EstadoReporte.aceptado ||
            r.estado == EstadoReporte.enAtencion)
        .length;
    final atendidos = _reportes
        .where((r) =>
            r.estado == EstadoReporte.atendido ||
            r.estado == EstadoReporte.resuelto)
        .length;
    final cerrados = _reportes
        .where((r) => r.estado == EstadoReporte.cerrado)
        .length;
    final reabiertos = _reportes
        .where((r) => r.estado == EstadoReporte.reabierto)
        .length;
    final criticosAbiertos = _reportes.where((r) {
      final esCritico = r.prioridad.toUpperCase() == 'CRITICO' ||
          r.prioridad.toUpperCase() == 'CRÍTICO';
      final sigueAbierto = r.estado != EstadoReporte.cerrado &&
          r.estado != EstadoReporte.atendido &&
          r.estado != EstadoReporte.resuelto;
      return esCritico && sigueAbierto;
    }).length;
    final ultimaSemana =
        _reportes.where((r) => r.fechaReporte.isAfter(semanaAtras)).length;

    final recursosPorId = {for (final r in _recursos) r.id: r};
    final fallasPorTipo = <String, int>{};
    for (final reporte in _reportes) {
      final recurso = recursosPorId[reporte.recursoId];
      final tipo = (recurso?.tipo.isNotEmpty ?? false)
          ? recurso!.tipo
          : 'SIN_RECURSO';
      fallasPorTipo[tipo] = (fallasPorTipo[tipo] ?? 0) + 1;
    }

    final fallasPorCategoria = <String, int>{};
    for (final reporte in _reportes) {
      final categoria =
          reporte.categoria.isNotEmpty ? reporte.categoria : 'SIN_CATEGORIA';
      fallasPorCategoria[categoria] = (fallasPorCategoria[categoria] ?? 0) + 1;
    }

    final tiemposRespuesta = _historial
        .map((h) => h.tiempoRespuestaHoras)
        .whereType<double>()
        .toList();
    final tiemposResolucion = _historial
        .map((h) => h.tiempoResolucionHoras)
        .whereType<double>()
        .toList();

    final totalPreventivos = _mantenimientosPreventivos.length;
    final preventivosVencidos = _mantenimientosPreventivos.where((m) {
      final fecha = DateTime.tryParse(m.fechaProgramada);
      return m.estado == 'PROGRAMADO' &&
          fecha != null &&
          fecha.isBefore(DateTime.now());
    }).length;
    final preventivosProgramados = _mantenimientosPreventivos
        .where((m) => m.estado == 'PROGRAMADO')
        .length;

    return Stats(
      recursos: {
        'total': totalRecursos,
        'operativos': operativos,
        'enMantenimiento': enMantenimiento,
        'fueraServicio': fueraServicio,
        'tasaDisponibilidad': disponibilidad,
      },
      reportes: {
        'total': _reportes.length,
        'pendientes': pendientes,
        'enProceso': enProceso,
        'atendidos': atendidos,
        'cerrados': cerrados,
        'reabiertos': reabiertos,
        'criticosAbiertos': criticosAbiertos,
        'ultimaSemana': ultimaSemana,
      },
      tiempos: {
        'promedioRespuestaHoras': _promedio(tiemposRespuesta),
        'promedioResolucionHoras': _promedio(tiemposResolucion),
      },
      fallasPorTipo: [
        for (final entry in fallasPorTipo.entries)
          {'tipo': entry.key, 'total': entry.value},
      ]..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int)),
      fallasPorCategoria: [
        for (final entry in fallasPorCategoria.entries)
          {'categoria': entry.key, 'total': entry.value},
      ]..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int)),
      preventivo: {
        'total': totalPreventivos,
        'vencidos': preventivosVencidos,
        'programados': preventivosProgramados,
        'cumplimiento': totalPreventivos == 0
            ? '100'
            : (((totalPreventivos - preventivosVencidos) / totalPreventivos) *
                    100)
                .toStringAsFixed(1),
      },
    );
  }

  String _promedio(List<double> valores) {
    if (valores.isEmpty) return '0';
    final suma = valores.fold<double>(0, (acc, v) => acc + v);
    return (suma / valores.length).toStringAsFixed(1);
  }

  Future<void> loadFromSupabase() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final service = SupabaseDataService();
      _usuarios = await service.getUsuarios();
      _recursos = await service.getRecursos();
      _reportes = await service.getReportes();
    } catch (e) {
      _error = 'No se pudieron cargar los datos: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Mantener método para compatibilidad
  void loadMockData() {
    loadFromSupabase();
  }

  List<ReporteAveria> reportesByUsuario(String usuarioId) {
    return _reportes.where((r) => r.usuarioReportanteId == usuarioId).toList()
      ..sort((a, b) => b.fechaReporte.compareTo(a.fechaReporte));
  }

  List<ReporteAveria> reportesAsignados(String tecnicoId) {
    return _reportes.where((r) => r.tecnicoId == tecnicoId).toList()
      ..sort((a, b) => b.fechaReporte.compareTo(a.fechaReporte));
  }
}
