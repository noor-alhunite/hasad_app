-- حصاد — مخطط توصيات الذكاء الاصطناعي (PostgreSQL / Supabase)
-- الجدول الرئيسي: سجلات تدريب/استنتاج من مجموعة Baidar أو مصادر لاحقة.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- دفعات استيراد لتتبع مصدر البيانات والإصدار
CREATE TABLE IF NOT EXISTS dataset_imports (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  file_name   TEXT,
  row_count   INTEGER,
  imported_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  notes       TEXT
);

COMMENT ON TABLE dataset_imports IS 'كل عملية رفع CSV أو مزامنة من النظام الخارجي';

-- البيانات الواسعة لكل سجل مزرعة/سيناريو (صف واحد = قرار توصية)
CREATE TABLE IF NOT EXISTS ai_recommendations (
  id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  import_id                 BIGINT REFERENCES dataset_imports (id) ON DELETE SET NULL,

  location                  TEXT NOT NULL,
  area_dunum                NUMERIC(12, 4),
  irrigation_type           TEXT,
  soil_type                 TEXT,
  current_season            TEXT,
  intended_crop             TEXT,

  market_condition          TEXT,
  dynamic_price_jd          NUMERIC(14, 4),
  water_used                NUMERIC(14, 4),
  expected_profit_jd        NUMERIC(14, 4),

  recommended_crop          TEXT,
  target_market             TEXT,
  recommended_water         NUMERIC(14, 4),
  water_saved               NUMERIC(14, 4),
  recommended_profit_jd     NUMERIC(14, 4),
  net_profit_difference_jd  NUMERIC(14, 4),

  raw_row                   JSONB,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_rec_location ON ai_recommendations (location);
CREATE INDEX IF NOT EXISTS idx_ai_rec_soil ON ai_recommendations (soil_type);
CREATE INDEX IF NOT EXISTS idx_ai_rec_irrigation ON ai_recommendations (irrigation_type);
CREATE INDEX IF NOT EXISTS idx_ai_rec_season ON ai_recommendations (current_season);
CREATE INDEX IF NOT EXISTS idx_ai_rec_intended ON ai_recommendations (intended_crop);
CREATE INDEX IF NOT EXISTS idx_ai_rec_market ON ai_recommendations (market_condition);
CREATE INDEX IF NOT EXISTS idx_ai_rec_import ON ai_recommendations (import_id);

COMMENT ON TABLE ai_recommendations IS 'توصيات وبيانات سيناريو لربطها بملف المزارع في تطبيق حصاد';
