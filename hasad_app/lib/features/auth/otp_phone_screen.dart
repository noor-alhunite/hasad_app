import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'verification_screen.dart';

/// تسجيل دخول سريع برقم الجوال وOTP (ربط مع [VerificationScreen]).
class OtpPhoneScreen extends StatefulWidget {
  final String role;

  const OtpPhoneScreen({super.key, required this.role});

  @override
  State<OtpPhoneScreen> createState() => _OtpPhoneScreenState();
}

class _OtpPhoneScreenState extends State<OtpPhoneScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    final raw = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    if (raw.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم جوال صحيح')),
      );
      return;
    }
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            phone: raw,
            purpose: VerificationPurpose.otpLogin,
            loginRole: widget.role,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('الدخول برمز التحقق'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 16),
            CustomTextField(
              label: 'رقم الجوال',
              hint: 'مثال: 0791234567',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.grey),
              validator: (_) => null,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'إرسال رمز التحقق',
              onPressed: _loading ? null : _continue,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
