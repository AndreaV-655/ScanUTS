// Modelos y tipos compartidos para la app UTS QR Mantenimiento
// Define roles, estados, enums y clases de datos (Resource, ReporteAveria, Stats, etc.)

enum Role { reportante, soporteTecnico } // Roles de usuario

enum EstadoRecurso { operativo, mantenimiento, fueraServicio } // Estado del recurso

enum EstadoReporte { pendiente, enProceso, atendido, reabierto, cerrado } // Estado del reporte

enum Prioridad { bajo, medio, alto, critico } // Prioridad de atención

enum CategoriaFalla { electrica, fisica, software, conectividad, otra } // Tipo de falla

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

class ReporteAveria {
  final String id;
  final String codigo;
  final String resourceId;
  final String usuarioReportanteId;
  final String? tecnicoId;
  final String descripcion;
  final CategoriaFalla categoria;
  final Prioridad prioridad;
  final String tipoMantenimiento; // PREVENTIVO o CORRECTIVO
  final String? fotoUrl;
  final EstadoReporte estado;
  final String fechaReporte;
  final String? fechaAceptacion;
  final String? fechaAtencion;
  final String? fechaConfirmacion;
  final String? intervencionRealizada;
  final String? observacionesTecnico;
  final bool confirmadoUsuario;
  final String? observacionesReapertura;
  final Resource? resource;
  final Map<String, dynamic>? usuarioReportante;
  final Map<String, dynamic>? tecnico;

  ReporteAveria({
    required this.id,
    required this.codigo,
    required this.resourceId,
    required this.usuarioReportanteId,
    this.tecnicoId,
    required this.descripcion,
    required this.categoria,
    required this.prioridad,
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
  final String estado; // PROGRAMADO | VENCIDO | REALIZADO
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
