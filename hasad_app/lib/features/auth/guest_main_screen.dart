import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../marketplace/smart_map_screen.dart';
import 'onboarding_screen.dart';

/// زائر: الخريطة الذكية فقط مع شريط خروج من الجلسة.
class GuestMainScreen extends StatelessWidget {
  const GuestMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartMapScreen(
      isGuestMode: true,
      onGuestExit: () async {
        await context.read<UserProvider>().logout();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (_) => false,
          );
        }
      },
    );
  }
}
