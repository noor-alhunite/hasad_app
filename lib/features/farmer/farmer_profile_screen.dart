import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/season_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/shell_tab_bridge.dart';
import '../../core/providers/factory_contract_provider.dart';
import '../auth/onboarding_screen.dart';
import 'edit_profile_screen.dart';
import 'previous_seasons_screen.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<UserProvider>().currentUser;
    final seasonProvider = context.watch<SeasonProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final seasons =
        user != null ? seasonProvider.getSeasonsForFarmer(user.id) : [];
    final factoryQuality = user != null
        ? context.watch<FactoryContractProvider>().farmerQualityStats()[user.id]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 32,
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.2).round()),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.person, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'أحمد محمد',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.roleDisplayName ?? l10n.farmer,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'تعديل الملف الشخصي',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PreviousSeasonsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'عرض المواسم السابقة',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(
                        value: seasons.length.toString(),
                        label: l10n.seasons_count,
                      ),
                      _ProfileStat(
                        value: user?.rating?.toString() ?? '4.8',
                        label: l10n.rating,
                      ),
                      _ProfileStat(
                        value: user?.reviewCount?.toString() ?? '12',
                        label: l10n.reviews,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Contact Info
                  _ProfileSection(
                    title: l10n.contactInfo,
                    icon: Icons.contact_phone,
                    children: [
                      _InfoRow(
                        icon: Icons.phone,
                        label: user?.phoneNumber ?? '+966 50 123 4567',
                      ),
                      _InfoRow(
                        icon: Icons.email,
                        label: user?.email ?? 'ahmed@example.com',
                      ),
                      _InfoRow(
                        icon: Icons.location_on,
                        label: user?.location ??
                            'الرياض، المملكة العربية السعودية',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Previous Seasons
                  _ProfileSection(
                    title: l10n.previousSeasons,
                    icon: Icons.history,
                    children: [
                      if (seasons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            l10n.no_seasons,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        ...seasons.map((s) => _SeasonRow(
                              cropType: s.cropType,
                              area: '${s.area} ${s.areaUnit}',
                              date: '${s.plantingDate.year}',
                              quality: s.qualityDisplayName,
                            )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reviews
                  _ProfileSection(
                    title: l10n.reviews,
                    icon: Icons.star,
                    trailing: TextButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('التقييمات', textAlign: TextAlign.right),
                            content: const SingleChildScrollView(
                              child: Text(
                                'عرض كامل للتقييمات سيتم ربطه بالخادم لاحقاً.\n\n'
                                'حالياً يمكنك الاطلاع على آخر تقييمين في الأسفل.',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('حسناً'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('عرض التقييمات'),
                    ),
                    children: [
                      if (factoryQuality != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'متوسط جودة التوريد للمصانع: ${factoryQuality.avgStars.toStringAsFixed(1)} '
                            'من 5 (${factoryQuality.count} دفعة مستلمة)',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      _ReviewItem(
                        name: 'محمد الشمري',
                        rating: 5,
                        comment: 'مزارع ممتاز، محصول طازج وعالي الجودة',
                        date: l10n.yesterday,
                      ),
                      const Divider(height: 16),
                      _ReviewItem(
                        name: 'أحمد العتيبي',
                        rating: 4,
                        comment: 'تعامل جيد وسريع في التوصيل',
                        date: l10n.yesterday,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Settings
                  _ProfileSection(
                    title: l10n.settings,
                    icon: Icons.settings,
                    children: [
                      // Language Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Switch(
                            value: langProvider.isArabic,
                            onChanged: (v) => langProvider.toggleLanguage(),
                            activeThumbColor: AppColors.primaryGreen,
                          ),
                          Row(
                            children: [
                              Text(
                                langProvider.isArabic
                                    ? l10n.arabic
                                    : l10n.english,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.language,
                                  color: AppColors.grey, size: 20),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 8),
                      _SettingsRow(
                        icon: Icons.description,
                        label: l10n.documents,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ستُعرض الوثائق من لوحة التحقق لاحقاً'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 8),
                      _SettingsRow(
                        icon: Icons.notifications_outlined,
                        label: l10n.notificationsTitle,
                        onTap: () =>
                            context.read<ShellTabBridge>().goToTab(5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logout
                  GestureDetector(
                    onTap: () {
                      context.read<UserProvider>().logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OnboardingScreen()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppColors.error.withAlpha((255 * 0.3).round())),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.logout,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.logout,
                              color: AppColors.error, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white.withAlpha((255 * 0.8).round()),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (trailing != null) trailing!,
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: AppColors.primaryGreen, size: 20),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
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
          const SizedBox(width: 8),
          Icon(icon, color: AppColors.primaryGreen, size: 18),
        ],
      ),
    );
  }
}

class _SeasonRow extends StatelessWidget {
  final String cropType;
  final String area;
  final String date;
  final String quality;

  const _SeasonRow({
    required this.cropType,
    required this.area,
    required this.date,
    required this.quality,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              quality,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Text(
            '$area - $date',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            cropType,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  final String date;

  const _ReviewItem({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          comment,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.grey),
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: AppColors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
