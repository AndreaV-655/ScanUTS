// Proveedor de estado global usando ChangeNotifier
// Centraliza usuario, navegación por tabs, datos mock y estado de UI
// Sin persistencia offline - datos cargados en memoria

import 'package:flutter/foundation.dart';
import 'package:uts_qr_mantenimiento/logic/types.dart';

class AppProvider extends ChangeNotifier {
  // === SESIÓN ===
  UserSession? _user;
  // === NAVEGACIÓN ===
  String _activeTab = 'home'; // home, scan, generate-qr, reports, maint, stats, profile

  // === DATOS ===
  List<Resource> _resources = [];
  List<ReporteAveria> _reports = [];
  List<MantenimientoPreventivo> _preventivos = [];
  Stats? _stats;

  // === UI: detalles/hojas/modal ===
  Resource? _scannedResource;
  bool _resourceSheetOpen = false;
  bool _newReportFlowOpen = false;
  ReporteAveria? _reportDetailOpen;

  // Getters
  UserSession? get user => _user;
  String get activeTab => _activeTab;
  List<Resource> get resources => _resources;
  List<ReporteAveria> get reports => _reports;
  List<MantenimientoPreventivo> get preventivos => _preventivos;
  Stats? get stats => _stats;
  Resource? get scannedResource => _scannedResource;
  bool get resourceSheetOpen => _resourceSheetOpen;
  bool get newReportFlowOpen => _newReportFlowOpen;
  ReporteAveria? get reportDetailOpen => _reportDetailOpen;

  // Setters con notificación a listeners
  void setUser(UserSession? u) {
    _user = u;
    notifyListeners();
  }

  void setActiveTab(String t) {
    _activeTab = t;
    notifyListeners();
  }

  void setResources(List<Resource> r) {
    _resources = r;
    notifyListeners();
  }

  void setReports(List<ReporteAveria> r) {
    _reports = r;
    notifyListeners();
  }

  void setPreventivos(List<MantenimientoPreventivo> p) {
    _preventivos = p;
    notifyListeners();
  }

  void setStats(Stats? s) {
    _stats = s;
    notifyListeners();
  }

  void setScannedResource(Resource? r) {
    _scannedResource = r;
    notifyListeners();
  }

  void setResourceSheetOpen(bool b) {
    _resourceSheetOpen = b;
    notifyListeners();
  }

  void setNewReportFlowOpen(bool b) {
    _newReportFlowOpen = b;
    notifyListeners();
  }

  void setReportDetailOpen(ReporteAveria? r) {
    _reportDetailOpen = r;
    notifyListeners();
  }

  // Carga datos mock para mantener funcionalidades sin modo offline
  // En producción estos datos vendrían de un backend/API
  void loadMockData() {
    _resources = [
      Resource(
        id: 'r1',
        codigo: 'EQ-001',
        nombre: 'Computador Aula 101',
        tipo: TipoRecurso.computador,
        marca: 'HP',
        modelo: 'EliteDesk',
        numeroSerie: 'HP-12345',
        bloque: 'A',
        aula: '101',
        estado: EstadoRecurso.operativo,
        reportesActivos: 0,
      ),
      Resource(
        id: 'r2',
        codigo: 'EQ-002',
        nombre: 'Proyector Aula 102',
        tipo: TipoRecurso.proyector,
        marca: 'Epson',
        modelo: 'XGA',
        numeroSerie: 'EP-67890',
        bloque: 'A',
        aula: '102',
        estado: EstadoRecurso.mantenimiento,
        reportesActivos: 1,
      ),
    ];
    _reports = [
      ReporteAveria(
        id: 'rep1',
        codigo: 'REP-001',
        resourceId: 'r1',
        usuarioReportanteId: 'u1',
        descripcion: 'No enciende',
        categoria: CategoriaFalla.electrica,
        prioridad: Prioridad.alto,
        tipoMantenimiento: 'CORRECTIVO',
        estado: EstadoReporte.pendiente,
        fechaReporte: DateTime.now().toIso8601String(),
        confirmadoUsuario: false,
        resource: Resource(
          id: 'r1',
          codigo: 'EQ-001',
          nombre: 'Computador Aula 101',
          tipo: TipoRecurso.computador,
          marca: 'HP',
          modelo: 'EliteDesk',
          numeroSerie: 'HP-12345',
          bloque: 'A',
          aula: '101',
          estado: EstadoRecurso.operativo,
        ),
      ),
    ];
    _preventivos = [];
    _stats = Stats(
      recursos: {
        'total': 2,
        'operativos': 1,
        'enMantenimiento': 1,
        'fueraServicio': 0,
        'tasaDisponibilidad': '50.0'
      },
      reportes: {
        'total': 1,
        'pendientes': 1,
        'enProceso': 0,
        'atendidos': 0,
        'cerrados': 0,
        'reabiertos': 0,
        'criticosAbiertos': 0,
        'ultimaSemana': 1
      },
      tiempos: {'promedioRespuestaHoras': '0', 'promedioResolucionHoras': '0'},
      fallasPorTipo: [
        {'tipo': 'COMPUTADOR', 'total': 1}
      ],
      fallasPorCategoria: [
        {'categoria': 'ELECTRICA', 'total': 1}
      ],
      preventivo: {
        'total': 0,
        'vencidos': 0,
        'programados': 0,
        'cumplimiento': '100'
      },
    );
    notifyListeners();
  }
}
