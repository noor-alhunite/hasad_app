"""
منطق اختيار أفضل صف توصية من DataFrame أو استعلام قاعدة البيانات.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import pandas as pd
from sqlalchemy import text
from sqlalchemy.engine import Engine

from app.column_aliases import normalize_columns


@dataclass
class RecommendationResult:
    recommended_crop: str | None
    recommended_profit_jd: float | None
    water_saved: float | None
    target_market: str | None
    net_profit_difference_jd: float | None
    source_row: dict[str, Any] | None
    matched_rows: int


def _norm(s: str | None) -> str:
    if s is None:
        return ""
    return str(s).strip().lower()


def best_from_dataframe(
    df: pd.DataFrame,
    *,
    location: str,
    soil_type: str | None = None,
    irrigation_type: str | None = None,
    current_season: str | None = None,
    intended_crop: str | None = None,
) -> RecommendationResult:
    colmap = normalize_columns(list(df.columns))
    if "location" not in colmap:
        raise ValueError("CSV لا يحتوي عمود موقع يمكن تمييزه.")

    def col(key: str) -> str:
        return colmap[key]

    m = df[col("location")].astype(str).map(_norm) == _norm(location)

    if soil_type and "soil_type" in colmap:
        m &= df[col("soil_type")].astype(str).map(_norm) == _norm(soil_type)
    if irrigation_type and "irrigation_type" in colmap:
        m &= df[col("irrigation_type")].astype(str).map(_norm) == _norm(irrigation_type)
    if current_season and "current_season" in colmap:
        m &= df[col("current_season")].astype(str).map(_norm) == _norm(current_season)
    if intended_crop and "intended_crop" in colmap:
        m &= df[col("intended_crop")].astype(str).map(_norm) == _norm(intended_crop)

    sub = df.loc[m]
    if sub.empty:
        return RecommendationResult(None, None, None, None, None, None, 0)

    sort_col = None
    if "net_profit_difference_jd" in colmap:
        sort_col = colmap["net_profit_difference_jd"]
    elif "recommended_profit_jd" in colmap:
        sort_col = colmap["recommended_profit_jd"]

    if sort_col:
        sub = sub.assign(_s=pd.to_numeric(sub[sort_col], errors="coerce")).sort_values("_s", ascending=False)
    row = sub.iloc[0]

    def get_f(k: str) -> float | None:
        if k not in colmap:
            return None
        v = row.get(colmap[k])
        if pd.isna(v):
            return None
        try:
            return float(v)
        except (TypeError, ValueError):
            return None

    def get_s(k: str) -> str | None:
        if k not in colmap:
            return None
        v = row.get(colmap[k])
        if pd.isna(v):
            return None
        return str(v)

    src = row.to_dict()
    return RecommendationResult(
        recommended_crop=get_s("recommended_crop"),
        recommended_profit_jd=get_f("recommended_profit_jd"),
        water_saved=get_f("water_saved"),
        target_market=get_s("target_market"),
        net_profit_difference_jd=get_f("net_profit_difference_jd"),
        source_row=src,
        matched_rows=len(sub),
    )


def best_from_postgres(
    engine: Engine,
    *,
    location: str,
    soil_type: str | None = None,
    irrigation_type: str | None = None,
    current_season: str | None = None,
    intended_crop: str | None = None,
) -> RecommendationResult:
    sql = """
    SELECT recommended_crop, recommended_profit_jd, water_saved, target_market,
           net_profit_difference_jd, location, soil_type, irrigation_type,
           current_season, intended_crop, raw_row
    FROM ai_recommendations
    WHERE lower(trim(location)) = lower(trim(:location))
      AND (:soil IS NULL OR lower(trim(soil_type)) = lower(trim(:soil)))
      AND (:irr IS NULL OR lower(trim(irrigation_type)) = lower(trim(:irr)))
      AND (:season IS NULL OR lower(trim(current_season)) = lower(trim(:season)))
      AND (:crop IS NULL OR lower(trim(intended_crop)) = lower(trim(:crop)))
    ORDER BY net_profit_difference_jd DESC NULLS LAST
    LIMIT 1
    """
    with engine.connect() as conn:
        r = conn.execute(
            text(sql),
            {
                "location": location,
                "soil": soil_type,
                "irr": irrigation_type,
                "season": current_season,
                "crop": intended_crop,
            },
        ).mappings().first()

    if not r:
        return RecommendationResult(None, None, None, None, None, None, 0)

    cnt_sql = """
    SELECT count(*) FROM ai_recommendations
    WHERE lower(trim(location)) = lower(trim(:location))
      AND (:soil IS NULL OR lower(trim(soil_type)) = lower(trim(:soil)))
      AND (:irr IS NULL OR lower(trim(irrigation_type)) = lower(trim(:irr)))
      AND (:season IS NULL OR lower(trim(current_season)) = lower(trim(:season)))
      AND (:crop IS NULL OR lower(trim(intended_crop)) = lower(trim(:crop)))
    """
    with engine.connect() as conn:
        n = conn.execute(
            text(cnt_sql),
            {
                "location": location,
                "soil": soil_type,
                "irr": irrigation_type,
                "season": current_season,
                "crop": intended_crop,
            },
        ).scalar()

    raw = r.get("raw_row")
    src = dict(raw) if raw is not None else dict(r)

    return RecommendationResult(
        recommended_crop=r.get("recommended_crop"),
        recommended_profit_jd=float(r["recommended_profit_jd"]) if r.get("recommended_profit_jd") is not None else None,
        water_saved=float(r["water_saved"]) if r.get("water_saved") is not None else None,
        target_market=r.get("target_market"),
        net_profit_difference_jd=float(r["net_profit_difference_jd"]) if r.get("net_profit_difference_jd") is not None else None,
        source_row=src,
        matched_rows=int(n or 0),
    )
