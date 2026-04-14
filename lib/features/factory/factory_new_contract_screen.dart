// إنشاء عقد توريد — 5 خطوات (Stepper) للمصنع فقط.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/models/factory_contract_model.dart';
import '../../core/providers/factory_contract_provider.dart';

class FactoryNewContractScreen extends StatefulWidget {
  const FactoryNewContractScreen({super.key});

  @override
  State<FactoryNewContractScreen> createState() =>
      _FactoryNewContractScreenState();
}

class _FactoryNewContractScreenState extends State<FactoryNewContractScreen> {
  int _step = 0;

  ContactedFarmerOption? _farmer;
  final _searchCtrl = TextEditingController();
  final _newFarmerNameCtrl = TextEditingController();

  String? _product;
  String _size = 'متوسط';
  String _color = 'أحمر';
  String _ripeness = 'ناضج';
  final _extraCtrl = TextEditingController();

  ContractQuantityUnit _unit = ContractQuantityUnit.ton;
  final _qtyCtrl = TextEditingController(text: '20');
  final _priceCtrl = TextEditingController(text: '0.45');
  DateTime _expectedDelivery = DateTime(2026, 4, 25);
  final _locationCtrl = TextEditingController(
    text: 'مخازن المصنع — الدمام',
  );
  final _penaltyCtrl = TextEditingController();

  DateTime _start = DateTime(2026, 4, 1);
  DateTime _end = DateTime(2026, 8, 30);

  final List<_ScheduleRow> _scheduleRows = [
    _ScheduleRow()
      ..date = DateTime(2026, 4, 22)
      ..tonsCtrl.text = '5',
  ];

  final List<String> _nationalIdPaths = [];
  final List<String> _holdingPaths = [];
  final List<String> _leasePaths = [];
  final List<String> _extraDocPaths = [];

  static const _sizes = ['صغير', 'متوسط', 'كبير'];
  static const _colors = ['أحمر', 'أخضر', 'أصفر', 'برتقالي'];
  static const _ripenessLevels = ['ناضج', 'نصف ناضج', 'غير ناضج'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _newFarmerNameCtrl.dispose();
    _extraCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _penaltyCtrl.dispose();
    for (final r in _scheduleRows) {
      r.tonsCtrl.dispose();
    }
    super.dispose();
  }

  double get _quantityAsTons {
    final v = double.tryParse(_qtyCtrl.text.replaceAll(',', '.')) ?? 0;
    if (_unit == ContractQuantityUnit.kg) return v / 1000;
    return v;
  }

  Future<void> _pickDate(
    BuildContext context, {
    bool isStart = true,
    bool expected = false,
  }) async {
    final initial = expected
        ? _expectedDelivery
        : (isStart ? _start : _end);
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025),
      lastDate: DateTime(2032),
    );
    if (d == null) return;
    setState(() {
      if (expected) {
        _expectedDelivery = d;
      } else if (isStart) {
        _start = d;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(days: 30));
        }
      } else {
        _end = d;
      }
    });
  }

  Future<void> _pickImageInto(List<String> target) async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => target.add(x.path));
  }

  bool _validateStep() {
    switch (_step) {
      case 0:
        if (_farmer == null &&
            _newFarmerNameCtrl.text.trim().length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اختر مزارعاً أو أدخل اسماً جديداً')),
          );
          return false;
        }
        return true;
      case 1:
        if (_product == null || _product!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اختر المنتج')),
          );
          return false;
        }
        return true;
      case 2:
        final tons = _quantityAsTons;
        final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.'));
        if (tons <= 0 || price == null || price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('أدخل كمية وسعراً صحيحين')),
          );
          return false;
        }
        final sched = _buildSchedule();
        if (sched.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('أضف صفاً واحداً على الأقل لجدول التوريد')),
          );
          return false;
        }
        return true;
      case 3:
        if (_holdingPaths.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('صورة بطاقة الحيازة الزراعية إلزامية'),
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  List<SupplyScheduleEntry> _buildSchedule() {
    final out = <SupplyScheduleEntry>[];
    for (final row in _scheduleRows) {
      final t = double.tryParse(row.tonsCtrl.text.replaceAll(',', '.'));
      if (t != null && t > 0) {
        out.add(SupplyScheduleEntry(dueDate: row.date, quantityTons: t));
      }
    }
    return out;
  }

  void _submit() {
    final prov = context.read<FactoryContractProvider>();
    ContactedFarmerOption farmer;
    if (_farmer != null) {
      farmer = _farmer!;
    } else {
      final name = _newFarmerNameCtrl.text.trim();
      farmer = ContactedFarmerOption(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        lastChatPreview: 'طلب عقد جديد',
      );
    }

    prov.addPendingContract(
      farmerId: farmer.id,
      farmerName: farmer.name,
      productName: _product!,
      qualitySpecs: ContractQualitySpecs(
        sizeLabel: _size,
        colorLabel: _color,
        ripenessLabel: _ripeness,
        moistureOrExtra: _extraCtrl.text.trim(),
      ),
      totalQuantityTons: _quantityAsTons,
      pricePerKgDinar:
          double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0,
      startDate: _start,
      endDate: _end,
      supplySchedule: _buildSchedule(),
      quantityUnit: _unit,
      expectedDeliveryDate: _expectedDelivery,
      deliveryLocation: _locationCtrl.text.trim(),
      penaltyTerms: _penaltyCtrl.text.trim(),
      documentNationalIdPaths: List<String>.from(_nationalIdPaths),
      documentHoldingPaths: List<String>.from(_holdingPaths),
      documentLeasePaths: List<String>.from(_leasePaths),
      documentExtraPaths: List<String>.from(_extraDocPaths),
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم إرسال العقد للمزارع — سيظهر كطلب في المحادثات (محاكاة)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FactoryContractProvider>();
    final farmers = prov.contactedFarmers();
    final products = prov.productChoices();
    final dateFmt = DateFormat.yMMMd('ar');
    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? farmers
        : farmers
            .where((f) => f.name.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'إنشاء عقد — الخطوة ${_step + 1} من 5',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(5, (i) {
                final done = i <= _step;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFFE65100)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(
                filtered,
                products,
                dateFmt,
              ),
            ),
          ),
          _buildNavBar(),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_step > 0)
              TextButton(
                onPressed: () => setState(() => _step--),
                child: const Text('السابق', style: TextStyle(fontFamily: 'Cairo')),
              ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                if (!_validateStep()) return;
                if (_step < 4) {
                  setState(() => _step++);
                } else {
                  _submit();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
              ),
              child: Text(
                _step == 4 ? 'إرسال العقد للمزارع' : 'التالي',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    List<ContactedFarmerOption> filtered,
    List<String> products,
    DateFormat dateFmt,
  ) {
    switch (_step) {
      case 0:
        return _stepFarmer(filtered, dateFmt);
      case 1:
        return _stepQuality(products);
      case 2:
        return _stepQtyPrice(dateFmt);
      case 3:
        return _stepDocs();
      case 4:
        return _stepReview(dateFmt);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _stepFarmer(List<ContactedFarmerOption> filtered, DateFormat dateFmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'اختيار المزارع',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'بحث باسم المزارع',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ContactedFarmerOption>(
          value: _farmer != null && filtered.contains(_farmer)
              ? _farmer
              : null,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: const Text('مزارع تواصلت معه مسبقاً', textAlign: TextAlign.right),
          items: filtered
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(
                    '${f.name} — ${f.lastChatPreview}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _farmer = v;
            _newFarmerNameCtrl.clear();
          }),
        ),
        const SizedBox(height: 20),
        const Text(
          'أو إدخال اسم مزارع جديد (يُنشأ طلب ربط لاحقاً عبر المحادثات)',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _newFarmerNameCtrl,
          onChanged: (_) => setState(() => _farmer = null),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'اسم مزارع جديد',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _stepQuality(List<String> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'المنتج والجودة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _product,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'المنتج',
          ),
          items: products
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p, style: const TextStyle(fontFamily: 'Cairo')),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _product = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _size,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'الحجم',
          ),
          items: _sizes
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontFamily: 'Cairo')),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _size = v ?? 'متوسط'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _color,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'اللون',
          ),
          items: _colors
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontFamily: 'Cairo')),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _color = v ?? 'أحمر'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _ripeness,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'درجة النضج',
          ),
          items: _ripenessLevels
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontFamily: 'Cairo')),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _ripeness = v ?? 'ناضج'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _extraCtrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'مواصفات إضافية (نص حر)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _stepQtyPrice(DateFormat dateFmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'الكمية والسعر والتسليم',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),
        SegmentedButton<ContractQuantityUnit>(
          segments: const [
            ButtonSegment(
              value: ContractQuantityUnit.ton,
              label: Text('طن', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ButtonSegment(
              value: ContractQuantityUnit.kg,
              label: Text('كجم', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
          selected: {_unit},
          onSelectionChanged: (s) =>
              setState(() => _unit = s.first),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qtyCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: _unit == ContractQuantityUnit.ton
                ? 'الكمية (طن)'
                : 'الكمية (كجم)',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'سعر الوحدة (دينار/كجم)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _pickDate(context, expected: true),
          child: Text(
            'تاريخ التسليم المتوقع: ${dateFmt.format(_expectedDelivery)}',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationCtrl,
          maxLines: 2,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'مكان التسليم (مخازن المصنع / العنوان)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'مدة العقد',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(context, isStart: true),
                child: Text(
                  'البداية: ${dateFmt.format(_start)}',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(context, isStart: false),
                child: Text(
                  'النهاية: ${dateFmt.format(_end)}',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _scheduleRows.add(_ScheduleRow());
                });
              },
              icon: const Icon(Icons.add_circle, color: Color(0xFFE65100)),
            ),
            const Text(
              'جدول التوريد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        ..._scheduleRows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  if (_scheduleRows.length > 1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          row.tonsCtrl.dispose();
                          _scheduleRows.removeAt(i);
                        });
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: row.date,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2032),
                        );
                        if (d != null) setState(() => row.date = d);
                      },
                      child: Text(
                        dateFmt.format(row.date),
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 88,
                    child: TextField(
                      controller: row.tonsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'طن',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        TextField(
          controller: _penaltyCtrl,
          maxLines: 2,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'شروط جزائية (اختياري)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _stepDocs() {
    Widget row(String title, List<String> paths, VoidCallback onAdd) {
      return Card(
        child: ListTile(
          title: Text(title, textAlign: TextAlign.right),
          subtitle: Text(
            paths.isEmpty ? 'لم يُرفع بعد' : '${paths.length} ملف',
            textAlign: TextAlign.right,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: onAdd,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'المستندات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        row(
          'بطاقة الرقم القومي / الهوية (اختياري)',
          _nationalIdPaths,
          () => _pickImageInto(_nationalIdPaths),
        ),
        row(
          'بطاقة الحيازة الزراعية (إلزامي)',
          _holdingPaths,
          () => _pickImageInto(_holdingPaths),
        ),
        row(
          'عقد إيجار الأرض (اختياري)',
          _leasePaths,
          () => _pickImageInto(_leasePaths),
        ),
        row(
          'مستندات إضافية',
          _extraDocPaths,
          () => _pickImageInto(_extraDocPaths),
        ),
      ],
    );
  }

  Widget _stepReview(DateFormat dateFmt) {
    final farmerName = _farmer?.name ?? _newFarmerNameCtrl.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'مراجعة وإرسال',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),
        _reviewLine('المزارع', farmerName.isEmpty ? '—' : farmerName),
        _reviewLine('المنتج', _product ?? '—'),
        _reviewLine('الجودة', '$_size / $_color / $_ripeness'),
        if (_extraCtrl.text.isNotEmpty)
          _reviewLine('إضافي', _extraCtrl.text),
        _reviewLine(
          'الكمية',
          '${_qtyCtrl.text} ${_unit == ContractQuantityUnit.ton ? 'طن' : 'كجم'} (≈ ${_quantityAsTons.toStringAsFixed(3)} طن)',
        ),
        _reviewLine('السعر', '${_priceCtrl.text} د.أ/كجم'),
        _reviewLine('التسليم المتوقع', dateFmt.format(_expectedDelivery)),
        _reviewLine('المكان', _locationCtrl.text),
        if (_penaltyCtrl.text.isNotEmpty)
          _reviewLine('جزائية', _penaltyCtrl.text),
        const SizedBox(height: 12),
        Text(
          'المستندات: هوية ${_nationalIdPaths.length}، حيازة ${_holdingPaths.length}، إيجار ${_leasePaths.length}، أخرى ${_extraDocPaths.length}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
        ),
      ],
    );
  }

  Widget _reviewLine(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow {
  DateTime date = DateTime.now();
  final TextEditingController tonsCtrl = TextEditingController(text: '5');
}
