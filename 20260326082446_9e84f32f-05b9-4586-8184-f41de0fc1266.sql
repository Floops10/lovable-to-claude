-- Fix RLS: allow anonymous access
CREATE POLICY "Public read access tasks" ON public.tasks FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access tasks" ON public.tasks FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access tasks" ON public.tasks FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access tasks" ON public.tasks FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access expenses" ON public.expenses FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access expenses" ON public.expenses FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access expenses" ON public.expenses FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access expenses" ON public.expenses FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access contributions" ON public.contributions FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access contributions" ON public.contributions FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access contributions" ON public.contributions FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access contributions" ON public.contributions FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access events" ON public.events FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access events" ON public.events FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access events" ON public.events FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access events" ON public.events FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access guests" ON public.guests FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access guests" ON public.guests FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access guests" ON public.guests FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access guests" ON public.guests FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access vendors" ON public.vendors FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access vendors" ON public.vendors FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access vendors" ON public.vendors FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access vendors" ON public.vendors FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access notes" ON public.notes FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access notes" ON public.notes FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access notes" ON public.notes FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access notes" ON public.notes FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access seating_tables" ON public.seating_tables FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access seating_tables" ON public.seating_tables FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access seating_tables" ON public.seating_tables FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access seating_tables" ON public.seating_tables FOR DELETE TO anon USING (true);

CREATE POLICY "Public read access wedding_settings" ON public.wedding_settings FOR SELECT TO anon USING (true);
CREATE POLICY "Public insert access wedding_settings" ON public.wedding_settings FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Public update access wedding_settings" ON public.wedding_settings FOR UPDATE TO anon USING (true);
CREATE POLICY "Public delete access wedding_settings" ON public.wedding_settings FOR DELETE TO anon USING (true);

CREATE TABLE public.da_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL DEFAULT '',
  label text NOT NULL DEFAULT '',
  url text NOT NULL,
  hex_color text DEFAULT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.da_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public full access da_images" ON public.da_images FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Auth full access da_images" ON public.da_images FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER PUBLICATION supabase_realtime ADD TABLE public.da_images;

CREATE TABLE public.da_elements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL DEFAULT '',
  name text NOT NULL DEFAULT '',
  hex_color text DEFAULT '',
  description text DEFAULT '',
  image_url text DEFAULT '',
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.da_elements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public full access da_elements" ON public.da_elements FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Auth full access da_elements" ON public.da_elements FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER PUBLICATION supabase_realtime ADD TABLE public.da_elements;

INSERT INTO storage.buckets (id, name, public) VALUES ('da-images', 'da-images', true);

CREATE POLICY "Public read da-images" ON storage.objects FOR SELECT TO anon USING (bucket_id = 'da-images');
CREATE POLICY "Public insert da-images" ON storage.objects FOR INSERT TO anon WITH CHECK (bucket_id = 'da-images');
CREATE POLICY "Public update da-images" ON storage.objects FOR UPDATE TO anon USING (bucket_id = 'da-images');
CREATE POLICY "Public delete da-images" ON storage.objects FOR DELETE TO anon USING (bucket_id = 'da-images');
CREATE POLICY "Auth read da-images" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'da-images');
CREATE POLICY "Auth insert da-images" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'da-images');
CREATE POLICY "Auth update da-images" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'da-images');
CREATE POLICY "Auth delete da-images" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'da-images');

CREATE TRIGGER update_da_images_updated_at BEFORE UPDATE ON public.da_images FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_da_elements_updated_at BEFORE UPDATE ON public.da_elements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();