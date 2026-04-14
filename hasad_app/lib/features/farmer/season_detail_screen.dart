import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hasad_app/core/app_colors.dart';
import 'package:hasad_app/core/models/season_model.dart';
import 'package:hasad_app/features/farmer/season_status_helper.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import 'package:hasad_app/shared/helpers/crop_image_assets.dart';

class SeasonDetailScreen extends StatelessWidget {
  final SeasonModel season;

  const SeasonDetailScreen({super.key, required this.season});

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(l10n.seasonDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.06).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
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
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        season.cropType,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (season.cropVariety.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          season.cropVariety,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: season.status.chipBackground(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          season.status.localizedLabel(l10n),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: season.status.chipForeground(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: l10n.dates_label,
            children: [
              _infoRow(
                context,
                l10n.planting,
                _fmt(season.plantingDate),
              ),
              _infoRow(
                context,
                l10n.expected_harvest,
                _fmt(season.expectedHarvestDate),
              ),
              _infoRow(
                context,
                l10n.area_label,
                '${season.area} ${season.areaUnit}',
              ),
              _infoRow(
                context,
                l10n.location_label,
                season.location,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.productionAndQuality,
            children: [
              _infoRow(
                context,
                l10n.expectedProduction,
                '${season.expectedProduction} ${season.productionUnit}',
              ),
              _infoRow(
                context,
                l10n.qualityLabel,
                season.qualityDisplayName,
              ),
            ],
          ),
          if (season.aiAdvice != null && season.aiAdvice!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.aiRecommendations,
              children: [
                Text(
                  season.aiAdvice!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.fertilizersSection,
            children: [
              Text(
                season.fertilizersUsed.isEmpty
                    ? '—'
                    : season.fertilizersUsed.join('، '),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.pesticidesSection,
            children: [
              Text(
                season.pesticidesUsed.isEmpty
                    ? '—'
                    : season.pesticidesUsed.join('، '),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.seasonPhotos,
            children: [
              if (season.imageUrls.isEmpty)
                Text(
                  l10n.noSeasonPhotos,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: season.imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final u = season.imageUrls[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CachedNetworkImage(
                            imageUrl: u,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => ColoredBox(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
