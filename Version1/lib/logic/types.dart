// Modelos y tipos compartidos para la app UTS QR Mantenimiento

enum Role { reportante, soporteTecnico }

enum UserRole { reportante, soporteTecnico }

enum EstadoRecurso { operativo, mantenimiento, fueraServicio }
enum RecursoEstado { operativo, mantenimiento, fueraServicio }

enum EstadoReporte { pendiente, enProceso, atendido, reabierto, cerrado, aceptado, enAtencion, resuelto }

enum Prioridad { bajo, medio, alto, critico }

enum CategoriaFalla { electrica, fisica, software, conectividad, otra }

enum TipoRecurso { computador, proyector, aireAcondicionado, mobiliario, impresora, switch_, otro }

class UserSession {
  final String id;
  final String name;
  final String email;
  final Role role;
  final String? phone;
  final String? area;
  final String? avatar;

  UserSession({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.area,
    this.avatar,
  });
}

class AppUser {
  final String id;
  final String nombre;
  final String correo;
  final String? telefono;
  final String? area;
  final UserRole rol;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.nombre,
    required this.correo,
    this.telefono,
    this.area,
    required this.rol,
    this.avatarUrl,
  });
}

class Resource {
  final String id;
  final String codigo;
  final String nombre;
  final TipoRecurso tipo;
  final String marca;
  final String modelo;
  final String numeroSerie;
  final String bloque;
  final String aula;
  final EstadoRecurso estado;
  final String? fechaCompra;
  final double? costoEstimado;
  final String? qrData;
  final int? reportesActivos;

  Resource({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.bloque,
    required this.aula,
    required this.estado,
    this.fechaCompra,
    this.costoEstimado,
    this.qrData,
    this.reportesActivos,
  });
}

class Recurso {
  final String id;
  final String codigo;
  final String nombre;
  final String tipo;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final String? bloque;
  final String? aula;
  final RecursoEstado estado;
  final DateTime? fechaCompra;
  final double? costoEstimado;
  final String? qrData;
  final int reportesActivos;

  Recurso({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    this.marca,
    this.modelo,
    this.numeroSerie,
    this.bloque,
    this.aula,
    required this.estado,
    this.fechaCompra,
    this.costoEstimado,
    this.qrData,
    required this.reportesActivos,
  });
}

class ReporteAveria {
  final String id;
  final String codigo;
  final String resourceId;
  final String usuarioReportanteId;
  final String? tecnicoId;
  final String descripcion;
  final CategoriaFalla? categoriaEnum;
  final String categoria;
  final Prioridad? prioridadEnum;
  final String prioridad;
  final String tipoMantenimiento;
  final String? fotoUrl;
  final EstadoReporte estado;
  final DateTime fechaReporte;
  final DateTime? fechaAceptacion;
  final DateTime? fechaAtencion;
  final DateTime? fechaConfirmacion;
  final String? intervencionRealizada;
  final String? observacionesTecnico;
  final bool confirmadoUsuario;
  final String? observacionesReapertura;
  final Resource? resource;
  final Map<String, dynamic>? usuarioReportante;
  final Map<String, dynamic>? tecnico;
  final String? recursoId;

  ReporteAveria({
    required this.id,
    required this.codigo,
    this.resourceId = '',
    required this.usuarioReportanteId,
    this.tecnicoId,
    required this.descripcion,
    this.categoriaEnum,
    this.categoria = '',
    this.prioridadEnum,
    this.prioridad = 'MEDIA',
    required this.tipoMantenimiento,
    this.fotoUrl,
    required this.estado,
    required this.fechaReporte,
    this.fechaAceptacion,
    this.fechaAtencion,
    this.fechaConfirmacion,
    this.intervencionRealizada,
    this.observacionesTecnico,
    required this.confirmadoUsuario,
    this.observacionesReapertura,
    this.resource,
    this.usuarioReportante,
    this.tecnico,
    this.recursoId,
  });
}

class Stats {
  final Map<String, dynamic> recursos;
  final Map<String, dynamic> reportes;
  final Map<String, dynamic> tiempos;
  final List<Map<String, dynamic>> fallasPorTipo;
  final List<Map<String, dynamic>> fallasPorCategoria;
  final Map<String, dynamic> preventivo;

  Stats({
    required this.recursos,
    required this.reportes,
    required this.tiempos,
    required this.fallasPorTipo,
    required this.fallasPorCategoria,
    required this.preventivo,
  });
}

class MantenimientoPreventivo {
  final String id;
  final String resourceId;
  final String descripcion;
  final int periodicidadMeses;
  final String fechaProgramada;
  final String? ultimaEjecucion;
  final String estado;
  final Resource? resource;

  MantenimientoPreventivo({
    required this.id,
    required this.resourceId,
    required this.descripcion,
    required this.periodicidadMeses,
    required this.fechaProgramada,
    this.ultimaEjecucion,
    required this.estado,
    this.resource,
  });
}

class HistorialMantenimiento {
  final String id;
  final String recursoId;
  final String? reporteId;
  final String? tecnicoId;
  final DateTime fecha;
  final String intervencion;
  final double? tiempoRespuestaHoras;
  final double? tiempoResolucionHoras;
  final String? observaciones;

  HistorialMantenimiento({
    required this.id,
    required this.recursoId,
    this.reporteId,
    this.tecnicoId,
    required this.fecha,
    required this.intervencion,
    this.tiempoRespuestaHoras,
    this.tiempoResolucionHoras,
    this.observaciones,
  });
}
