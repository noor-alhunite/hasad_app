import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import '../farmer/farmer_main_screen.dart';
import '../trader/trader_main_screen.dart';
import '../factory/factory_main_screen.dart';
import 'otp_phone_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Define hardcoded credentials
    const farmerEmail = 'farmer@hasad.com';
    const farmerPass = '123456';
    const traderEmail = 'trader@hasad.com';
    const traderPass = '123456';
    const factoryEmail = 'factory@hasad.com';
    const factoryPass = '123456';

    bool isAuthenticated = false;
    Widget? destination;

    // Validate credentials based on the role passed from OnboardingScreen
    if (widget.role == 'FARMER' &&
        email == farmerEmail &&
        password == farmerPass) {
      isAuthenticated = true;
      context.read<UserProvider>().loginAsFarmer();
      destination = const FarmerMainScreen();
    } else if (widget.role == 'TRADER' &&
        email == traderEmail &&
        password == traderPass) {
      isAuthenticated = true;
      context.read<UserProvider>().loginAsTrader();
      destination = const TraderMainScreen();
    } else if (widget.role == 'FACTORY' &&
        email == factoryEmail &&
        password == factoryPass) {
      isAuthenticated = true;
      context.read<UserProvider>().loginAsFactory();
      destination = const FactoryMainScreen();
    }

    if (isAuthenticated && mounted && destination != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
        ),
      );
    }
  }

  UserRole _roleEnum() {
    return switch (widget.role) {
      'FARMER' => UserRole.farmer,
      'TRADER' => UserRole.trader,
      'FACTORY' => UserRole.factory,
      _ => UserRole.farmer,
    };
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'FARMER':
        return 'مزارع';
      case 'TRADER':
        return 'تاجر';
      case 'FACTORY':
        return 'مصنع';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.person, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'تسجيل دخول ${_getRoleName(widget.role)}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ادخل بيانات دخولك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),
                // Email Field
                CustomTextField(
                  label: 'البريد الإلكتروني',
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: AppColors.grey),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'البريد الإلكتروني مطلوب';
                    if (!value.contains('@'))
                      return 'البريد الإلكتروني غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password Field
                CustomTextField(
                  label: 'كلمة المرور',
                  hint: '••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: AppColors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'كلمة المرور مطلوبة';
                    if (value.length < 6)
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم إرسال رابط استعادة كلمة المرور لاحقاً'),
                        ),
                      );
                    },
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryGreen,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Login Button
                Consumer<UserProvider>(
                  builder: (context, provider, _) {
                    return CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: _login,
                      isLoading: provider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtpPhoneScreen(role: widget.role),
                      ),
                    );
                  },
                  child: const Text(
                    'دخول برمز التحقق عبر الجوال',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SignupScreen(initialRole: _roleEnum()),
                          ),
                        );
                      },
                      child: const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
