import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _location;

  @override
  void initState() {
    super.initState();
    final u = context.read<UserProvider>().currentUser;
    _name = TextEditingController(text: u?.name ?? '');
    _phone = TextEditingController(text: u?.phoneNumber ?? '');
    _location = TextEditingController(text: u?.location ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final u = context.read<UserProvider>().currentUser;
    if (u == null) return;
    context.read<UserProvider>().updateUser(
          u.copyWith(
            name: _name.text.trim(),
            phoneNumber: _phone.text.trim(),
            location: _location.text.trim(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ التعديلات')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('تعديل الملف الشخصي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomTextField(
                label: 'الاسم',
                controller: _name,
                validator: (v) =>
                    v == null || v.isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'رقم الجوال',
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'الرقم مطلوب' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'الموقع',
                controller: _location,
                validator: (v) =>
                    v == null || v.isEmpty ? 'الموقع مطلوب' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(text: 'حفظ', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
