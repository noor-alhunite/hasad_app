// تفاصيل العقد — للمصنع وللمزارع (قبول/رفض، تسليم، استلام، إذن استلام PDF، تقييم جودة).
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/models/factory_contract_model.dart';
import '../../core/providers/factory_contract_provider.dart';
import 'contract_receipt_pdf.dart';

/// من يعرض الشاشة: واجهة المصنع أو المزارع.
enum ContractDetailViewer { factory, farmer }

class FactoryContractDetailScreen extends StatelessWidget {
  const FactoryContractDetailScreen({
    super.key,
    required this.contractId,
    this.viewer = ContractDetailViewer.factory,
  });

  final String contractId;
  final ContractDetailViewer viewer;

  bool get _isFarmer => viewer == ContractDetailViewer.farmer;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FactoryContractProvider>();
    final c = prov.contractById(contractId);
    final dateFmt = DateFormat.yMMMd('ar');
    final dateTimeFmt = DateFormat.yMMMd('ar').add_Hm();

    if (c == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('عقد')),
        body: const Center(child: Text('العقد غير موجود')),
      );
    }

    final sortedDeliveries = [...c.deliveries]
      ..sort((a, b) => b.sortTime.compareTo(a.sortTime));

    final accent =
        _isFarmer ? AppColors.primaryGreen : const Color(0xFFE65100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          c.productName,
          style: const TextStyle(
              fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(status: c.status),
          const SizedBox(height: 12),
          _sectionTitle('المزارع والمنتج'),
          _infoCard([
            ('المزارع', c.farmerName),
            ('المنتج', c.productName),
            ('الحالة', _statusArabic(c.status)),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('مواصفات الجودة'),
          _infoCard([
            ('الحجم', c.qualitySpecs.sizeLabel),
            ('اللون', c.qualitySpecs.colorLabel),
            ('النضج', c.qualitySpecs.ripenessLabel),
            if (c.qualitySpecs.moistureOrExtra.isNotEmpty)
              ('مواصفات إضافية', c.qualitySpecs.moistureOrExtra),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('الكمية والسعر والمدة'),
          _infoCard([
            (
              'الكمية',
              '${c.totalQuantityTons} ${c.quantityUnit == ContractQuantityUnit.kg ? 'كجم' : 'طن'}'
            ),
            ('السعر', '${c.pricePerKgDinar} دينار/كجم'),
            ('من', dateFmt.format(c.startDate)),
            ('إلى', dateFmt.format(c.endDate)),
            if (c.expectedDeliveryDate != null)
              (
                'التسليم المتوقع',
                dateFmt.format(c.expectedDeliveryDate!)
              ),
            if (c.deliveryLocation.isNotEmpty)
              ('مكان التسليم', c.deliveryLocation),
          ]),
          if (c.penaltyTerms.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('الشروط الجزائية'),
            _infoCard([('', c.penaltyTerms)]),
          ],
          const SizedBox(height: 16),
          _sectionTitle('جدول التوريد'),
          ...c.supplySchedule.map(
            (s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  '${s.quantityTons} طن',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  dateFmt.format(s.dueDate),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                leading: Icon(Icons.event, color: accent),
              ),
            ),
          ),
          if (c.documentHoldingPaths.isNotEmpty ||
              c.documentNationalIdPaths.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('المستندات المرفقة'),
            _infoCard([
              ('بطاقة الحيازة', '${c.documentHoldingPaths.length} ملف'),
              ('الهوية', '${c.documentNationalIdPaths.length} ملف'),
              ('عقد إيجار', '${c.documentLeasePaths.length} ملف'),
              ('أخرى', '${c.documentExtraPaths.length} ملف'),
            ]),
          ],
          if (c.status == FactoryContractStatus.pendingFarmerApproval &&
              _isFarmer) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      prov.simulateFarmerAccept(c.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم قبول العقد — أصبح نشطاً')),
                      );
                    },
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    child: const Text('قبول',
                        style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      prov.farmerRejectContract(c.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم رفض العقد')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('رفض',
                        style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),
              ],
            ),
          ],
          if (c.status == FactoryContractStatus.pendingFarmerApproval &&
              !_isFarmer) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFFFF8E1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'العقد مرسل للمزارع — في انتظار القبول أو الرفض.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.brown[800]),
                ),
              ),
            ),
          ],
          if (c.status == FactoryContractStatus.activeCertified) ...[
            const SizedBox(height: 16),
            if (_isFarmer)
              FilledButton.icon(
                onPressed: () =>
                    _openFarmerDeliveryDialog(context, c.id, accent),
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('تم التسليم',
                    style: TextStyle(fontFamily: 'Cairo')),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openLegacyDeliveryDialog(context, c.id),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('تسجيل توريد (اختصار)',
                          style: TextStyle(fontFamily: 'Cairo')),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (!_isFarmer &&
              sortedDeliveries.any((d) => d.awaitingFactoryReceipt)) ...[
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFE8F5E9),
              child: const ListTile(
                leading: Icon(Icons.notifications_active, color: Color(0xFF2E7D32)),
                title: Text(
                  'طلب استلام بانتظار التأكيد — راجع الدفعات أدناه.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _sectionTitle('سجل التسليم والاستلام'),
          if (sortedDeliveries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'لا توجد دفعات مسجّلة بعد',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Cairo', color: AppColors.textSecondary),
              ),
            )
          else
            ...sortedDeliveries.map((d) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateTimeFmt.format(d.sortTime),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${d.quantityTons} طن (معلن)',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      if (d.farmerPhotoPaths.isNotEmpty)
                        Text(
                          'صور التسليم: ${d.farmerPhotoPaths.length}',
                          style: const TextStyle(
                              fontFamily: 'Cairo', fontSize: 12),
                        ),
                      if (d.awaitingFactoryReceipt) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isFarmer
                                ? 'بانتظار تأكيد استلام المصنع'
                                : 'طلب استلام — أكّد الكمية الفعلية',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                        if (!_isFarmer)
                          FilledButton(
                            onPressed: () => _openFactoryReceiptDialog(
                              context,
                              c.id,
                              d.id,
                              d.quantityTons,
                            ),
                            child: const Text('استلام وتأكيد',
                                style: TextStyle(fontFamily: 'Cairo')),
                          ),
                      ],
                      if (d.receiptNumber != null) ...[
                        const Divider(),
                        Text(
                          'إذن استلام: ${d.receiptNumber}',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold),
                        ),
                        if (d.receivedQuantityTons != null)
                          Text(
                            'الكمية المستلمة: ${d.receivedQuantityTons} طن',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                openReceiptPdf(
                                  receiptNumber: d.receiptNumber!,
                                  receiptAt: d.receiptAt ?? d.sortTime,
                                  farmerName: c.farmerName,
                                  productName: c.productName,
                                  receivedTons:
                                      d.receivedQuantityTons ?? d.quantityTons,
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('تحميل PDF',
                                  style: TextStyle(fontFamily: 'Cairo')),
                            ),
                          ],
                        ),
                      ],
                      if (d.receiptComplete &&
                          d.assessment == null &&
                          !_isFarmer) ...[
                        const Divider(),
                        OutlinedButton.icon(
                          onPressed: () => _openQualityDialog(
                            context,
                            c.id,
                            d.id,
                          ),
                          icon: const Icon(Icons.star_outline),
                          label: const Text('تقييم الجودة',
                              style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                      if (d.assessment != null) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RatingBarIndicator(
                              rating: d.assessment!.stars.toDouble(),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('تقييم الجودة:',
                                style: TextStyle(fontFamily: 'Cairo')),
                          ],
                        ),
                        if (d.assessment!.notes.isNotEmpty)
                          Text(
                            d.assessment!.notes,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _statusArabic(FactoryContractStatus s) {
    switch (s) {
      case FactoryContractStatus.pendingFarmerApproval:
        return 'قيد موافقة المزارع';
      case FactoryContractStatus.activeCertified:
        return 'موثق ونشط';
      case FactoryContractStatus.ended:
        return 'منتهي';
      case FactoryContractStatus.rejected:
        return 'مرفوض';
    }
  }

  Future<void> _openFarmerDeliveryDialog(
    BuildContext context,
    String contractId,
    Color accent,
  ) async {
    final tonsCtrl = TextEditingController(text: '5');
    final paths = <String>[];
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('تأكيد التسليم',
                  textAlign: TextAlign.right),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: tonsCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'الكمية (طن)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final x = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (x != null) {
                          setLocal(() => paths.add(x.path));
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('إرفاق صور (اختياري)',
                          style: TextStyle(fontFamily: 'Cairo')),
                    ),
                    if (paths.isNotEmpty)
                      Text('عدد الصور: ${paths.length}',
                          textAlign: TextAlign.right),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    final v = double.tryParse(
                      tonsCtrl.text.replaceAll(',', '.'),
                    );
                    if (v == null || v <= 0) return;
                    context.read<FactoryContractProvider>().farmerSubmitDelivery(
                          contractId: contractId,
                          quantityTons: v,
                          farmerPhotoPaths: List<String>.from(paths),
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'تم إرسال طلب التسليم — سيصل إشعار للمصنع'),
                      ),
                    );
                  },
                  child: const Text('إرسال'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openLegacyDeliveryDialog(
      BuildContext context, String contractId) async {
    final tonsCtrl = TextEditingController(text: '5');
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('تسجيل توريد', textAlign: TextAlign.right),
          content: TextField(
            controller: tonsCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'الكمية (طن)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(tonsCtrl.text.replaceAll(',', '.'));
                if (v == null || v <= 0) return;
                context.read<FactoryContractProvider>().recordDelivery(
                      contractId: contractId,
                      quantityTons: v,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل التوريد')),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFactoryReceiptDialog(
    BuildContext context,
    String contractId,
    String deliveryId,
    double declaredTons,
  ) async {
    final qtyCtrl =
        TextEditingController(text: declaredTons.toStringAsFixed(2));
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('تأكيد الاستلام',
              textAlign: TextAlign.right),
          content: TextField(
            controller: qtyCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'الكمية الفعلية المستلمة (طن)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
                if (v == null || v <= 0) return;
                context.read<FactoryContractProvider>().factoryConfirmReceipt(
                      contractId: contractId,
                      deliveryId: deliveryId,
                      receivedQuantityTons: v,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إصدار إذن الاستلام — يمكنك تقييم الجودة'),
                  ),
                );
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openQualityDialog(
    BuildContext context,
    String contractId,
    String deliveryId,
  ) async {
    double stars = 4;
    final notesCtrl = TextEditingController();
    final paths = <String>[];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('تقييم جودة المستلم',
                  textAlign: TextAlign.right),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RatingBar.builder(
                      initialRating: stars,
                      minRating: 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 28,
                      allowHalfRating: false,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (r) => setLocal(() => stars = r),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 3,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'تعليق (اختياري)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final x = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (x != null) {
                          setLocal(() => paths.add(x.path));
                        }
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('صور للمنتج المستلم (اختياري)',
                          style: TextStyle(fontFamily: 'Cairo')),
                    ),
                    if (paths.isNotEmpty)
                      Text('صور: ${paths.length}',
                          textAlign: TextAlign.right),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    context.read<FactoryContractProvider>().attachQualityAssessment(
                          contractId: contractId,
                          deliveryId: deliveryId,
                          assessment: QualityAssessment(
                            stars: stars.round().clamp(1, 5),
                            notes: notesCtrl.text.trim(),
                            imagePaths: List<String>.from(paths),
                          ),
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم حفظ التقييم — يظهر في سجل الجودة')),
                    );
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _infoCard(List<(String, String)> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: rows
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          r.$2,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                      if (r.$1.isNotEmpty)
                        Text(
                          r.$1,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final FactoryContractStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    String text;
    switch (status) {
      case FactoryContractStatus.pendingFarmerApproval:
        bg = AppColors.warning.withAlpha((255 * 0.2).round());
        text = 'قيد موافقة المزارع — ليس موثقاً بعد';
        break;
      case FactoryContractStatus.activeCertified:
        bg = AppColors.lightGreen;
        text = 'عقد موثق ونشط';
        break;
      case FactoryContractStatus.ended:
        bg = AppColors.lightGrey.withAlpha((255 * 0.5).round());
        text = 'عقد منتهٍ';
        break;
      case FactoryContractStatus.rejected:
        bg = AppColors.error.withAlpha((255 * 0.12).round());
        text = 'مرفوض من المزارع';
        break;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
      ),
    );
  }
}
