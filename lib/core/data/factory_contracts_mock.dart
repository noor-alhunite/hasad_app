import '../models/factory_contract_model.dart';

/// مزارعون افتراضيون سبق التواصل معهم عبر المحادثات.
List<ContactedFarmerOption> mockContactedFarmers() {
  return const [
    ContactedFarmerOption(
      id: 'farmer_001',
      name: 'أحمد الشمري',
      lastChatPreview: 'الطماطم جاهزة الأسبوع القادم',
    ),
    ContactedFarmerOption(
      id: 'farmer_m002',
      name: 'محمد العتيبي',
      lastChatPreview: 'نرسل عينات الخيار غداً',
    ),
    ContactedFarmerOption(
      id: 'f3',
      name: 'سعد القحطاني',
      lastChatPreview: 'الفلفل بدرجة نضج ممتازة',
    ),
  ];
}

List<String> mockContractProductChoices() {
  return const ['طماطم', 'خيار', 'فلفل', 'باذنجان', 'كوسا'];
}

/// عقدان وهميان: نشط + منتهٍ (أسماء المزارعين كما طُلب).
List<FactoryContract> mockFactoryContracts() {
  return [
    // نشط — أحمد الشمري (نفس معرّف المستخدم التجريبي farmer_001)
    FactoryContract(
      id: 'c_active_001',
      farmerId: 'farmer_001',
      farmerName: 'أحمد الشمري',
      productName: 'طماطم',
      qualitySpecs: const ContractQualitySpecs(
        sizeLabel: 'متوسط',
        colorLabel: 'أحمر',
        ripenessLabel: 'ناضج',
        moistureOrExtra: 'خلو من الآفات، رطوبة أقل من 5%',
      ),
      totalQuantityTons: 40,
      pricePerKgDinar: 0.45,
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 6, 30),
      status: FactoryContractStatus.activeCertified,
      quantityUnit: ContractQuantityUnit.ton,
      expectedDeliveryDate: DateTime(2026, 4, 20),
      deliveryLocation: 'مخازن المصنع — الدمام، حي الفيصلية',
      penaltyTerms: 'غرامة 2% عن كل أسبوع تأخير عن موعد التسليم المتفق عليه.',
      documentHoldingPaths: const ['/mock/holding.jpg'],
      supplySchedule: [
        SupplyScheduleEntry(dueDate: DateTime(2026, 4, 15), quantityTons: 10),
        SupplyScheduleEntry(dueDate: DateTime(2026, 4, 22), quantityTons: 10),
      ],
      deliveries: [
        ContractDeliveryRecord(
          id: 'd_legacy_1',
          quantityTons: 9.5,
          legacyDeliveredAt: DateTime(2026, 4, 8),
          factoryConfirmedAt: DateTime(2026, 4, 8),
          receivedQuantityTons: 9.5,
          receiptNumber: 'REC-2026-0408-001',
          receiptAt: DateTime(2026, 4, 8, 14, 30),
          assessment: const QualityAssessment(
            stars: 5,
            notes: 'مطابقة للمواصفات، تغليف جيد',
            imagePaths: [],
          ),
        ),
      ],
    ),
    // منتهٍ — محمد العتيبي
    FactoryContract(
      id: 'c_ended_002',
      farmerId: 'farmer_m002',
      farmerName: 'محمد العتيبي',
      productName: 'فلفل',
      qualitySpecs: const ContractQualitySpecs(
        sizeLabel: 'صغير',
        colorLabel: 'أحمر',
        ripenessLabel: 'ناضج',
        moistureOrExtra: 'حسب المواصفة المرجعية للمصنع',
      ),
      totalQuantityTons: 12,
      pricePerKgDinar: 0.52,
      startDate: DateTime(2025, 11, 1),
      endDate: DateTime(2026, 2, 28),
      status: FactoryContractStatus.ended,
      expectedDeliveryDate: DateTime(2026, 2, 20),
      deliveryLocation: 'مستودع المصنع الرئيسي',
      supplySchedule: [
        SupplyScheduleEntry(dueDate: DateTime(2025, 12, 1), quantityTons: 4),
        SupplyScheduleEntry(dueDate: DateTime(2026, 2, 20), quantityTons: 4),
      ],
      deliveries: [
        ContractDeliveryRecord(
          id: 'd_end_1',
          quantityTons: 4,
          legacyDeliveredAt: DateTime(2025, 12, 2),
          factoryConfirmedAt: DateTime(2025, 12, 2),
          receivedQuantityTons: 4,
          receiptNumber: 'REC-2025-1202-014',
          receiptAt: DateTime(2025, 12, 2, 9, 0),
          assessment: const QualityAssessment(
            stars: 5,
            notes: 'مطابق تماماً',
            imagePaths: [],
          ),
        ),
      ],
    ),
  ];
}
