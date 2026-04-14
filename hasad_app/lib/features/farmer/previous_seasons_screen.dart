import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/providers/season_provider.dart';
import '../../core/providers/user_provider.dart';

class PreviousSeasonsScreen extends StatelessWidget {
  const PreviousSeasonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<UserProvider>().currentUser;
    final seasonProvider = context.watch<SeasonProvider>();
    final seasons = user != null
        ? seasonProvider.getSeasonsForFarmer(user.id)
        : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(l10n.previousSeasons),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: seasons.isEmpty
          ? Center(child: Text(l10n.no_seasons))
          : ListView.builder(
              itemCount: seasons.length,
              itemBuilder: (context, i) {
                final s = seasons[i];
                return ListTile(
                  title: Text(s.cropType, textAlign: TextAlign.right),
                  subtitle: Text(
                    '${s.area} ${s.areaUnit} — ${s.qualityDisplayName}',
                    textAlign: TextAlign.right,
                  ),
                  trailing: const Icon(Icons.grass, color: AppColors.primaryGreen),
                );
              },
            ),
    );
  }
}
