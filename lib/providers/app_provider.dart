// Proveedor de estado global usando ChangeNotifier
// Centraliza usuario, navegación por tabs, datos y estado de UI
// Los datos se cargan en memoria desde Supabase

import 'package:flutter/foundation.dart';
import '../models/types.dart';
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

  /// Carga datos de ejemplo en memoria para probar la app sin conexión.
  /// Se usa desde los accesos demo del login.
  void loadDemoData() {
    final ahora = DateTime.now();
    _usuarios = [
      AppUser(
        id: 'demo-soporte',
        nombre: 'Soporte Técnico',
        correo: 'soporte1@uts.edu.co',
        area: 'Sistemas',
        rol: UserRole.soporteTecnico,
      ),
      AppUser(
        id: 'demo-reportante',
        nombre: 'Docente / Estudiante',
        correo: 'docente1@uts.edu.co',
        area: 'Aulas',
        rol: UserRole.reportante,
      ),
    ];
    _recursos = [
      Recurso(
        id: 'demo-eq-1',
        codigo: 'EQ-001',
        nombre: 'Computador Aula 101',
        tipo: 'COMPUTADOR',
        marca: 'HP',
        modelo: 'EliteDesk',
        numeroSerie: 'HP-12345',
        bloque: 'A',
        aula: '101',
        estado: RecursoEstado.operativo,
        reportesActivos: 1,
      ),
      Recurso(
        id: 'demo-eq-2',
        codigo: 'EQ-002',
        nombre: 'Proyector Aula 102',
        tipo: 'PROYECTOR',
        marca: 'Epson',
        modelo: 'XGA',
        numeroSerie: 'EP-67890',
        bloque: 'A',
        aula: '102',
        estado: RecursoEstado.mantenimiento,
        reportesActivos: 1,
      ),
      Recurso(
        id: 'demo-eq-3',
        codigo: 'EQ-003',
        nombre: 'Aire acondicionado Bloque B',
        tipo: 'AIRE_ACONDICIONADO',
        marca: 'LG',
        modelo: 'Dual Inverter',
        numeroSerie: 'LG-55221',
        bloque: 'B',
        aula: '201',
        estado: RecursoEstado.fueraServicio,
        reportesActivos: 1,
      ),
    ];
    _reportes = [
      ReporteAveria(
        id: 'demo-rep-1',
        codigo: 'REP-001',
        recursoId: 'demo-eq-1',
        usuarioReportanteId: 'demo-reportante',
        descripcion: 'El computador no enciende desde esta mañana.',
        categoria: 'ELÉCTRICA',
        prioridad: 'ALTO',
        tipoMantenimiento: 'CORRECTIVO',
        estado: EstadoReporte.pendiente,
        fechaReporte: ahora.subtract(const Duration(hours: 3)),
        confirmadoUsuario: false,
      ),
      ReporteAveria(
        id: 'demo-rep-2',
        codigo: 'REP-002',
        recursoId: 'demo-eq-2',
        usuarioReportanteId: 'demo-reportante',
        tecnicoId: 'demo-soporte',
        descripcion: 'El proyector se apaga solo después de 10 minutos.',
        categoria: 'ELÉCTRICA',
        prioridad: 'MEDIA',
        tipoMantenimiento: 'CORRECTIVO',
        estado: EstadoReporte.enProceso,
        fechaReporte: ahora.subtract(const Duration(days: 1, hours: 2)),
        fechaAceptacion: ahora.subtract(const Duration(days: 1)),
        confirmadoUsuario: false,
      ),
      ReporteAveria(
        id: 'demo-rep-3',
        codigo: 'REP-003',
        recursoId: 'demo-eq-3',
        usuarioReportanteId: 'demo-reportante',
        tecnicoId: 'demo-soporte',
        descripcion: 'El aire acondicionado no enfría y hace ruido.',
        categoria: 'FÍSICA',
        prioridad: 'CRITICO',
        tipoMantenimiento: 'CORRECTIVO',
        estado: EstadoReporte.reabierto,
        fechaReporte: ahora.subtract(const Duration(days: 2)),
        fechaAceptacion: ahora.subtract(const Duration(days: 2)),
        fechaAtencion: ahora.subtract(const Duration(days: 1, hours: 4)),
        intervencionRealizada: 'Se limpiaron los filtros.',
        observacionesTecnico: 'Se recomienda revisar el compresor.',
        confirmadoUsuario: false,
        observacionesReapertura: 'Sigue haciendo ruido.',
      ),
      ReporteAveria(
        id: 'demo-rep-4',
        codigo: 'REP-004',
        recursoId: 'demo-eq-1',
        usuarioReportanteId: 'demo-reportante',
        tecnicoId: 'demo-soporte',
        descripcion: 'Mouse del computador no responde.',
        categoria: 'OTRA',
        prioridad: 'BAJO',
        tipoMantenimiento: 'CORRECTIVO',
        estado: EstadoReporte.cerrado,
        fechaReporte: ahora.subtract(const Duration(days: 6)),
        fechaAceptacion: ahora.subtract(const Duration(days: 6)),
        fechaAtencion: ahora.subtract(const Duration(days: 5)),
        fechaConfirmacion: ahora.subtract(const Duration(days: 5)),
        intervencionRealizada: 'Se reemplazó el mouse.',
        confirmadoUsuario: true,
      ),
    ];
    _error = null;
    _loading = false;
    notifyListeners();
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
