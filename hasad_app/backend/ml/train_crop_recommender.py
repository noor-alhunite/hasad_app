#!/usr/bin/env python3
"""
تدريب Random Forest للتنبؤ بالمحصول الموصى به من خصائص الأرض/الموسم.
تشغيل من مجلد backend:
  python ml/train_crop_recommender.py --csv ../data/Baidar_AI_Dataset_2024.csv --out ml/models/crop_rf.joblib

يتطلّب أعمدة: location, soil_type, irrigation_type, current_season, recommended_crop
(أو أسماء متطابقة مع column_aliases).
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(_ROOT))

from app.column_aliases import normalize_columns  # noqa: E402


FEATURE_KEYS = ["location", "soil_type", "irrigation_type", "current_season"]
TARGET_KEY = "recommended_crop"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--out", type=Path, default=Path("ml/models/crop_rf.joblib"))
    parser.add_argument("--test-size", type=float, default=0.2)
    args = parser.parse_args()

    df = pd.read_csv(args.csv, encoding="utf-8", on_bad_lines="skip")
    colmap = normalize_columns(list(df.columns))

    for k in FEATURE_KEYS + [TARGET_KEY]:
        if k not in colmap:
            print("أعمدة ناقصة بعد المطابقة:", k, "الأعمدة:", list(df.columns), file=sys.stderr)
            sys.exit(1)

    X = df[[colmap[k] for k in FEATURE_KEYS]].astype(str)
    y = df[colmap[TARGET_KEY]].astype(str)
    mask = y.str.strip().ne("") & y.str.lower().ne("nan")
    X, y = X.loc[mask], y.loc[mask]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=args.test_size, random_state=42, stratify=y if y.nunique() > 1 else None
    )

    pre = ColumnTransformer(
        transformers=[
            (
                "cat",
                Pipeline(
                    steps=[
                        ("impute", SimpleImputer(strategy="constant", fill_value="missing")),
                        ("onehot", OneHotEncoder(handle_unknown="ignore", sparse_output=False)),
                    ]
                ),
                list(range(len(FEATURE_KEYS))),
            )
        ]
    )

    clf = RandomForestClassifier(
        n_estimators=200,
        max_depth=None,
        random_state=42,
        class_weight="balanced_subsample",
        n_jobs=-1,
    )
    pipe = Pipeline(steps=[("pre", pre), ("clf", clf)])
    pipe.fit(X_train, y_train)

    y_pred = pipe.predict(X_test)
    print(classification_report(y_test, y_pred, zero_division=0))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(
        {
            "model": pipe,
            "feature_columns": [colmap[k] for k in FEATURE_KEYS],
            "target_column": colmap[TARGET_KEY],
        },
        args.out,
    )
    print("حُفظ النموذج في:", args.out.resolve())


if __name__ == "__main__":
    main()
