"""
أسماء أعمدة متوقعة في CSV — تُطابق أول عمود موجود (case-insensitive).
عدّل القوائم إذا كان ملفك يستخدم أسماء مختلفة.
"""

from __future__ import annotations

ALIASES: dict[str, list[str]] = {
    "location": [
        "location",
        "الموقع",
        "Region",
        "Governorate",
        "المحافظة",
        "Area_Name",
    ],
    "area_dunum": [
        "area_dunum",
        "Area_Dunum",
        "area",
        "المساحة",
        "دونم",
        "Land_Area_Dunum",
    ],
    "irrigation_type": [
        "irrigation_type",
        "Irrigation_Type",
        "نوع الري",
        "Irrigation",
    ],
    "soil_type": [
        "soil_type",
        "Soil_Type",
        "نوع التربة",
        "Soil",
    ],
    "current_season": [
        "current_season",
        "Current_Season",
        "الموسم",
        "Season",
    ],
    "intended_crop": [
        "intended_crop",
        "Intended_Crop",
        "المحصول المقصود",
        "Current_Crop",
        "Planned_Crop",
    ],
    "market_condition": [
        "market_condition",
        "Market_Condition",
        "Market_Status",
        "حالة السوق",
        "supply_risk",
        "Oversupply_Risk",
    ],
    "dynamic_price_jd": [
        "dynamic_price_jd",
        "Dynamic_Price_JD",
        "السعر",
        "Price_JD",
    ],
    "water_used": [
        "water_used",
        "Water_Used",
        "كمية المياه",
        "Water_Usage_m3",
    ],
    "expected_profit_jd": [
        "expected_profit_jd",
        "Expected_Profit_JD",
        "الربح المتوقع",
        "Net_Profit_Current",
    ],
    "recommended_crop": [
        "recommended_crop",
        "Recommended_Crop",
        "المحصول المُوصى به",
        "AI_Recommended_Crop",
    ],
    "target_market": [
        "target_market",
        "Target_Market",
        "السوق المستهدف",
    ],
    "recommended_water": [
        "recommended_water",
        "Recommended_Water",
        "كمية المياه الموصى بها",
    ],
    "water_saved": [
        "water_saved",
        "Water_Saved",
        "المياه الموفرة",
    ],
    "recommended_profit_jd": [
        "recommended_profit_jd",
        "Recommended_Profit_JD",
        "الربح الموصى به",
    ],
    "net_profit_difference_jd": [
        "net_profit_difference_jd",
        "Net_Profit_Difference_JD",
        "الفرق في الربح",
        "Profit_Delta_JD",
    ],
}


def normalize_columns(columns: list[str]) -> dict[str, str]:
    """يعيد mapping من المفتاح المنطقي إلى اسم العمود الفعلي في الملف."""
    lower_map = {c.lower().strip(): c for c in columns}
    resolved: dict[str, str] = {}
    for key, names in ALIASES.items():
        for name in names:
            n = name.lower().strip()
            if n in lower_map:
                resolved[key] = lower_map[n]
                break
    return resolved
