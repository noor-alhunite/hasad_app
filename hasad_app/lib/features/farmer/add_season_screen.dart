import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/models/season_model.dart';
import '../../core/providers/crop_provider.dart';
import '../../core/providers/season_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';

class AddSeasonScreen extends StatefulWidget {
  const AddSeasonScreen({super.key});

  @override
  State<AddSeasonScreen> createState() => _AddSeasonScreenState();
}

class _AddSeasonScreenState extends State<AddSeasonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _productionController = TextEditingController();
  final _fertilizerController = TextEditingController();
  final _pesticideController = TextEditingController();

  String? _selectedCrop;
  String? _selectedVariety;
  String _selectedAreaUnit = 'دونم';
  String _selectedQuality = 'excellent';
  DateTime? _plantingDate;
  DateTime? _harvestDate;
  bool _isLoading = false;
  final List<String> _imagePaths = [];
  String _locationLabel = 'عمان — اضغط لتحديد الموقع على الخريطة';
  double _latitude = 31.9539;
  double _longitude = 35.9106;

  bool get _canSave {
    if (_selectedCrop == null) return false;
    if (_selectedVariety == null || _selectedVariety!.trim().isEmpty) {
      return false;
    }
    if (_areaController.text.trim().isEmpty) return false;
    if (_plantingDate == null || _harvestDate == null) return false;
    return true;
  }

  @override
  void dispose() {
    _areaController.dispose();
    _productionController.dispose();
    _fertilizerController.dispose();
    _pesticideController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isPlanting) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isPlanting) {
          _plantingDate = picked;
        } else {
          _harvestDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.selectDate;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickLocationSheet(AppLocalizations l10n) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.setLocationOnMap,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('عمان — الجبيهة', textAlign: TextAlign.right),
                  onTap: () => Navigator.pop(ctx, 'amman'),
                ),
                ListTile(
                  title: const Text('إربد — لواء الأغوار', textAlign: TextAlign.right),
                  onTap: () => Navigator.pop(ctx, 'irbid'),
                ),
                ListTile(
                  title: const Text('المفرق — محطة تجريبية', textAlign: TextAlign.right),
                  onTap: () => Navigator.pop(ctx, 'mafraq'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null || !mounted) return;
    setState(() {
      switch (choice) {
        case 'amman':
          _locationLabel = 'عمان — الجبيهة';
          _latitude = 31.9539;
          _longitude = 35.9106;
          break;
        case 'irbid':
          _locationLabel = 'إربد — الأغوار';
          _latitude = 32.5562;
          _longitude = 35.8469;
          break;
        case 'mafraq':
          _locationLabel = 'المفرق';
          _latitude = 32.3426;
          _longitude = 36.2061;
          break;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديد: $_locationLabel')),
    );
  }

  Future<void> _pickImages() async {
    final imgs = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (!mounted || imgs.isEmpty) return;
    setState(() => _imagePaths.addAll(imgs.map((e) => e.path)));
  }

  Future<void> _saveSeason(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectCropType)),
      );
      return;
    }
    if (_selectedVariety == null || _selectedVariety!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر الصنف')),
      );
      return;
    }
    if (_plantingDate == null || _harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectDates)),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final user = context.read<UserProvider>().currentUser;
    final season = SeasonModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: user?.id ?? 'farmer_001',
      cropType: _selectedCrop!,
      cropVariety: _selectedVariety!,
      area: double.tryParse(_areaController.text) ?? 0,
      areaUnit: _selectedAreaUnit,
      plantingDate: _plantingDate!,
      expectedHarvestDate: _harvestDate!,
      expectedProduction: double.tryParse(_productionController.text) ?? 0,
      productionUnit: 'طن',
      expectedQuality: _selectedQuality,
      fertilizersUsed: _fertilizerController.text.isNotEmpty
          ? [_fertilizerController.text]
          : [],
      pesticidesUsed: _pesticideController.text.isNotEmpty
          ? [_pesticideController.text]
          : [],
      imageUrls: List<String>.from(_imagePaths),
      location: _locationLabel,
      latitude: _latitude,
      longitude: _longitude,
      status: SeasonStatus.active,
      createdAt: DateTime.now(),
    );

    context.read<SeasonProvider>().addSeason(season);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.seasonAddedSuccess),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cropProvider = context.watch<CropProvider>();
    final areaUnits = [l10n.dunum, l10n.hectare, l10n.squareMeter];
    final qualityOptions = [
      {'value': 'excellent', 'label': l10n.excellent},
      {'value': 'very_good', 'label': l10n.very_good},
      {'value': 'good', 'label': l10n.good},
      {'value': 'acceptable', 'label': l10n.acceptable},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          l10n.addNewSeason,
          style:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Section: Crop Info
              _SectionHeader(title: l10n.cropInfo, icon: Icons.grass),
              const SizedBox(height: 12),

              // Crop Type Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${l10n.cropType} *',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCrop,
                      isExpanded: true,
                      alignment: AlignmentDirectional.centerEnd,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      hint: Text(
                        l10n.selectCropType,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: AppColors.grey),
                      ),
                      items: cropProvider.cropNames.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Text(
                            crop,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        _selectedCrop = value;
                        _selectedVariety = null;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_selectedCrop != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.cropVariety,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedVariety,
                        isExpanded: true,
                        alignment: AlignmentDirectional.centerEnd,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        hint: Text(
                          l10n.cropVarietyHint,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                        items: cropProvider
                            .getVarietiesForCrop(_selectedCrop!)
                            .map(
                              (v) => DropdownMenuItem<String>(
                                value: v,
                                child: Text(
                                  v,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedVariety = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Area + Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Unit Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.unit,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 110,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAreaUnit,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: areaUnits.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo', fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedAreaUnit = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Area Input
                  Expanded(
                    child: CustomTextField(
                      label: '${l10n.area} *',
                      hint: l10n.enterArea,
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? l10n.areaRequired : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Dates
              _SectionHeader(title: l10n.dates, icon: Icons.calendar_today),
              const SizedBox(height: 12),

              // Planting Date
              _DatePickerField(
                label: '${l10n.plantingDate} *',
                value: _formatDate(_plantingDate, l10n),
                onTap: () => _selectDate(true),
                isPlaceholder: _plantingDate == null,
              ),
              const SizedBox(height: 16),

              // Harvest Date
              _DatePickerField(
                label: '${l10n.expectedHarvestDate} *',
                value: _formatDate(_harvestDate, l10n),
                onTap: () => _selectDate(false),
                isPlaceholder: _harvestDate == null,
              ),
              const SizedBox(height: 24),

              // Section: Production
              _SectionHeader(
                  title: l10n.productionAndQuality, icon: Icons.inventory),
              const SizedBox(height: 12),

              // Expected Production
              CustomTextField(
                label: l10n.expectedProduction,
                hint: l10n.expectedProductionHint,
                controller: _productionController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Quality Grade
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.expectedQuality,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: qualityOptions.map((option) {
                      final isSelected = _selectedQuality == option['value'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedQuality = option['value']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.lightGrey,
                            ),
                          ),
                          child: Text(
                            option['label']!,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Additional Info
              _SectionHeader(
                  title: l10n.additionalInfo, icon: Icons.info_outline),
              const SizedBox(height: 12),

              // Fertilizer
              CustomTextField(
                label: l10n.fertilizerType,
                hint: l10n.fertilizerHint,
                controller: _fertilizerController,
              ),
              const SizedBox(height: 16),

              // Pesticide
              CustomTextField(
                label: l10n.pesticidesUsed,
                hint: l10n.pesticidesHint,
                controller: _pesticideController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Upload Images
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightGrey,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined,
                        size: 40, color: AppColors.grey),
                    const SizedBox(height: 8),
                    Text(
                      l10n.uploadImages,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.uploadImagesHint,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_imagePaths.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'تم اختيار ${_imagePaths.length} صورة',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate, size: 18),
                      label: Text(
                        l10n.uploadImage,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Location
              Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _pickLocationSheet(l10n),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location,
                            color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _locationLabel,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          l10n.setLocationOnMap,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on,
                            color: AppColors.primaryGreen, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: l10n.saveAndPublish,
                onPressed: !_canSave || _isLoading ? null : () => _saveSeason(l10n),
                isLoading: _isLoading,
                icon: Icons.check,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: l10n.cancel,
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 18),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isPlaceholder;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppColors.grey, size: 18),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color:
                        isPlaceholder ? AppColors.grey : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
