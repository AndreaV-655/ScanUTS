// Proveedor de estado global usando ChangeNotifier
// Centraliza usuario, navegaci?n por tabs, datos y estado de UI
// Sin persistencia offline - datos cargados en memoria desde Supabase

import 'package:flutter/foundation.dart';
import '../logic/types.dart';
import '../services/supabase_data_service.dart';

class AppProvider extends ChangeNotifier {
  AppUser? _currentUser;
  List<AppUser> _usuarios = [];
  List<Recurso> _recursos = [];
  List<ReporteAveria> _reportes = [];
  List<MantenimientoPreventivo> _mantenimientosPreventivos = [];
  List<HistorialMantenimiento> _historial = [];
  int _currentTabIndex = 0;
  bool _loading = false;

  AppUser? get currentUser => _currentUser;
  List<AppUser> get usuarios => _usuarios;
  List<Recurso> get recursos => _recursos;
  List<ReporteAveria> get reportes => _reportes;
  List<MantenimientoPreventivo> get mantenimientosPreventivos => _mantenimientosPreventivos;
  List<HistorialMantenimiento> get historial => _historial;
  int get currentTabIndex => _currentTabIndex;
  bool get loading => _loading;

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setCurrentUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> loadFromSupabase() async {
    _loading = true;
    notifyListeners();
    try {
      final service = SupabaseDataService();
      final usuarios = await service.getUsuarios();
      final recursos = await service.getRecursos();
      final reportes = await service.getReportes();
      _usuarios = usuarios;
      _recursos = recursos;
      _reportes = reportes;
    } catch (e) {
      // Si falla, mantener datos vac?os
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Mantener m?todo para compatibilidad
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

  List<ReporteAveria> reportesPendientes() {
    return _reportes.where((r) => r.estado == EstadoReporte.pendiente).toList()
      ..sort((a, b) => b.fechaReporte.compareTo(a.fechaReporte));
  }
}
