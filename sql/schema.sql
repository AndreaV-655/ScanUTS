-- Esquema inicial para un proyecto Supabase de pruebas vacío.
-- Para una base existente, se necesita una migración que conserve sus datos.
BEGIN;

CREATE TABLE public.usuarios (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
  nombre TEXT NOT NULL,
  correo TEXT UNIQUE NOT NULL,
  telefono TEXT,
  area TEXT,
  rol TEXT NOT NULL CHECK (rol IN ('REPORTANTE','SOPORTE_TECNICO')),
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.recursos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  tipo TEXT NOT NULL,
  marca TEXT,
  modelo TEXT,
  numero_serie TEXT,
  bloque TEXT,
  aula TEXT,
  estado TEXT NOT NULL DEFAULT 'OPERATIVO'
    CHECK (estado IN ('OPERATIVO', 'MANTENIMIENTO', 'FUERA_SERVICIO')),
  fecha_compra DATE,
  costo_estimado NUMERIC,
  qr_data TEXT,
  reportes_activos INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE SEQUENCE public.reporte_codigo_seq;

CREATE TABLE public.reportes_averia (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT UNIQUE NOT NULL DEFAULT
    ('REP-' || to_char(nextval('public.reporte_codigo_seq'), 'FM9999999999999990000')),
  recurso_id UUID NOT NULL REFERENCES public.recursos(id),
  usuario_reportante_id UUID NOT NULL DEFAULT auth.uid() REFERENCES public.usuarios(id),
  tecnico_id UUID REFERENCES public.usuarios(id),
  descripcion TEXT NOT NULL,
  categoria TEXT NOT NULL,
  prioridad TEXT NOT NULL,
  tipo_mantenimiento TEXT NOT NULL DEFAULT 'CORRECTIVO',
  foto_url TEXT,
  estado TEXT NOT NULL DEFAULT 'PENDIENTE'
    CHECK (estado IN ('PENDIENTE', 'EN_PROCESO', 'RESUELTO', 'CERRADO', 'REABIERTO')),
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

CREATE TABLE public.mantenimientos_preventivos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recurso_id UUID REFERENCES public.recursos(id),
  descripcion TEXT NOT NULL,
  periodicidad_meses INTEGER NOT NULL CHECK (periodicidad_meses > 0),
  fecha_programada DATE NOT NULL,
  ultima_ejecucion DATE,
  estado TEXT NOT NULL DEFAULT 'PROGRAMADO',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.historial_mantenimiento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recurso_id UUID REFERENCES public.recursos(id),
  reporte_id UUID REFERENCES public.reportes_averia(id),
  tecnico_id UUID REFERENCES public.usuarios(id),
  fecha TIMESTAMP WITH TIME ZONE DEFAULT now(),
  intervencion TEXT NOT NULL,
  tiempo_respuesta_horas NUMERIC,
  tiempo_resolucion_horas NUMERIC,
  observaciones TEXT,
  actor_id UUID REFERENCES public.usuarios(id),
  estado_anterior TEXT,
  estado_nuevo TEXT
);

ALTER SEQUENCE public.reporte_codigo_seq OWNED BY public.reportes_averia.codigo;

CREATE INDEX reportes_estado_idx ON public.reportes_averia (estado);
CREATE INDEX reportes_recurso_idx ON public.reportes_averia (recurso_id);
CREATE INDEX reportes_reportante_idx ON public.reportes_averia (usuario_reportante_id);
CREATE INDEX historial_reporte_idx ON public.historial_mantenimiento (reporte_id);

ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recursos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reportes_averia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mantenimientos_preventivos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historial_mantenimiento ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.usuarios, public.recursos, public.reportes_averia,
  public.mantenimientos_preventivos, public.historial_mantenimiento
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON SEQUENCE public.reporte_codigo_seq FROM PUBLIC, anon, authenticated;

GRANT SELECT ON public.usuarios, public.recursos, public.reportes_averia,
  public.mantenimientos_preventivos, public.historial_mantenimiento TO authenticated;
GRANT INSERT (recurso_id, descripcion, categoria, prioridad)
  ON public.reportes_averia TO authenticated;
GRANT USAGE ON SEQUENCE public.reporte_codigo_seq TO authenticated;
GRANT INSERT, UPDATE ON public.recursos TO authenticated;

-- Un administrador vincula cada perfil con el UUID de su cuenta de Auth.
-- Los perfiles y sus roles se administran fuera de la aplicación.
CREATE POLICY usuarios_leer_perfil_propio ON public.usuarios
  FOR SELECT TO authenticated USING (id = (SELECT auth.uid()));

CREATE POLICY recursos_leer_con_perfil ON public.recursos
  FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.usuarios));

CREATE POLICY recursos_crear_soporte ON public.recursos
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM public.usuarios WHERE rol = 'SOPORTE_TECNICO')
  );

CREATE POLICY recursos_editar_soporte ON public.recursos
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.usuarios WHERE rol = 'SOPORTE_TECNICO'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.usuarios WHERE rol = 'SOPORTE_TECNICO'));

CREATE POLICY reportes_leer_por_rol ON public.reportes_averia
  FOR SELECT TO authenticated USING (
    usuario_reportante_id = (SELECT auth.uid())
    OR EXISTS (SELECT 1 FROM public.usuarios WHERE rol = 'SOPORTE_TECNICO')
  );

CREATE POLICY reportes_crear_reportante ON public.reportes_averia
  FOR INSERT TO authenticated WITH CHECK (
    usuario_reportante_id = (SELECT auth.uid())
    AND estado = 'PENDIENTE'
    AND EXISTS (SELECT 1 FROM public.usuarios WHERE rol = 'REPORTANTE')
  );

-- Las transiciones y escrituras de historial se añadirán juntas en la Fase 5.
CREATE POLICY historial_leer_reportes_visibles ON public.historial_mantenimiento
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.usuarios WHERE rol = 'SOPORTE_TECNICO')
    OR EXISTS (
      SELECT 1 FROM public.reportes_averia
      WHERE reportes_averia.id = historial_mantenimiento.reporte_id
    )
  );

CREATE POLICY preventivos_leer_soporte ON public.mantenimientos_preventivos
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.usuarios WHERE rol = 'SOPORTE_TECNICO')
  );

INSERT INTO public.recursos (codigo, nombre, tipo, marca, modelo, numero_serie, bloque, aula, estado) VALUES
('EQ-001', 'Computador Aula 101', 'COMPUTADOR', 'HP', 'EliteDesk', 'HP-12345', 'A', '101', 'OPERATIVO'),
('EQ-002', 'Proyector Aula 102', 'PROYECTOR', 'Epson', 'XGA', 'EP-67890', 'A', '102', 'MANTENIMIENTO')
ON CONFLICT (codigo) DO NOTHING;

COMMIT;
