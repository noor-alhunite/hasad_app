import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/core/app_colors.dart';
import 'package:hasad_app/core/data/farmer_seasons_repository.dart';
import 'package:hasad_app/core/models/season_model.dart';
import 'package:hasad_app/core/providers/season_provider.dart';
import 'package:hasad_app/features/farmer/season_detail_screen.dart';
import 'package:hasad_app/features/farmer/season_status_helper.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import 'package:hasad_app/shared/helpers/crop_image_assets.dart';

/// جميع مواسم المزارع الحالي (حسب `farmerId`).
class AllFarmerSeasonsScreen extends StatelessWidget {
  final String farmerId;

  const AllFarmerSeasonsScreen({super.key, required this.farmerId});

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final seasonProvider = context.watch<SeasonProvider>();
    final seasons = getFarmerSeasonsOrdered(farmerId, seasonProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(l10n.viewAllSeasons),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: seasons.isEmpty
          ? Center(
              child: Text(
                l10n.no_seasons,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: seasons.length,
              itemBuilder: (context, index) {
                final s = seasons[index];
                return _SeasonListTile(
                  season: s,
                  plantingText: '${l10n.planting}: ${_fmt(s.plantingDate)}',
                  harvestText:
                      '${l10n.expected_harvest}: ${_fmt(s.expectedHarvestDate)}',
                  areaText: '${l10n.area_label}: ${s.area} ${s.areaUnit}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SeasonDetailScreen(season: s),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _SeasonListTile extends StatelessWidget {
  final SeasonModel season;
  final String plantingText;
  final String harvestText;
  final String areaText;
  final VoidCallback onTap;

  const _SeasonListTile({
    required this.season,
    required this.plantingText,
    required this.harvestText,
    required this.areaText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.asset(
                      resolveCropImageAsset(season.cropType),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/crop_default.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.agriculture_outlined,
                            color: Colors.grey.shade600,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: season.status.chipBackground(),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              season.status.localizedLabel(l10n),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: season.status.chipForeground(),
                              ),
                            ),
                          ),
                          Text(
                            season.cropType,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        areaText,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        plantingText,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        harvestText,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
