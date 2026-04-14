import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/factory_contracts_mock.dart';
import '../models/factory_contract_model.dart';

const _uuid = Uuid();

/// إدارة عقود المصنع في الذاكرة (وهمي — جاهز لاحقاً لربط API / تخزين محلي).
class FactoryContractProvider extends ChangeNotifier {
  FactoryContractProvider() {
    _contracts = List<FactoryContract>.from(mockFactoryContracts());
  }

  late List<FactoryContract> _contracts;

  List<FactoryContract> get contracts => List.unmodifiable(_contracts);

  /// عقود تخص مزارعاً محدداً (حسب معرّف المستخدم).
  List<FactoryContract> contractsForFarmerId(String? farmerId) {
    if (farmerId == null || farmerId.isEmpty) return [];
    return _contracts.where((c) => c.farmerId == farmerId).toList();
  }

  FactoryContract? contractById(String id) {
    try {
      return _contracts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FactoryContract> activeContracts() {
    return _contracts
        .where((c) =>
            c.status == FactoryContractStatus.activeCertified ||
            c.status == FactoryContractStatus.pendingFarmerApproval)
        .toList();
  }

  List<({DateTime date, String contractId, String productName, double tons})>
      upcomingSupplyWithinDays(int days) {
    final now = DateTime.now();
    final horizon = now.add(Duration(days: days));
    final out = <({
      DateTime date,
      String contractId,
      String productName,
      double tons
    })>[];
    for (final c in _contracts) {
      if (c.status != FactoryContractStatus.activeCertified) continue;
      for (final row in c.supplySchedule) {
        if (!row.dueDate.isBefore(now) && !row.dueDate.isAfter(horizon)) {
          out.add((
            date: row.dueDate,
            contractId: c.id,
            productName: c.productName,
            tons: row.quantityTons,
          ));
        }
      }
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  Map<String, ({String name, double avgStars, int count})> farmerQualityStats() {
    final map = <String, List<int>>{};
    final names = <String, String>{};
    for (final c in _contracts) {
      names[c.farmerId] = c.farmerName;
      for (final d in c.deliveries) {
        final stars = d.assessment?.stars;
        if (stars == null) continue;
        map.putIfAbsent(c.farmerId, () => []).add(stars);
      }
    }
    final result = <String, ({String name, double avgStars, int count})>{};
    for (final e in map.entries) {
      final list = e.value;
      final avg = list.reduce((a, b) => a + b) / list.length;
      result[e.key] = (
        name: names[e.key] ?? '',
        avgStars: avg,
        count: list.length,
      );
    }
    return result;
  }

  /// طلبات استلام بانتظار المصنع (المزارع سلّم ولم يُؤكد المصنع بعد).
  int get pendingFactoryReceiptCount {
    var n = 0;
    for (final c in _contracts) {
      for (final d in c.deliveries) {
        if (d.awaitingFactoryReceipt) n++;
      }
    }
    return n;
  }

  void addPendingContract({
    required String farmerId,
    required String farmerName,
    required String productName,
    required ContractQualitySpecs qualitySpecs,
    required double totalQuantityTons,
    required double pricePerKgDinar,
    required DateTime startDate,
    required DateTime endDate,
    required List<SupplyScheduleEntry> supplySchedule,
    ContractQuantityUnit quantityUnit = ContractQuantityUnit.ton,
    DateTime? expectedDeliveryDate,
    String deliveryLocation = '',
    String penaltyTerms = '',
    List<String> documentNationalIdPaths = const [],
    List<String> documentHoldingPaths = const [],
    List<String> documentLeasePaths = const [],
    List<String> documentExtraPaths = const [],
  }) {
    final id = _uuid.v4();
    _contracts = [
      FactoryContract(
        id: id,
        farmerId: farmerId,
        farmerName: farmerName,
        productName: productName,
        qualitySpecs: qualitySpecs,
        totalQuantityTons: totalQuantityTons,
        pricePerKgDinar: pricePerKgDinar,
        startDate: startDate,
        endDate: endDate,
        supplySchedule: supplySchedule,
        status: FactoryContractStatus.pendingFarmerApproval,
        deliveries: [],
        quantityUnit: quantityUnit,
        expectedDeliveryDate: expectedDeliveryDate,
        deliveryLocation: deliveryLocation,
        penaltyTerms: penaltyTerms,
        documentNationalIdPaths: documentNationalIdPaths,
        documentHoldingPaths: documentHoldingPaths,
        documentLeasePaths: documentLeasePaths,
        documentExtraPaths: documentExtraPaths,
      ),
      ..._contracts,
    ];
    notifyListeners();
  }

  void simulateFarmerAccept(String contractId) {
    final i = _contracts.indexWhere((c) => c.id == contractId);
    if (i < 0) return;
    final c = _contracts[i];
    if (c.status != FactoryContractStatus.pendingFarmerApproval) return;
    _contracts[i] = c.copyWith(status: FactoryContractStatus.activeCertified);
    notifyListeners();
  }

  void farmerRejectContract(String contractId) {
    final i = _contracts.indexWhere((c) => c.id == contractId);
    if (i < 0) return;
    final c = _contracts[i];
    if (c.status != FactoryContractStatus.pendingFarmerApproval) return;
    _contracts[i] = c.copyWith(status: FactoryContractStatus.rejected);
    notifyListeners();
  }

  /// المزارع يعلن التسليم (صور اختيارية).
  void farmerSubmitDelivery({
    required String contractId,
    required double quantityTons,
    List<String> farmerPhotoPaths = const [],
  }) {
    final i = _contracts.indexWhere((c) => c.id == contractId);
    if (i < 0) return;
    final c = _contracts[i];
    if (c.status != FactoryContractStatus.activeCertified) return;
    final rec = ContractDeliveryRecord(
      id: _uuid.v4(),
      quantityTons: quantityTons,
      farmerSubmittedAt: DateTime.now(),
      farmerPhotoPaths: List<String>.from(farmerPhotoPaths),
    );
    _contracts[i] = c.copyWith(deliveries: [...c.deliveries, rec]);
    notifyListeners();
  }

  /// المصنع يؤكد الاستلام ويُصدِر إذن استلام.
  void factoryConfirmReceipt({
    required String contractId,
    required String deliveryId,
    required double receivedQuantityTons,
  }) {
    final ci = _contracts.indexWhere((c) => c.id == contractId);
    if (ci < 0) return;
    final c = _contracts[ci];
    final deliveries = [...c.deliveries];
    final di = deliveries.indexWhere((d) => d.id == deliveryId);
    if (di < 0) return;
    final d = deliveries[di];
    if (!d.awaitingFactoryReceipt) return;

    final now = DateTime.now();
    final receiptNumber =
        'REC-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${deliveryId.substring(0, deliveryId.length.clamp(0, 8))}';

    deliveries[di] = d.copyWith(
      factoryConfirmedAt: now,
      receivedQuantityTons: receivedQuantityTons,
      receiptNumber: receiptNumber,
      receiptAt: now,
    );
    _contracts[ci] = c.copyWith(deliveries: deliveries);
    notifyListeners();
  }

  /// تسجيل توريد مباشر (اختصار للمصنع — سلوك قديم).
  void recordDelivery({
    required String contractId,
    required double quantityTons,
    DateTime? deliveredAt,
  }) {
    final i = _contracts.indexWhere((c) => c.id == contractId);
    if (i < 0) return;
    final c = _contracts[i];
    if (c.status != FactoryContractStatus.activeCertified) return;
    final at = deliveredAt ?? DateTime.now();
    final rec = ContractDeliveryRecord(
      id: _uuid.v4(),
      quantityTons: quantityTons,
      legacyDeliveredAt: at,
      factoryConfirmedAt: at,
      receivedQuantityTons: quantityTons,
      receiptNumber:
          'REC-${at.year}${at.month.toString().padLeft(2, '0')}${at.day.toString().padLeft(2, '0')}-LEG',
      receiptAt: at,
    );
    _contracts[i] = c.copyWith(deliveries: [...c.deliveries, rec]);
    notifyListeners();
  }

  void attachQualityAssessment({
    required String contractId,
    String? deliveryId,
    required QualityAssessment assessment,
  }) {
    final ci = _contracts.indexWhere((c) => c.id == contractId);
    if (ci < 0) return;
    final c = _contracts[ci];
    final deliveries = [...c.deliveries];
    int target = -1;
    if (deliveryId != null) {
      target = deliveries.indexWhere((d) => d.id == deliveryId);
    } else {
      for (var j = deliveries.length - 1; j >= 0; j--) {
        if (deliveries[j].assessment == null &&
            (deliveries[j].receiptComplete)) {
          target = j;
          break;
        }
      }
    }
    if (target < 0) return;
    final cur = deliveries[target];
    deliveries[target] = ContractDeliveryRecord(
      id: cur.id,
      quantityTons: cur.quantityTons,
      farmerSubmittedAt: cur.farmerSubmittedAt,
      farmerPhotoPaths: cur.farmerPhotoPaths,
      factoryConfirmedAt: cur.factoryConfirmedAt,
      receivedQuantityTons: cur.receivedQuantityTons,
      receiptNumber: cur.receiptNumber,
      receiptAt: cur.receiptAt,
      assessment: assessment,
      legacyDeliveredAt: cur.legacyDeliveredAt,
    );
    _contracts[ci] = c.copyWith(deliveries: deliveries);
    notifyListeners();
  }

  List<ContactedFarmerOption> contactedFarmers() => mockContactedFarmers();

  List<String> productChoices() => mockContractProductChoices();
}
