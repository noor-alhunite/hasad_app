import 'package:flutter/material.dart';
import 'package:hasad_app/core/app_colors.dart';
import 'package:hasad_app/core/models/season_model.dart';
import 'package:hasad_app/l10n/app_localizations.dart';

extension SeasonStatusUi on SeasonStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SeasonStatus.active:
        return l10n.active;
      case SeasonStatus.inHarvest:
        return l10n.seasonInHarvest;
      case SeasonStatus.harvested:
        return l10n.seasonEnded;
      case SeasonStatus.cancelled:
        return l10n.cancelled;
    }
  }

  Color chipBackground() {
    switch (this) {
      case SeasonStatus.active:
        return AppColors.lightGreen;
      case SeasonStatus.inHarvest:
        return const Color(0xFFFFF3E0);
      case SeasonStatus.harvested:
        return const Color(0xFFF5F5F5);
      case SeasonStatus.cancelled:
        return const Color(0xFFFFEBEE);
    }
  }

  Color chipForeground() {
    switch (this) {
      case SeasonStatus.active:
        return AppColors.primaryGreen;
      case SeasonStatus.inHarvest:
        return const Color(0xFFE65100);
      case SeasonStatus.harvested:
        return AppColors.textSecondary;
      case SeasonStatus.cancelled:
        return const Color(0xFFC62828);
    }
  }
}
