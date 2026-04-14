import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../farmer/farmer_main_screen.dart';
import '../factory/factory_main_screen.dart';
import '../trader/trader_main_screen.dart';
import 'documents_upload_screen.dart';

enum VerificationPurpose { signup, otpLogin }

class VerificationScreen extends StatefulWidget {
  final String phone;
  final VerificationPurpose purpose;
  final String? loginRole;

  const VerificationScreen({
    super.key,
    required this.phone,
    this.purpose = VerificationPurpose.signup,
    this.loginRole,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _verifyLoading = false;
  bool _sendLoading = false;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    if (widget.purpose == VerificationPurpose.otpLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _otpSent = true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _sendOtp() async {
    if (widget.phone.trim().length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تأكد من رقم الجوال (9 أرقام على الأقل)')),
      );
      return;
    }
    setState(() => _sendLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _sendLoading = false;
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رمز التحقق (تجريبي)')),
      );
      _focusNodes.first.requestFocus();
    }
  }

  Future<void> _verify() async {
    if (!_otpSent && widget.purpose == VerificationPurpose.signup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اضغط «إرسال رمز التحقق» أولاً')),
      );
      return;
    }
    if (_otp.length != 6 || int.tryParse(_otp) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل الرمز المكوّن من 6 أرقام')),
      );
      return;
    }

    setState(() => _verifyLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _verifyLoading = false);

    if (widget.purpose == VerificationPurpose.otpLogin) {
      final role = widget.loginRole ?? 'FARMER';
      final user = context.read<UserProvider>();
      if (role == 'FARMER') {
        user.loginAsFarmer();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FarmerMainScreen()),
          (_) => false,
        );
      } else if (role == 'TRADER') {
        user.loginAsTrader();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TraderMainScreen()),
          (_) => false,
        );
      } else {
        user.loginAsFactory();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FactoryMainScreen()),
          (_) => false,
        );
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DocumentsUploadScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('رمز التحقق'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sms, size: 40, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 24),
            const Text(
              'رمز التحقق',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الرقم: ${widget.phone}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'إرسال رمز التحقق (OTP)',
              onPressed: _sendLoading || _verifyLoading ? null : _sendOtp,
              isLoading: _sendLoading,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  height: 56,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'تأكيد الرمز',
              onPressed: _sendLoading || _verifyLoading ? null : _verify,
              isLoading: _verifyLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _sendLoading || _verifyLoading
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إعادة إرسال الرمز (تجريبي)')),
                      );
                      _sendOtp();
                    },
              child: const Text(
                'إعادة إرسال الرمز',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryGreen,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
