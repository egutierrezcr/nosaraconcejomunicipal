-- ====================================================
-- CMD-Nosara · Logo storage setup
-- Run in: Dashboard → SQL Editor → New query → paste → Run
-- ====================================================

-- 1. Add logo_url column to organizaciones
ALTER TABLE organizaciones ADD COLUMN IF NOT EXISTS logo_url text;

-- 2. Create storage bucket for logos (public read)
INSERT INTO storage.buckets (id, name, public)
VALUES ('logos', 'logos', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Allow anon to upload files to the logos bucket
CREATE POLICY "anon_upload_logos" ON storage.objects
  FOR INSERT TO anon
  WITH CHECK (bucket_id = 'logos');

-- 4. Allow anyone to read/download logos (public bucket)
CREATE POLICY "public_read_logos" ON storage.objects
  FOR SELECT TO anon
  USING (bucket_id = 'logos');
