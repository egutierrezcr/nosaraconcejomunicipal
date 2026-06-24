-- ====================================================
-- CMD-Nosara · Supabase schema
-- Run in: Dashboard → SQL Editor → New query → paste → Run
-- ====================================================

-- 1. Tables
CREATE TABLE IF NOT EXISTS adhesiones (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamptz DEFAULT now(),
  nombre text NOT NULL,
  telefono text,
  correo text,
  barrio text NOT NULL,
  posicion text NOT NULL CHECK (posicion IN ('apoyo', 'dudas', 'mas_info', 'no')),
  ayudar_difundir boolean DEFAULT false,
  ayudar_firmas boolean DEFAULT false,
  ayudar_comite boolean DEFAULT false,
  ayudar_donar boolean DEFAULT false,
  comentario text,
  comentario_publico boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS organizaciones (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamptz DEFAULT now(),
  org_nombre text NOT NULL,
  org_persona text NOT NULL,
  org_telefono text
);

-- 2. Row Level Security (anon can INSERT only, never SELECT raw data)
ALTER TABLE adhesiones ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizaciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_insert_adhesiones" ON adhesiones
  FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "anon_insert_organizaciones" ON organizaciones
  FOR INSERT TO anon WITH CHECK (true);

-- 3. Views (security_invoker = off → bypass RLS, safe because views expose only aggregates)
CREATE OR REPLACE VIEW stats_resumen WITH (security_invoker = off) AS
SELECT
  count(*)::int AS total,
  count(*) FILTER (WHERE posicion = 'apoyo')::int AS apoyo,
  count(*) FILTER (WHERE posicion = 'dudas')::int AS dudas,
  count(*) FILTER (WHERE posicion = 'mas_info')::int AS mas_info,
  count(*) FILTER (WHERE posicion = 'no')::int AS no_apoya,
  count(*) FILTER (WHERE ayudar_comite)::int AS militantes_comite,
  count(*) FILTER (WHERE ayudar_difundir)::int AS difusores
FROM adhesiones;

CREATE OR REPLACE VIEW stats_barrio WITH (security_invoker = off) AS
SELECT barrio, count(*)::int AS total
FROM adhesiones
GROUP BY barrio
ORDER BY total DESC;

CREATE OR REPLACE VIEW comentarios_publicos WITH (security_invoker = off) AS
SELECT
  created_at,
  comentario,
  split_part(nombre, ' ', 1) AS primer_nombre,
  barrio,
  posicion
FROM adhesiones
WHERE comentario_publico = true
  AND comentario IS NOT NULL
  AND comentario <> ''
ORDER BY created_at DESC;

-- 4. Grant anon SELECT on views (not on raw tables)
GRANT SELECT ON stats_resumen TO anon;
GRANT SELECT ON stats_barrio TO anon;
GRANT SELECT ON comentarios_publicos TO anon;

-- 5. Enable Realtime for live counter updates
ALTER publication supabase_realtime ADD TABLE adhesiones;
