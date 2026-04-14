import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import 'under_review_screen.dart';

class DocumentsUploadScreen extends StatefulWidget {
  const DocumentsUploadScreen({super.key});

  @override
  State<DocumentsUploadScreen> createState() => _DocumentsUploadScreenState();
}

class _DocumentsUploadScreenState extends State<DocumentsUploadScreen> {
  final Map<String, bool> _uploadedDocs = {};
  bool _isLoading = false;

  List<Map<String, dynamic>> _getDocuments(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return [
          {'key': 'id', 'label': 'صورة الهوية الوطنية', 'icon': Icons.badge},
          {'key': 'land', 'label': 'وثائق ملكية الأرض', 'icon': Icons.landscape},
        ];
      case UserRole.trader:
        return [
          {'key': 'id', 'label': 'صورة الهوية الوطنية', 'icon': Icons.badge},
          {'key': 'commercial', 'label': 'السجل التجاري', 'icon': Icons.business},
        ];
      case UserRole.factory:
        return [
          {'key': 'id', 'label': 'صورة الهوية الوطنية', 'icon': Icons.badge},
          {'key': 'industrial', 'label': 'السجل الصناعي', 'icon': Icons.factory},
          {'key': 'license', 'label': 'التراخيص', 'icon': Icons.verified},
        ];
    }
  }

  int get _uploadedCount => _uploadedDocs.values.where((v) => v).length;

  bool _allRequiredUploaded(List<Map<String, dynamic>> docs) {
    for (final d in docs) {
      if (_uploadedDocs[d['key']] != true) return false;
    }
    return docs.isNotEmpty;
  }

  Future<void> _pickDocument(String key) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _uploadedDocs[key] = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار ملف للمستند: $key')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final role = user?.role ?? UserRole.farmer;
    final docs = _getDocuments(role);
    final progress = docs.isEmpty ? 0.0 : _uploadedCount / docs.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('رفع المستندات'),
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
            // Progress
            const Text(
              'تقدم الرفع',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.lightGrey,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_uploadedCount من ${docs.length} مستندات',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Documents List
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final isUploaded = _uploadedDocs[doc['key']] ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUploaded ? AppColors.primaryGreen : AppColors.lightGrey,
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _pickDocument(doc['key'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUploaded
                                  ? AppColors.lightGreen
                                  : AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isUploaded ? 'مكتمل' : 'رفع',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: isUploaded ? AppColors.primaryGreen : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              doc['label'],
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isUploaded ? 'تم الرفع' : 'مطلوب',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: isUploaded ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          doc['icon'],
                          color: isUploaded ? AppColors.primaryGreen : AppColors.grey,
                          size: 28,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'إرسال للمراجعة',
              onPressed: _allRequiredUploaded(docs)
                  ? () async {
                      setState(() => _isLoading = true);
                      await Future.delayed(const Duration(seconds: 1));
                      if (mounted) {
                        setState(() => _isLoading = false);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const UnderReviewScreen()),
                        );
                      }
                    }
                  : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
