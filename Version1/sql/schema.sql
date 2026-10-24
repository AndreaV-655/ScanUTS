-- Esquema para UTS QR Mantenimiento
-- Crear tablas con nombres en espa?ol, permitir acentos

CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  correo TEXT UNIQUE NOT NULL,
  telefono TEXT,
  area TEXT,
  rol TEXT NOT NULL CHECK (rol IN ('REPORTANTE','SOPORTE_TECNICO')),
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS recursos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  tipo TEXT NOT NULL,
  marca TEXT,
  modelo TEXT,
  numero_serie TEXT,
  bloque TEXT,
  aula TEXT,
  estado TEXT NOT NULL DEFAULT 'OPERATIVO',
  fecha_compra DATE,
  costo_estimado NUMERIC,
  qr_data TEXT,
  reportes_activos INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reportes_averia (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT UNIQUE NOT NULL,
  recurso_id UUID REFERENCES recursos(id),
  usuario_reportante_id UUID REFERENCES usuarios(id),
  tecnico_id UUID REFERENCES usuarios(id),
  descripcion TEXT NOT NULL,
  categoria TEXT NOT NULL,
  prioridad TEXT NOT NULL,
  tipo_mantenimiento TEXT NOT NULL DEFAULT 'CORRECTIVO',
  foto_url TEXT,
  estado TEXT NOT NULL DEFAULT 'PENDIENTE',
  fecha_reporte TIMESTAMP WITH TIME ZONE DEFAULT now(),
  fecha_aceptacion TIMESTAMP WITH TIME ZONE,
  fecha_atencion TIMESTAMP WITH TIME ZONE,
  fecha_confirmacion TIMESTAMP WITH TIME ZONE,
  intervencion_realizada TEXT,
  observaciones_tecnico TEXT,
  confirmado_usuario BOOLEAN DEFAULT false,
  observaciones_reapertura TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS mantenimientos_preventivos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recurso_id UUID REFERENCES recursos(id),
  descripcion TEXT NOT NULL,
  periodicidad_meses INTEGER NOT NULL,
  fecha_programada DATE NOT NULL,
  ultima_ejecucion DATE,
  estado TEXT NOT NULL DEFAULT 'PROGRAMADO',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS historial_mantenimiento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recurso_id UUID REFERENCES recursos(id),
  reporte_id UUID REFERENCES reportes_averia(id),
  tecnico_id UUID REFERENCES usuarios(id),
  fecha TIMESTAMP WITH TIME ZONE DEFAULT now(),
  intervencion TEXT NOT NULL,
  tiempo_respuesta_horas NUMERIC,
  tiempo_resolucion_horas NUMERIC,
  observaciones TEXT
);

-- Datos m?nimos
INSERT INTO usuarios (nombre, correo, rol) VALUES
('Soporte T?cnico', 'soporte1@uts.edu.co', 'SOPORTE_TECNICO'),
('Docente / Estudiante', 'docente1@uts.edu.co', 'REPORTANTE')
ON CONFLICT (correo) DO NOTHING;

INSERT INTO recursos (codigo, nombre, tipo, marca, modelo, numero_serie, bloque, aula, estado) VALUES
('EQ-001', 'Computador Aula 101', 'COMPUTADOR', 'HP', 'EliteDesk', 'HP-12345', 'A', '101', 'OPERATIVO'),
('EQ-002', 'Proyector Aula 102', 'PROYECTOR', 'Epson', 'XGA', 'EP-67890', 'A', '102', 'MANTENIMIENTO')
ON CONFLICT (codigo) DO NOTHING;
