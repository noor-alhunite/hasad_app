import 'package:flutter/foundation.dart';

/// حالة العقد في دورة الحياة.
enum FactoryContractStatus {
  pendingFarmerApproval,
  activeCertified,
  ended,
  rejected,
}

/// وحدة الكمية في العقد.
enum ContractQuantityUnit {
  kg,
  ton,
}

/// مواصفات الجودة المتفق عليها.
@immutable
class ContractQualitySpecs {
  const ContractQualitySpecs({
    required this.sizeLabel,
    required this.colorLabel,
    required this.ripenessLabel,
    this.moistureOrExtra = '',
  });

  final String sizeLabel;
  final String colorLabel;
  final String ripenessLabel;
  final String moistureOrExtra;

  ContractQualitySpecs copyWith({
    String? sizeLabel,
    String? colorLabel,
    String? ripenessLabel,
    String? moistureOrExtra,
  }) {
    return ContractQualitySpecs(
      sizeLabel: sizeLabel ?? this.sizeLabel,
      colorLabel: colorLabel ?? this.colorLabel,
      ripenessLabel: ripenessLabel ?? this.ripenessLabel,
      moistureOrExtra: moistureOrExtra ?? this.moistureOrExtra,
    );
  }
}

/// صف في جدول التوريد.
@immutable
class SupplyScheduleEntry {
  const SupplyScheduleEntry({
    required this.dueDate,
    required this.quantityTons,
  });

  final DateTime dueDate;
  final double quantityTons;
}

/// تقييم جودة من المصنع بعد الاستلام.
@immutable
class QualityAssessment {
  const QualityAssessment({
    required this.stars,
    required this.notes,
    this.imagePaths = const [],
  });

  final int stars;
  final String notes;
  final List<String> imagePaths;
}

/// سجل تسليم/استلام لدفعة واحدة.
@immutable
class ContractDeliveryRecord {
  const ContractDeliveryRecord({
    required this.id,
    required this.quantityTons,
    this.farmerSubmittedAt,
    this.farmerPhotoPaths = const [],
    this.factoryConfirmedAt,
    this.receivedQuantityTons,
    this.receiptNumber,
    this.receiptAt,
    this.assessment,
    this.legacyDeliveredAt,
  });

  final String id;
  /// الكمية المعلنة من المزارع (طن).
  final double quantityTons;
  /// المزارع ضغط «تم التسليم».
  final DateTime? farmerSubmittedAt;
  final List<String> farmerPhotoPaths;
  /// المصنع أكد الاستلام وأصدر إذن الاستلام.
  final DateTime? factoryConfirmedAt;
  final double? receivedQuantityTons;
  final String? receiptNumber;
  final DateTime? receiptAt;
  final QualityAssessment? assessment;
  /// توافق مع السجلات القديمة قبل إضافة سير العمل.
  final DateTime? legacyDeliveredAt;

  bool get awaitingFactoryReceipt =>
      farmerSubmittedAt != null && factoryConfirmedAt == null;

  bool get receiptComplete =>
      factoryConfirmedAt != null || legacyDeliveredAt != null;

  /// للفرز والعرض.
  DateTime get sortTime =>
      factoryConfirmedAt ??
      receiptAt ??
      farmerSubmittedAt ??
      legacyDeliveredAt ??
      DateTime.fromMillisecondsSinceEpoch(0);

  /// توافق مع الواجهات القديمة (تاريخ العرض).
  DateTime get deliveredAt => sortTime;

  ContractDeliveryRecord copyWith({
    String? id,
    double? quantityTons,
    DateTime? farmerSubmittedAt,
    List<String>? farmerPhotoPaths,
    DateTime? factoryConfirmedAt,
    double? receivedQuantityTons,
    String? receiptNumber,
    DateTime? receiptAt,
    QualityAssessment? assessment,
    DateTime? legacyDeliveredAt,
  }) {
    return ContractDeliveryRecord(
      id: id ?? this.id,
      quantityTons: quantityTons ?? this.quantityTons,
      farmerSubmittedAt: farmerSubmittedAt ?? this.farmerSubmittedAt,
      farmerPhotoPaths: farmerPhotoPaths ?? this.farmerPhotoPaths,
      factoryConfirmedAt: factoryConfirmedAt ?? this.factoryConfirmedAt,
      receivedQuantityTons: receivedQuantityTons ?? this.receivedQuantityTons,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptAt: receiptAt ?? this.receiptAt,
      assessment: assessment ?? this.assessment,
      legacyDeliveredAt: legacyDeliveredAt ?? this.legacyDeliveredAt,
    );
  }
}

/// عقد توريد إلكتروني (مصنع ↔ مزارع).
@immutable
class FactoryContract {
  const FactoryContract({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.productName,
    required this.qualitySpecs,
    required this.totalQuantityTons,
    required this.pricePerKgDinar,
    required this.startDate,
    required this.endDate,
    required this.supplySchedule,
    required this.status,
    this.deliveries = const [],
    this.quantityUnit = ContractQuantityUnit.ton,
    this.expectedDeliveryDate,
    this.deliveryLocation = '',
    this.penaltyTerms = '',
    this.documentNationalIdPaths = const [],
    this.documentHoldingPaths = const [],
    this.documentLeasePaths = const [],
    this.documentExtraPaths = const [],
  });

  final String id;
  final String farmerId;
  final String farmerName;
  final String productName;
  final ContractQualitySpecs qualitySpecs;
  final double totalQuantityTons;
  final double pricePerKgDinar;
  final DateTime startDate;
  final DateTime endDate;
  final List<SupplyScheduleEntry> supplySchedule;
  final FactoryContractStatus status;
  final List<ContractDeliveryRecord> deliveries;
  final ContractQuantityUnit quantityUnit;
  final DateTime? expectedDeliveryDate;
  final String deliveryLocation;
  final String penaltyTerms;
  final List<String> documentNationalIdPaths;
  final List<String> documentHoldingPaths;
  final List<String> documentLeasePaths;
  final List<String> documentExtraPaths;

  bool get isActive =>
      status == FactoryContractStatus.activeCertified ||
      status == FactoryContractStatus.pendingFarmerApproval;

  FactoryContract copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? productName,
    ContractQualitySpecs? qualitySpecs,
    double? totalQuantityTons,
    double? pricePerKgDinar,
    DateTime? startDate,
    DateTime? endDate,
    List<SupplyScheduleEntry>? supplySchedule,
    FactoryContractStatus? status,
    List<ContractDeliveryRecord>? deliveries,
    ContractQuantityUnit? quantityUnit,
    DateTime? expectedDeliveryDate,
    String? deliveryLocation,
    String? penaltyTerms,
    List<String>? documentNationalIdPaths,
    List<String>? documentHoldingPaths,
    List<String>? documentLeasePaths,
    List<String>? documentExtraPaths,
  }) {
    return FactoryContract(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      productName: productName ?? this.productName,
      qualitySpecs: qualitySpecs ?? this.qualitySpecs,
      totalQuantityTons: totalQuantityTons ?? this.totalQuantityTons,
      pricePerKgDinar: pricePerKgDinar ?? this.pricePerKgDinar,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      supplySchedule: supplySchedule ?? this.supplySchedule,
      status: status ?? this.status,
      deliveries: deliveries ?? this.deliveries,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      penaltyTerms: penaltyTerms ?? this.penaltyTerms,
      documentNationalIdPaths:
          documentNationalIdPaths ?? this.documentNationalIdPaths,
      documentHoldingPaths: documentHoldingPaths ?? this.documentHoldingPaths,
      documentLeasePaths: documentLeasePaths ?? this.documentLeasePaths,
      documentExtraPaths: documentExtraPaths ?? this.documentExtraPaths,
    );
  }
}

/// مزارع متواصل معه سابقاً (قائمة إنشاء عقد).
@immutable
class ContactedFarmerOption {
  const ContactedFarmerOption({
    required this.id,
    required this.name,
    required this.lastChatPreview,
  });

  final String id;
  final String name;
  final String lastChatPreview;
}
