
-- Timestamp trigger function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Project enum
CREATE TYPE public.project_id AS ENUM ('dote', 'civil', 'religieux', 'lune-de-miel');

-- Global settings (single row)
CREATE TABLE public.wedding_settings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  total_budget INTEGER NOT NULL DEFAULT 20000,
  hero_image TEXT,
  active_project TEXT NOT NULL DEFAULT 'all',
  da_settings JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.wedding_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone authenticated can read settings" ON public.wedding_settings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Anyone authenticated can update settings" ON public.wedding_settings FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Anyone authenticated can insert settings" ON public.wedding_settings FOR INSERT TO authenticated WITH CHECK (true);
CREATE TRIGGER update_wedding_settings_updated_at BEFORE UPDATE ON public.wedding_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Tasks
CREATE TABLE public.tasks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'backlog',
  priority TEXT NOT NULL DEFAULT 'medium',
  assignee TEXT NOT NULL DEFAULT '',
  deadline TEXT NOT NULL DEFAULT '',
  category TEXT NOT NULL DEFAULT '',
  project TEXT NOT NULL DEFAULT 'religieux',
  ai_suggested BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access tasks" ON public.tasks FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Expenses (multi-project via array)
CREATE TABLE public.expenses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Autre',
  amount NUMERIC NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'planned',
  date TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  linked_task TEXT,
  projects TEXT[] NOT NULL DEFAULT ARRAY['religieux'],
  ai_suggested BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access expenses" ON public.expenses FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Contributions
CREATE TABLE public.contributions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  "from" TEXT NOT NULL,
  amount NUMERIC NOT NULL DEFAULT 0,
  date TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  project TEXT NOT NULL DEFAULT 'all',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.contributions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access contributions" ON public.contributions FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Events
CREATE TABLE public.events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  date TEXT NOT NULL DEFAULT '',
  end_time TEXT,
  location TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'upcoming',
  budget NUMERIC NOT NULL DEFAULT 0,
  description TEXT NOT NULL DEFAULT '',
  sort_order INTEGER NOT NULL DEFAULT 0,
  project TEXT NOT NULL DEFAULT 'religieux',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access events" ON public.events FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Guests
CREATE TABLE public.guests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL DEFAULT '',
  phone TEXT NOT NULL DEFAULT '',
  side TEXT NOT NULL DEFAULT 'both',
  status TEXT NOT NULL DEFAULT 'pending',
  plus_one BOOLEAN NOT NULL DEFAULT false,
  dietary_notes TEXT NOT NULL DEFAULT '',
  table_id UUID,
  seat_index INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.guests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access guests" ON public.guests FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE TRIGGER update_guests_updated_at BEFORE UPDATE ON public.guests FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Vendors (multi-project via array)
CREATE TABLE public.vendors (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Autre',
  contact TEXT NOT NULL DEFAULT '',
  price NUMERIC NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'contacted',
  notes TEXT NOT NULL DEFAULT '',
  rating INTEGER NOT NULL DEFAULT 0,
  next_follow_up TEXT,
  projects TEXT[] NOT NULL DEFAULT ARRAY['religieux'],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access vendors" ON public.vendors FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Notes
CREATE TABLE public.notes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL DEFAULT '',
  category TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access notes" ON public.notes FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE TRIGGER update_notes_updated_at BEFORE UPDATE ON public.notes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Seating tables
CREATE TABLE public.seating_tables (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  shape TEXT NOT NULL DEFAULT 'round',
  seats INTEGER NOT NULL DEFAULT 8,
  x NUMERIC NOT NULL DEFAULT 200,
  y NUMERIC NOT NULL DEFAULT 200,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.seating_tables ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated full access seating_tables" ON public.seating_tables FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE TRIGGER update_seating_tables_updated_at BEFORE UPDATE ON public.seating_tables FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Enable realtime for all tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE public.expenses;
ALTER PUBLICATION supabase_realtime ADD TABLE public.contributions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.guests;
ALTER PUBLICATION supabase_realtime ADD TABLE public.vendors;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notes;
ALTER PUBLICATION supabase_realtime ADD TABLE public.seating_tables;
ALTER PUBLICATION supabase_realtime ADD TABLE public.wedding_settings;

-- Insert default settings with DA
INSERT INTO public.wedding_settings (total_budget, da_settings) VALUES (20000, '{
  "spring": {
    "base": {"name": "Cloud Dancer", "hex": "#F5F0EB", "pct": "60%"},
    "nuance": {"name": "Polar Wind", "hex": "#D8E2E8", "pct": "30%"},
    "accent": {"name": "Baby Yellow", "hex": "#F5E6A3", "pct": "10%"},
    "liants": ["Laiton brossé", "Vert sauge"],
    "textures": ["Mousseline", "Crêpe de soie", "Lin lavé"],
    "flowers": ["Camomille", "Marguerite", "Gypsophile", "Eucalyptus"]
  },
  "autumn": {
    "base": {"name": "Écru texturé", "hex": "#E8DFD0", "pct": "60%"},
    "nuance": {"name": "Royal Blue", "hex": "#1E3A5F", "pct": "30%"},
    "accent": {"name": "Sun Orange", "hex": "#E8913A", "pct": "10%"},
    "liants": ["Cuivre", "Bois noyer"],
    "textures": ["Velours", "Tweed", "Satin lourd"],
    "flowers": ["Dahlias", "Roses antiques", "Pivoines séchées"]
  },
  "context": [
    {"title": "🇨🇩 Racines congolaises", "description": "Culture, tradition, couleurs vibrantes, famille élargie"},
    {"title": "🇫🇷 Élégance française", "description": "Minimalisme, raffinement, luxe discret — Mariage civil"},
    {"title": "🇿🇦 Cape Town", "description": "Lumière naturelle, vignobles, montagnes, océan — Mariage religieux"}
  ],
  "principles": [
    {"title": "Typographie raffinée", "desc": "Playfair Display pour les titres, Cormorant Garamond pour le corps, Alex Brush pour les accents script."},
    {"title": "Espaces généreux", "desc": "Respiration, minimalisme, chaque élément a sa place."},
    {"title": "Matières nobles", "desc": "Textures de papier, effets de transparence, touches cuivrées."},
    {"title": "Harmonie culturelle", "desc": "Fusion subtile entre traditions congolaises et élégance européenne."}
  ],
  "typography": {
    "titleFont": "Playfair Display",
    "bodyFont": "Cormorant Garamond",
    "uiFont": "Montserrat",
    "scriptFont": "Alex Brush"
  },
  "weddingStyle": {
    "theme": "Élégance multiculturelle",
    "season": "Automne 2025",
    "mood": ["Raffiné", "Chaleureux", "Intemporel", "Multiculturel"],
    "dressCode": "Tenue de soirée — touches dorées bienvenues",
    "keywords": ["Cuivre", "Élégance", "Tradition", "Modernité", "Nature"]
  }
}'::jsonb);
