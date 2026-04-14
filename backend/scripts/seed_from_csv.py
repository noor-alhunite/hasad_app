#!/usr/bin/env python3
"""
قراءة CSV وإدراج الصفوف في PostgreSQL/Supabase أو SQLite.
تشغيل:
  python scripts/seed_from_csv.py --csv ../data/Baidar_AI_Dataset_2024.csv --dsn postgresql://user:pass@host:5432/db
  python scripts/seed_from_csv.py --csv data.csv --sqlite ../local.db
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Connection

_ROOT = Path(__file__).resolve().parents[1]
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from app.column_aliases import normalize_columns  # noqa: E402


INSERT_SQL_PG = text(
    """
    INSERT INTO ai_recommendations (
      import_id, location, area_dunum, irrigation_type, soil_type,
      current_season, intended_crop, market_condition, dynamic_price_jd,
      water_used, expected_profit_jd, recommended_crop, target_market,
      recommended_water, water_saved, recommended_profit_jd,
      net_profit_difference_jd, raw_row
    ) VALUES (
      :import_id, :location, :area_dunum, :irrigation_type, :soil_type,
      :current_season, :intended_crop, :market_condition, :dynamic_price_jd,
      :water_used, :expected_profit_jd, :recommended_crop, :target_market,
      :recommended_water, :water_saved, :recommended_profit_jd,
      :net_profit_difference_jd, CAST(:raw_row AS JSONB)
    )
    """
)

def _val(row: dict, key: str, colmap: dict[str, str]):
    if key not in colmap:
        return None
    v = row.get(colmap[key])
    if pd.isna(v):
        return None
    return v


def _float(row: dict, key: str, colmap: dict[str, str]):
    if key not in colmap:
        return None
    v = row.get(colmap[key])
    if pd.isna(v):
        return None
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def ensure_sqlite_schema(conn: Connection) -> None:
    conn.execute(
        text(
            """
            CREATE TABLE IF NOT EXISTS dataset_imports (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              file_name TEXT,
              row_count INTEGER,
              imported_at TEXT DEFAULT CURRENT_TIMESTAMP,
              notes TEXT
            )
            """
        )
    )
    conn.execute(
        text(
            """
            CREATE TABLE IF NOT EXISTS ai_recommendations (
              id TEXT PRIMARY KEY,
              import_id INTEGER REFERENCES dataset_imports(id),
              location TEXT NOT NULL,
              area_dunum REAL,
              irrigation_type TEXT,
              soil_type TEXT,
              current_season TEXT,
              intended_crop TEXT,
              market_condition TEXT,
              dynamic_price_jd REAL,
              water_used REAL,
              expected_profit_jd REAL,
              recommended_crop TEXT,
              target_market TEXT,
              recommended_water REAL,
              water_saved REAL,
              recommended_profit_jd REAL,
              net_profit_difference_jd REAL,
              raw_row TEXT,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
            """
        )
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--dsn", type=str, help="PostgreSQL connection URL")
    parser.add_argument("--sqlite", type=Path, help="مسار ملف SQLite")
    parser.add_argument("--batch", type=str, default="Baidar_AI_Dataset_2024")
    args = parser.parse_args()

    if not args.csv.is_file():
        print(f"ملف غير موجود: {args.csv}", file=sys.stderr)
        sys.exit(1)
    if not args.dsn and not args.sqlite:
        print("حدد --dsn أو --sqlite", file=sys.stderr)
        sys.exit(1)

    df = pd.read_csv(args.csv, encoding="utf-8", on_bad_lines="skip")
    colmap = normalize_columns(list(df.columns))

    if "location" not in colmap:
        print("خطأ: لم يُعثر على عمود الموقع. الأعمدة:", list(df.columns), file=sys.stderr)
        sys.exit(1)

    is_pg = bool(args.dsn)
    url = args.dsn if is_pg else f"sqlite:///{args.sqlite.as_posix()}"
    engine = create_engine(url)

    import uuid

    with engine.begin() as conn:
        if not is_pg:
            ensure_sqlite_schema(conn)

        r = conn.execute(
            text(
                "INSERT INTO dataset_imports (name, file_name, row_count, notes) "
                "VALUES (:name, :file, :cnt, :notes) RETURNING id"
                if is_pg
                else "INSERT INTO dataset_imports (name, file_name, row_count, notes) "
                "VALUES (:name, :file, :cnt, :notes)"
            ),
            {
                "name": args.batch,
                "file": args.csv.name,
                "cnt": len(df),
                "notes": "seed_from_csv",
            },
        )
        if is_pg:
            import_id = r.scalar_one()
        else:
            import_id = conn.execute(text("SELECT last_insert_rowid()")).scalar()

        for _, row in df.iterrows():
            rd = row.to_dict()
            raw = json.dumps({str(k): (None if pd.isna(v) else v) for k, v in rd.items()})
            params = {
                "import_id": import_id,
                "location": str(_val(rd, "location", colmap) or "").strip(),
                "area_dunum": _float(rd, "area_dunum", colmap),
                "irrigation_type": _val(rd, "irrigation_type", colmap),
                "soil_type": _val(rd, "soil_type", colmap),
                "current_season": _val(rd, "current_season", colmap),
                "intended_crop": _val(rd, "intended_crop", colmap),
                "market_condition": _val(rd, "market_condition", colmap),
                "dynamic_price_jd": _float(rd, "dynamic_price_jd", colmap),
                "water_used": _float(rd, "water_used", colmap),
                "expected_profit_jd": _float(rd, "expected_profit_jd", colmap),
                "recommended_crop": _val(rd, "recommended_crop", colmap),
                "target_market": _val(rd, "target_market", colmap),
                "recommended_water": _float(rd, "recommended_water", colmap),
                "water_saved": _float(rd, "water_saved", colmap),
                "recommended_profit_jd": _float(rd, "recommended_profit_jd", colmap),
                "net_profit_difference_jd": _float(rd, "net_profit_difference_jd", colmap),
                "raw_row": raw,
            }
            if not is_pg:
                conn.execute(
                    text(
                        """
                        INSERT INTO ai_recommendations (
                          id, import_id, location, area_dunum, irrigation_type, soil_type,
                          current_season, intended_crop, market_condition, dynamic_price_jd,
                          water_used, expected_profit_jd, recommended_crop, target_market,
                          recommended_water, water_saved, recommended_profit_jd,
                          net_profit_difference_jd, raw_row
                        ) VALUES (
                          :id, :import_id, :location, :area_dunum, :irrigation_type, :soil_type,
                          :current_season, :intended_crop, :market_condition, :dynamic_price_jd,
                          :water_used, :expected_profit_jd, :recommended_crop, :target_market,
                          :recommended_water, :water_saved, :recommended_profit_jd,
                          :net_profit_difference_jd, :raw_row
                        )
                        """
                    ),
                    {**params, "id": str(uuid.uuid4())},
                )
            else:
                conn.execute(insert_sql, params)

    print(f"تم إدراج {len(df)} صف، import_id={import_id}")


if __name__ == "__main__":
    main()
