import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'verification_screen.dart';
import 'onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  final UserRole? initialRole;

  const SignupScreen({super.key, this.initialRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? UserRole.farmer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<UserProvider>().signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text,
          _selectedRole,
        );

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            phone: _phoneController.text.trim(),
            purpose: VerificationPurpose.signup,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('إنشاء حساب جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Full Name
                CustomTextField(
                  label: 'الاسم الكامل *',
                  hint: 'أدخل اسمك الكامل',
                  controller: _nameController,
                  prefixIcon:
                      const Icon(Icons.person_outline, color: AppColors.grey),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'الاسم مطلوب' : null,
                ),
                const SizedBox(height: 16),
                // Email
                CustomTextField(
                  label: 'البريد الإلكتروني *',
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: AppColors.grey),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'البريد الإلكتروني مطلوب';
                    if (!v.contains('@')) return 'البريد الإلكتروني غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Phone
                CustomTextField(
                  label: 'رقم الجوال *',
                  hint: '+966 5X XXX XXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon:
                      const Icon(Icons.phone_outlined, color: AppColors.grey),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'رقم الجوال مطلوب' : null,
                ),
                const SizedBox(height: 16),
                // Password
                CustomTextField(
                  label: 'كلمة المرور *',
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                    if (v.length < 6)
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Confirm Password
                CustomTextField(
                  label: 'تأكيد كلمة المرور *',
                  hint: '••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: AppColors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.grey,
                    ),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'تأكيد كلمة المرور مطلوب';
                    if (v != _passwordController.text)
                      return 'كلمة المرور غير متطابقة';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Role Selection
                const Text(
                  'اختر دورك *',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleButton(
                        label: 'مزارع',
                        icon: Icons.agriculture,
                        isSelected: _selectedRole == UserRole.farmer,
                        onTap: () =>
                            setState(() => _selectedRole = UserRole.farmer),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleButton(
                        label: 'تاجر',
                        icon: Icons.store,
                        isSelected: _selectedRole == UserRole.trader,
                        onTap: () =>
                            setState(() => _selectedRole = UserRole.trader),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleButton(
                        label: 'مصنع',
                        icon: Icons.factory,
                        isSelected: _selectedRole == UserRole.factory,
                        onTap: () =>
                            setState(() => _selectedRole = UserRole.factory),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Consumer<UserProvider>(
                  builder: (context, provider, _) {
                    return CustomButton(
                      text: 'إنشاء حساب',
                      onPressed: _signup,
                      isLoading: provider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // go back to onboarding so user can pick a role before logging in
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()),
                        );
                      },
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGrey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.grey,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
