import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/chat_inbox_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/helpers/crop_image_assets.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/chat_models.dart';
import 'price_comparison_mock.dart';

/// شاشة مقارنة الأسعار وحساب التوصيل (تاجر / مصنع).
/// خطوات: منتج → اختيار مزارع (2–4) → كمية → جدول نتائج + طلب شراء.
class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  int _step = 0;
  String? _crop;
  final Set<String> _selectedFarmerIds = {};
  final TextEditingController _qtyCtrl = TextEditingController(text: '500');
  List<PriceComparisonRow> _rows = [];

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  List<ComparisonFarmer> get _farmersForCrop {
    if (_crop == null) return [];
    return kComparisonFarmers
        .where((f) => f.priceFor(_crop!) != null)
        .toList();
  }

  void _recalculateRows() {
    final crop = _crop!;
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.')) ?? 0;
    _rows = _selectedFarmerIds
        .map((id) => kComparisonFarmers.firstWhere((f) => f.id == id))
        .map((f) => PriceComparisonRow.compute(f, crop, qty))
        .toList()
      ..sort((a, b) => a.grandTotal.compareTo(b.grandTotal));
  }

  PriceComparisonRow? get _bestRow {
    if (_rows.isEmpty) return null;
    return _rows.reduce((a, b) => a.grandTotal <= b.grandTotal ? a : b);
  }

  bool _validateStep() {
    switch (_step) {
      case 0:
        if (_crop == null) {
          _toast('اختر المنتج أولاً');
          return false;
        }
        return true;
      case 1:
        if (_selectedFarmerIds.length < 2) {
          _toast('اختر مزارعين على الأقل (حتى 4)');
          return false;
        }
        if (_selectedFarmerIds.length > 4) {
          _toast('يمكن اختيار 4 مزارع كحد أقصى');
          return false;
        }
        return true;
      case 2:
        final q = double.tryParse(_qtyCtrl.text.replaceAll(',', '.'));
        if (q == null || q <= 0) {
          _toast('أدخل كمية صحيحة بالكيلوغرام');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, textAlign: TextAlign.right)),
    );
  }

  Future<void> _sendPurchaseRequests() async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.isGuest) {
      _toast('سجّل الدخول لإرسال الطلب');
      return;
    }
    if (_rows.isEmpty || _crop == null) return;

    final inbox = context.read<ChatInboxProvider>();
    String? firstThreadId;

    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      final tid = inbox.openOrCreateThread(
        peerName: r.farmer.name,
        topicSubtitle: '${r.cropName} — ${r.farmer.governorateName}',
        avatarAssetPath: resolveCropImageAsset(r.cropName),
        viewerRole: user.role,
        peerKind: ChatPeerKind.farmer,
      );

      final msg = StringBuffer()
        ..writeln('📋 طلب شراء — من «مقارنة الأسعار»')
        ..writeln('المنتج: ${r.cropName}')
        ..writeln('الكمية المطلوبة: ${r.quantityKg.toStringAsFixed(0)} كجم')
        ..writeln('سعر الكيلو (عرض المقارنة): ${r.pricePerKg.toStringAsFixed(2)} د.أ')
        ..writeln('المسافة من عمان (تقدير): ${r.distanceKm.toStringAsFixed(1)} كم')
        ..writeln('تكلفة التوصيل (0.25×المسافة): ${r.deliveryCost.toStringAsFixed(2)} د.أ')
        ..writeln('قيمة المنتج: ${r.productTotal.toStringAsFixed(2)} د.أ')
        ..writeln('المجموع التقديري: ${r.grandTotal.toStringAsFixed(2)} د.أ');

      inbox.sendText(tid, msg.toString());
      firstThreadId ??= tid;
    }

    if (!mounted || firstThreadId == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال الطلب إلى ${_rows.length} مزارع — تفتح أول محادثة',
          textAlign: TextAlign.right,
        ),
      ),
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChatDetailScreen(threadId: firstThreadId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final best = _bestRow;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'مقارنة الأسعار والتوصيل',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _step,
        onStepContinue: () {
          if (!_validateStep()) return;
          if (_step == 2) {
            setState(() {
              _recalculateRows();
              _step = 3;
            });
            return;
          }
          if (_step < 3) {
            setState(() => _step++);
          }
        },
        onStepCancel: () {
          if (_step > 0) {
            setState(() => _step--);
          } else {
            Navigator.of(context).maybePop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_step == 0 ? 'إغلاق' : 'رجوع'),
                ),
                const SizedBox(width: 12),
                if (_step < 3)
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: Text(_step == 2 ? 'احسب وأظهر النتائج' : 'التالي'),
                  ),
              ],
            ),
          );
        },
        steps: [
          // 1) المنتج
          Step(
            title: const Text('اختيار المنتج', style: TextStyle(fontFamily: 'Cairo')),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: kComparisonCropNames.map((c) {
                  final sel = _crop == c;
                  return ChoiceChip(
                    label: Text(c, style: const TextStyle(fontFamily: 'Cairo')),
                    selected: sel,
                    onSelected: (_) => setState(() => _crop = c),
                    selectedColor: AppColors.primaryGreen.withAlpha((255 * 0.35).round()),
                  );
                }).toList(),
              ),
            ),
          ),
          // 2) المزارع
          Step(
            title: const Text('اختيار المزارع (2–4)', style: TextStyle(fontFamily: 'Cairo')),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: _crop == null
                ? const Text(
                    'اختر المنتج في الخطوة السابقة',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _farmersForCrop.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final f = _farmersForCrop[index];
                      final ppk = f.priceFor(_crop!)!;
                      final checked = _selectedFarmerIds.contains(f.id);
                      return CheckboxListTile(
                        value: checked,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              if (_selectedFarmerIds.length >= 4) {
                                _toast('الحد الأقصى 4 مزارع');
                                return;
                              }
                              _selectedFarmerIds.add(f.id);
                            } else {
                              _selectedFarmerIds.remove(f.id);
                            }
                          });
                        },
                        title: Text(
                          f.name,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${f.governorateName} — ${ppk.toStringAsFixed(2)} د.أ/كجم',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                        ),
                        secondary: const Icon(Icons.agriculture, color: AppColors.primaryGreen),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
          ),
          // 3) الكمية
          Step(
            title: const Text('الكمية المطلوبة (كجم)', style: TextStyle(fontFamily: 'Cairo')),
            isActive: _step >= 2,
            state: _step > 2 ? StepState.complete : StepState.indexed,
            content: TextField(
              controller: _qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'مثال: 500',
                border: OutlineInputBorder(),
                prefixText: 'كجم ',
              ),
            ),
          ),
          // 4) النتائج
          Step(
            title: const Text('النتائج والتوصية', style: TextStyle(fontFamily: 'Cairo')),
            isActive: _step >= 3,
            state: _step == 3 ? StepState.complete : StepState.indexed,
            content: _step >= 3
                ? _buildResultsTable(best)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable(PriceComparisonRow? best) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
            columns: const [
              DataColumn(label: Text('المزارع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
              DataColumn(label: Text('سعر/كجم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
              DataColumn(label: Text('المسافة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
              DataColumn(label: Text('التوصيل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
              DataColumn(label: Text('المجموع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
            ],
            rows: _rows.map((r) {
              final isBest = best != null && r.farmer.id == best.farmer.id;
              return DataRow(
                color: isBest
                    ? MaterialStateProperty.all(
                        AppColors.lightGreen.withAlpha((255 * 0.45).round()),
                      )
                    : null,
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBest)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'موصى به',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white),
                            ),
                          ),
                        Flexible(
                          child: Text(
                            r.farmer.name,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text('${r.pricePerKg.toStringAsFixed(2)} د.أ', style: const TextStyle(fontFamily: 'Cairo'))),
                  DataCell(Text('${r.distanceKm.toStringAsFixed(0)} كم', style: const TextStyle(fontFamily: 'Cairo'))),
                  DataCell(Text('${r.deliveryCost.toStringAsFixed(2)} د.أ', style: const TextStyle(fontFamily: 'Cairo'))),
                  DataCell(
                    Text(
                      '${r.grandTotal.toStringAsFixed(2)} د.أ',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: isBest ? FontWeight.bold : FontWeight.w500,
                        color: isBest ? AppColors.primaryGreen : null,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تكلفة التوصيل = المسافة × ${kDeliveryCostPerKm.toStringAsFixed(2)} د.أ/كم. قيمة المنتج = الكمية × سعر الكيلو.',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        Consumer<UserProvider>(
          builder: (context, up, _) {
            final ok = up.currentUser != null &&
                !up.currentUser!.isGuest &&
                (up.currentUser!.role == UserRole.trader ||
                    up.currentUser!.role == UserRole.factory);
            return FilledButton.icon(
              onPressed: ok ? _sendPurchaseRequests : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.send),
              label: const Text('إرسال طلب شراء', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            );
          },
        ),
        if (context.watch<UserProvider>().currentUser?.isGuest ?? false)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'سجّل الدخول كتاجر أو مصنع لإرسال الطلب',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}
