import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../farmer/farmer_main_screen.dart';
import '../trader/trader_main_screen.dart';
import '../factory/factory_main_screen.dart';
import 'guest_main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final restored = await context.read<UserProvider>().tryRestoreSession();
      if (!restored || !mounted) return;
      final u = context.read<UserProvider>().currentUser!;
      if (u.isGuest) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GuestMainScreen()),
        );
      } else {
        _goRoleHome(context, u.role);
      }
    });
  }

  UserRole _userRoleFromKey(String key) {
    return switch (key) {
      'TRADER' => UserRole.trader,
      'FACTORY' => UserRole.factory,
      _ => UserRole.farmer,
    };
  }

  void _goRoleHome(BuildContext context, UserRole role) {
    final Widget home = switch (role) {
      UserRole.farmer => const FarmerMainScreen(),
      UserRole.trader => const TraderMainScreen(),
      UserRole.factory => const FactoryMainScreen(),
    };
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => home),
    );
  }

  void _showSanadDialog() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار دور أولاً')),
      );
      return;
    }

    final idController = TextEditingController();
    final passController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'تسجيل الدخول بواسطة سند',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: idController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'رقم الهوية',
                    hintText: '10 أرقام',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passController,
                  obscureText: true,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'كلمة السر',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            FilledButton(
              onPressed: () async {
                final id = idController.text.trim();
                if (!RegExp(r'^\d{10}$').hasMatch(id)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('رقم الهوية يجب أن يكون 10 أرقام بالضبط'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                final role = _userRoleFromKey(_selectedRole!);
                await context.read<UserProvider>().loginWithSanadMock(
                      nationalId: id,
                      role: role,
                    );
                if (mounted) _goRoleHome(context, role);
              },
              child: const Text('تأكيد', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    ).whenComplete(() {
      idController.dispose();
      passController.dispose();
    });
  }

  Future<void> _guestLogin() async {
    await context.read<UserProvider>().loginAsGuest();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GuestMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'حصاد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'منصة حصاد الزراعية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تربط المزارعين والتجار والمصانع في منصة واحدة متكاملة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white.withAlpha(217),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RoleIcon(
                      icon: Icons.agriculture,
                      label: 'مزارع',
                      isSelected: _selectedRole == 'FARMER',
                      onTap: () => setState(() => _selectedRole = 'FARMER'),
                    ),
                    _RoleIcon(
                      icon: Icons.store,
                      label: 'تاجر',
                      isSelected: _selectedRole == 'TRADER',
                      onTap: () => setState(() => _selectedRole = 'TRADER'),
                    ),
                    _RoleIcon(
                      icon: Icons.factory,
                      label: 'مصنع',
                      isSelected: _selectedRole == 'FACTORY',
                      onTap: () => setState(() => _selectedRole = 'FACTORY'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'تسجيل الدخول بواسطة سند',
                  onPressed: _showSanadDialog,
                  backgroundColor: Colors.white,
                  textColor: AppColors.primaryGreen,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _guestLogin,
                  child: Text(
                    'دخول كزائر',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.white.withAlpha(230),
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withAlpha(230),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withAlpha(38),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
