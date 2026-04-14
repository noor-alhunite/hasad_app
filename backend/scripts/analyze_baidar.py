#!/usr/bin/env python3
"""
تحليل ملف Baidar_AI_Dataset_2024 (أو أي CSV بنفس المنطق).
تشغيل: python scripts/analyze_baidar.py --csv ../data/Baidar_AI_Dataset_2024.csv
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import pandas as pd

# مسار الاستيراد من مجلد scripts
_ROOT = Path(__file__).resolve().parents[1]
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from app.column_aliases import normalize_columns  # noqa: E402


def _series(df: pd.DataFrame, key: str, colmap: dict[str, str]) -> pd.Series:
    if key not in colmap:
        return pd.Series(dtype=object)
    return df[colmap[key]].astype(str).str.strip()


def _numeric(df: pd.DataFrame, key: str, colmap: dict[str, str]) -> pd.Series:
    if key not in colmap:
        return pd.Series(dtype=float)
    return pd.to_numeric(df[colmap[key]], errors="coerce")


def main() -> None:
    parser = argparse.ArgumentParser(description="تحليل بيانات Baidar / حصاد")
    parser.add_argument("--csv", required=True, type=Path, help="مسار ملف CSV")
    args = parser.parse_args()

    if not args.csv.is_file():
        print(f"الملف غير موجود: {args.csv}", file=sys.stderr)
        sys.exit(1)

    df = pd.read_csv(args.csv, encoding="utf-8", on_bad_lines="skip")
    colmap = normalize_columns(list(df.columns))

    missing = [k for k in ("location", "intended_crop", "net_profit_difference_jd") if k not in colmap]
    if missing:
        print(
            "تحذير: أعمدة مفقودة بعد المطابقة:",
            missing,
            "\nالأعمدة في الملف:",
            list(df.columns),
            file=sys.stderr,
        )

    loc = _series(df, "location", colmap)
    intended = _series(df, "intended_crop", colmap)
    market = _series(df, "market_condition", colmap)
    profit_delta = _numeric(df, "net_profit_difference_jd", colmap)
    rec_crop = _series(df, "recommended_crop", colmap)
    expected = _numeric(df, "expected_profit_jd", colmap)

    print("=== عدد السجلات ===")
    print(len(df))

    print("\n=== أكثر المحاصيل شيوعاً (المحصول المقصود) ===")
    if not intended.empty:
        print(intended.value_counts().head(15).to_string())
    else:
        print("(لا يوجد عمود محصول مقصود)")

    print("\n=== أكثر المناطق إنتاجية (مجموع الربح المتوقع الحالي) ===")
    if not loc.empty and not expected.empty:
        by_loc = df.assign(_loc=loc, _exp=expected).groupby("_loc")["_exp"].sum().sort_values(ascending=False)
        print(by_loc.head(15).to_string())
    else:
        print("(يتطلب أعمدة الموقع والربح المتوقع)")

    print("\n=== محاصيل ترتبط بسجلات «خطر فائض» (حسب نص حالة السوق) ===")
    if not market.empty and not intended.empty:
        risk_mask = market.str.contains(
            "فائض|oversupply|glut|surplus|risk|خطر",
            case=False,
            na=False,
            regex=True,
        )
        if risk_mask.any() and "intended_crop" in colmap:
            ic = colmap["intended_crop"]
            print(df.loc[risk_mask, ic].value_counts().head(15).to_string())
        else:
            print("لم يُعثر على قيم مطابقة لنمط الخطر — راجع قيم عمود حالة السوق في الملف.")
            print("أكثر القيم شيوعاً:")
            print(market.value_counts().head(10).to_string())
    else:
        print("(يتطلب أعمدة السوق والمحصول)")

    print("\n=== إجمالي الربح الإضافي (مجموع Net_Profit_Difference_JD) ===")
    if profit_delta.notna().any():
        total = profit_delta.fillna(0).sum()
        print(f"{total:,.2f} دينار")
    else:
        print("(عمود الفرق غير متاح)")

    print("\n=== أفضل توصيات محصول (حسب عدد السجلات) ===")
    if not rec_crop.empty:
        print(rec_crop.value_counts().head(10).to_string())


if __name__ == "__main__":
    main()
