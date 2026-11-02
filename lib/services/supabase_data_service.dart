// Servicio para obtener datos desde Supabase
// Usa solo Dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/types.dart';

class SupabaseDataService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AppUser>> getUsuarios() async {
    final res = await _client.from('usuarios').select().order('created_at');
    final list = <AppUser>[];
    for (final row in res as List) {
      list.add(AppUser(
        id: row['id'].toString(),
        nombre: row['nombre'] ?? '',
        correo: row['correo'] ?? '',
        telefono: row['telefono'],
        area: row['area'],
        rol: row['rol'] == 'SOPORTE_TECNICO' ? UserRole.soporteTecnico : UserRole.reportante,
        avatarUrl: row['avatar_url'],
      ));
    }
    return list;
  }

  Future<List<Recurso>> getRecursos() async {
    final res = await _client.from('recursos').select().order('codigo');
    final list = <Recurso>[];
    for (final row in res as List) {
      list.add(Recurso(
        id: row['id'].toString(),
        codigo: row['codigo'] ?? '',
        nombre: row['nombre'] ?? '',
        tipo: row['tipo'] ?? '',
        marca: row['marca'],
        modelo: row['modelo'],
        numeroSerie: row['numero_serie'],
        bloque: row['bloque'],
        aula: row['aula'],
        estado: _mapRecursoEstado(row['estado']),
        fechaCompra: row['fecha_compra'] != null ? DateTime.tryParse(row['fecha_compra'].toString()) : null,
        costoEstimado: row['costo_estimado'] != null ? double.tryParse(row['costo_estimado'].toString()) : null,
        qrData: row['qr_data'],
        reportesActivos: row['reportes_activos'] ?? 0,
      ));
    }
    return list;
  }

  Future<List<ReporteAveria>> getReportes() async {
    final res = await _client.from('reportes_averia').select().order('fecha_reporte', ascending: false);
    final list = <ReporteAveria>[];
    for (final row in res as List) {
      list.add(ReporteAveria(
        id: row['id'].toString(),
        codigo: row['codigo'] ?? '',
        recursoId: row['recurso_id']?.toString() ?? '',
        usuarioReportanteId: row['usuario_reportante_id']?.toString() ?? '',
        tecnicoId: row['tecnico_id']?.toString(),
        descripcion: row['descripcion'] ?? '',
        categoria: row['categoria'] ?? '',
        prioridad: row['prioridad'] ?? 'MEDIA',
        tipoMantenimiento: row['tipo_mantenimiento'] ?? 'CORRECTIVO',
        fotoUrl: row['foto_url'],
        estado: _mapEstado(row['estado']),
        fechaReporte: row['fecha_reporte'] != null ? DateTime.tryParse(row['fecha_reporte'].toString()) ?? DateTime.now() : DateTime.now(),
        fechaAceptacion: row['fecha_aceptacion'] != null ? DateTime.tryParse(row['fecha_aceptacion'].toString()) : null,
        fechaAtencion: row['fecha_atencion'] != null ? DateTime.tryParse(row['fecha_atencion'].toString()) : null,
        fechaConfirmacion: row['fecha_confirmacion'] != null ? DateTime.tryParse(row['fecha_confirmacion'].toString()) : null,
        intervencionRealizada: row['intervencion_realizada'],
        observacionesTecnico: row['observaciones_tecnico'],
        confirmadoUsuario: row['confirmado_usuario'] ?? false,
        observacionesReapertura: row['observaciones_reapertura'],
      ));
    }
    return list;
  }

  RecursoEstado _mapRecursoEstado(String? s) {
    switch (s) {
      case 'MANTENIMIENTO':
        return RecursoEstado.mantenimiento;
      case 'FUERA_SERVICIO':
        return RecursoEstado.fueraServicio;
      case 'OPERATIVO':
        return RecursoEstado.operativo;
      default:
        return RecursoEstado.operativo;
    }
  }

  EstadoReporte _mapEstado(String? s) {
    switch (s) {
      case 'ACEPTADO':
        return EstadoReporte.aceptado;
      case 'EN_PROCESO':
        return EstadoReporte.enProceso;
      case 'EN_ATENCION':
        return EstadoReporte.enAtencion;
      case 'ATENDIDO':
        return EstadoReporte.atendido;
      case 'RESUELTO':
        return EstadoReporte.resuelto;
      case 'CERRADO':
        return EstadoReporte.cerrado;
      case 'REABIERTO':
        return EstadoReporte.reabierto;
      default:
        return EstadoReporte.pendiente;
    }
  }
}
