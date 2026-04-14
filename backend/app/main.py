"""
واجهة FastAPI لتوصيات حصاد — مصدر البيانات: CSV أو PostgreSQL.
تشغيل من مجلد backend:
  set HASAD_CSV_PATH=data\\sample_baidar.csv
  uvicorn app.main:app --reload --app-dir .
أو مع قاعدة بيانات:
  set DATABASE_URL=postgresql://user:pass@localhost:5432/hasad
"""
from __future__ import annotations

from functools import lru_cache
from pathlib import Path

import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import create_engine

from app.recommendation_service import RecommendationResult, best_from_dataframe, best_from_postgres


class Settings(BaseSettings):
    """متغيرات البيئة: HASAD_CSV_PATH، DATABASE_URL."""

    hasad_csv_path: str | None = None
    database_url: str | None = None

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


@lru_cache
def get_settings() -> Settings:
    return Settings()


@lru_cache
def get_dataframe() -> pd.DataFrame | None:
    s = get_settings()
    if not s.hasad_csv_path:
        return None
    p = Path(s.hasad_csv_path)
    if not p.is_file():
        return None
    return pd.read_csv(p, encoding="utf-8", on_bad_lines="skip")


@lru_cache
def get_engine():
    s = get_settings()
    if not s.database_url:
        return None
    return create_engine(s.database_url, pool_pre_ping=True)


app = FastAPI(title="حصاد — توصيات ذكية", version="0.1.0")


class RecommendationRequest(BaseModel):
    location: str = Field(..., description="المحافظة أو المنطقة")
    soil_type: str | None = None
    irrigation_type: str | None = None
    current_season: str | None = None
    intended_crop: str | None = None


class RecommendationResponse(BaseModel):
    recommended_crop: str | None
    expected_profit_jd: float | None = Field(None, description="الربح الموصى به")
    water_saved: float | None
    target_market: str | None
    net_profit_difference_jd: float | None
    matched_rows: int


def _to_response(r: RecommendationResult) -> RecommendationResponse:
    return RecommendationResponse(
        recommended_crop=r.recommended_crop,
        expected_profit_jd=r.recommended_profit_jd,
        water_saved=r.water_saved,
        target_market=r.target_market,
        net_profit_difference_jd=r.net_profit_difference_jd,
        matched_rows=r.matched_rows,
    )


@app.get("/health")
def health():
    return {"status": "ok", "csv": bool(get_dataframe()), "db": bool(get_engine())}


@app.post("/api/v1/recommendations/match", response_model=RecommendationResponse)
def match_recommendation(body: RecommendationRequest):
    eng = get_engine()
    try:
        if eng is not None:
            res = best_from_postgres(
                eng,
                location=body.location,
                soil_type=body.soil_type,
                irrigation_type=body.irrigation_type,
                current_season=body.current_season,
                intended_crop=body.intended_crop,
            )
        else:
            df = get_dataframe()
            if df is None:
                raise HTTPException(
                    status_code=503,
                    detail="لم يُضبط مصدر بيانات. عيّن HASAD_CSV_PATH أو DATABASE_URL.",
                )
            res = best_from_dataframe(
                df,
                location=body.location,
                soil_type=body.soil_type,
                irrigation_type=body.irrigation_type,
                current_season=body.current_season,
                intended_crop=body.intended_crop,
            )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e

    if res.matched_rows == 0:
        raise HTTPException(status_code=404, detail="لا سجلات مطابقة لهذه المدخلات.")
    return _to_response(res)


# تسهيل التشغيل: `python -m app.main` غير مستخدم؛ يُفضّل uvicorn.
