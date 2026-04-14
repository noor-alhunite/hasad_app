import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/language_provider.dart';
import '../auth/onboarding_screen.dart';

/// تقييمات وهمية للعرض — تُستبدل لاحقاً ببيانات الخادم.
const List<({String name, int rating, String comment, String date})>
    _mockTraderReviews = [
  (
    name: 'مزارع محمد',
    rating: 4,
    comment: 'تعامل راقي وسعر عادل',
    date: 'أمس',
  ),
  (
    name: 'مزارع خالد',
    rating: 5,
    comment: 'شحن سريع وتغليف ممتاز',
    date: '10 أبريل 2026',
  ),
  (
    name: 'مصنع الحبوب',
    rating: 4,
    comment: 'تعاون مهني في الصفقات الكبيرة',
    date: 'مارس 2026',
  ),
];

double _averageRating(Iterable<int> ratings) {
  final list = ratings.toList();
  if (list.isEmpty) return 0;
  return list.reduce((a, b) => a + b) / list.length;
}

class TraderProfileScreen extends StatelessWidget {
  const TraderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.2).round()),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.store, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'محمد الشمري',
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
                    child: const Text(
                      'تاجر',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(value: '45', label: 'صفقة'),
                      _Stat(
                          value: user?.rating?.toString() ?? '4.5',
                          label: 'التقييم'),
                      _Stat(
                          value: user?.reviewCount?.toString() ?? '8',
                          label: 'تقييم'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Section(
                    title: 'معلومات الاتصال',
                    icon: Icons.contact_phone,
                    children: [
                      _Row(
                          icon: Icons.phone,
                          label: user?.phoneNumber ?? '+966 55 987 6543'),
                      _Row(
                          icon: Icons.email,
                          label: user?.email ?? 'trader@example.com'),
                      _Row(
                          icon: Icons.location_on,
                          label: user?.location ??
                              'جدة، المملكة العربية السعودية'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'التقييمات',
                    icon: Icons.star,
                    iconColor: AppColors.primaryGreen,
                    trailing: TextButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('التقييمات',
                                textAlign: TextAlign.right),
                            content: const SingleChildScrollView(
                              child: Text(
                                'عرض كامل للتقييمات سيتم ربطه بالخادم لاحقاً.\n\n'
                                'حالياً يمكنك الاطلاع على آخر التقييمات في الأسفل.',
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
                      _AverageRatingSummary(
                        average:
                            _averageRating(_mockTraderReviews.map((e) => e.rating)),
                        count: _mockTraderReviews.length,
                      ),
                      const SizedBox(height: 12),
                      _ReviewItem(
                        name: _mockTraderReviews[0].name,
                        rating: _mockTraderReviews[0].rating,
                        comment: _mockTraderReviews[0].comment,
                        date: _mockTraderReviews[0].date,
                      ),
                      const Divider(height: 16),
                      _ReviewItem(
                        name: _mockTraderReviews[1].name,
                        rating: _mockTraderReviews[1].rating,
                        comment: _mockTraderReviews[1].comment,
                        date: _mockTraderReviews[1].date,
                      ),
                      const Divider(height: 16),
                      _ReviewItem(
                        name: _mockTraderReviews[2].name,
                        rating: _mockTraderReviews[2].rating,
                        comment: _mockTraderReviews[2].comment,
                        date: _mockTraderReviews[2].date,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'الإعدادات',
                    icon: Icons.settings,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Switch(
                            value: langProvider.isArabic,
                            onChanged: (_) => langProvider.toggleLanguage(),
                            activeThumbColor: const Color(0xFF1565C0),
                          ),
                          Row(
                            children: const [
                              Text('اللغة',
                                  style: TextStyle(
                                      fontFamily: 'Cairo', fontSize: 14)),
                              SizedBox(width: 8),
                              Icon(Icons.language,
                                  color: AppColors.grey, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                        children: const [
                          Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.logout, color: AppColors.error, size: 20),
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

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.white.withAlpha((255 * 0.8).round()))),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final Color iconColor;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
    this.iconColor = const Color(0xFF1565C0),
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
              offset: const Offset(0, 2))
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
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, children: children),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Row({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary))),
          const SizedBox(width: 8),
          Icon(icon, color: const Color(0xFF1565C0), size: 18),
        ],
      ),
    );
  }
}

class _AverageRatingSummary extends StatelessWidget {
  final double average;
  final int count;

  const _AverageRatingSummary({
    required this.average,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final rounded = (average * 10).round() / 10;
    final fullStars = rounded.floor().clamp(0, 5);
    final hasHalf = (rounded - fullStars) >= 0.5 && fullStars < 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withAlpha((255 * 0.35).round()),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'متوسط التقييم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$count تقييم',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                rounded.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  for (var i = 0; i < fullStars; i++)
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  if (hasHalf)
                    const Icon(Icons.star_half, size: 16, color: Colors.amber),
                  for (var i = 0;
                      i <
                          5 -
                              fullStars -
                              (hasHalf ? 1 : 0);
                      i++)
                    const Icon(Icons.star_border, size: 16, color: Colors.amber),
                ],
              ),
            ],
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
