-- 1. Mengaktifkan ekstensi pgvector (jika belum aktif)
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Membuat tabel knowledge_base untuk dokumen regulasi kota
CREATE TABLE IF NOT EXISTS public.knowledge_base (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    embedding VECTOR(768) NOT NULL, -- Menggunakan dimensi 768 dari model google/gemini-embedding-2
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Membuat Indeks HNSW (Hierarchical Navigable Small World) untuk pencarian kosinus yang cepat & terukur
CREATE INDEX IF NOT EXISTS knowledge_base_embedding_hnsw_idx 
ON public.knowledge_base 
USING hnsw (embedding vector_cosine_ops);

-- 4. Membuat fungsi RPC match_documents untuk pencarian kesamaan kosinus (Cosine Similarity)
CREATE OR REPLACE FUNCTION public.match_documents (
  query_embedding VECTOR(768),
  match_threshold FLOAT,
  match_count INT
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  similarity FLOAT
)
LANGUAGE sql STABLE
AS $$
  SELECT
    knowledge_base.id,
    knowledge_base.title,
    knowledge_base.content,
    1 - (knowledge_base.embedding <=> query_embedding) AS similarity
  FROM public.knowledge_base
  WHERE 1 - (knowledge_base.embedding <=> query_embedding) > match_threshold
  ORDER BY knowledge_base.embedding <=> query_embedding
  LIMIT match_count;
$$;

-- 5. Tambahkan RLS (Row Level Security) - Hanya Admin yang bisa mengubah data
ALTER TABLE public.knowledge_base ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to knowledge_base" 
ON public.knowledge_base 
FOR SELECT 
USING (true);

CREATE POLICY "Allow write access to admin only" 
ON public.knowledge_base 
FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.role = 'admin'
  )
);
