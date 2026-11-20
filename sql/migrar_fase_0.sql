-- BAN-00941. Actualiza la base existente del proyecto de pruebas.
-- Antes de ejecutar, crear en Auth una cuenta confirmada por cada correo de public.usuarios.
-- Si ya hay reportes, preventivos o historial, se requiere revisar la migración para esos datos.
BEGIN;

LOCK TABLE public.usuarios, public.recursos, public.reportes_averia,
  public.mantenimientos_preventivos, public.historial_mantenimiento IN ACCESS EXCLUSIVE MODE;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.reportes_averia)
     OR EXISTS (SELECT 1 FROM public.mantenimientos_preventivos)
     OR EXISTS (SELECT 1 FROM public.historial_mantenimiento) THEN
    RAISE EXCEPTION 'Hay reportes, preventivos o historial. Revisar la migración antes de continuar.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('usuarios', 'recursos', 'reportes_averia',
                        'mantenimientos_preventivos', 'historial_mantenimiento')
  ) THEN
    RAISE EXCEPTION 'Ya existen políticas para ScanUTS. Revisarlas antes de migrar.';
  END IF;
END;
$$;

CREATE TEMPORARY TABLE vinculos_scanuts ON COMMIT DROP AS
SELECT u.id AS perfil_id, a.id AS cuenta_id
FROM public.usuarios u
JOIN auth.users a ON lower(a.email) = lower(u.correo)
WHERE a.email_confirmed_at IS NOT NULL;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.usuarios u
    WHERE (
      SELECT count(*) FROM vinculos_scanuts v WHERE v.perfil_id = u.id
    ) <> 1
  ) OR EXISTS (
    SELECT 1 FROM vinculos_scanuts GROUP BY cuenta_id HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'Cada perfil debe corresponder a una única cuenta confirmada de Auth con el mismo correo.';
  END IF;
END;
$$;

UPDATE public.usuarios u
SET id = v.cuenta_id
FROM vinculos_scanuts v
WHERE u.id = v.perfil_id AND u.id <> v.cuenta_id;

ALTER TABLE public.usuarios
  ALTER COLUMN id DROP DEFAULT,
  ADD CONSTRAINT usuarios_auth_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE RESTRICT;

ALTER TABLE public.recursos
  ADD CONSTRAINT recursos_estado_check
    CHECK (estado IN ('OPERATIVO', 'MANTENIMIENTO', 'FUERA_SERVICIO'));

CREATE SEQUENCE public.reporte_codigo_seq;

ALTER TABLE public.reportes_averia
  ALTER COLUMN codigo SET DEFAULT
    ('REP-' || to_char(nextval('public.reporte_codigo_seq'), 'FM9999999999999990000')),
  ALTER COLUMN recurso_id SET NOT NULL,
  ALTER COLUMN usuario_reportante_id SET NOT NULL,
  ALTER COLUMN usuario_reportante_id SET DEFAULT auth.uid(),
  ADD CONSTRAINT reportes_averia_estado_check
    CHECK (estado IN ('PENDIENTE', 'EN_PROCESO', 'RESUELTO', 'CERRADO', 'REABIERTO'));

ALTER TABLE public.mantenimientos_preventivos
  ADD CONSTRAINT preventivos_periodicidad_check CHECK (periodicidad_meses > 0);

ALTER TABLE public.historial_mantenimiento
  ADD COLUMN actor_id UUID REFERENCES public.usuarios(id),
  ADD COLUMN estado_anterior TEXT,
  ADD COLUMN estado_nuevo TEXT;

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

COMMIT;
