import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'onboarding_screen.dart';

class UnderReviewScreen extends StatelessWidget {
  const UnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 56,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'بياناتك قيد المراجعة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تم استلام بياناتك وهي قيد المراجعة من قِبل فريقنا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  children: [
                    _ReviewItem(
                      icon: Icons.badge,
                      label: 'صورة الهوية',
                      status: 'تم الرفع',
                    ),
                    const Divider(height: 16),
                    _ReviewItem(
                      icon: Icons.landscape,
                      label: 'وثائق الأرض',
                      status: 'تم الرفع',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.warning.withAlpha((255 * 0.3).round())),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'سيتم مراجعة طلبك خلال 48 ساعة وإشعارك بالنتيجة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time,
                        color: AppColors.warning, size: 28),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'متابعة',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;

  const _ReviewItem({
    required this.icon,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: AppColors.primaryGreen, size: 22),
      ],
    );
  }
}
