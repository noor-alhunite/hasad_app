import 'dart:typed_data';

import 'package:hasad_app/core/models/user_model.dart';

/// نوع الطرف الآخر في المحادثة (للأيقونة والتصفية).
enum ChatPeerKind {
  farmer,
  trader,
  factory,
}

/// حالة عرض سعري يظهر للمزارع في القائمة.
enum ThreadOfferListStatus {
  none,
  pendingReview,
  accepted,
  rejected,
}

/// نوع محتوى الرسالة في فقاعة الدردشة.
enum ChatBubbleKind {
  text,
  imageAsset,
  imageBytes,
  pdf,
  /// عرض سعري وارد من تاجر/مصنع → المزارع يمكنه قبول/رفض
  incomingPriceOffer,
  /// عرض شراء مرسل من التاجر (منظم)
  purchaseOfferCard,
  /// طلب تعاقد موسمي من المصنع
  factoryContractCard,
  /// تذكير توريد
  deliveryReminder,
  /// تأكيد توقيع إلكتروني بسيط
  esignAck,
}

/// رسالة واحدة في محادثة.
class ChatMessageModel {
  final String id;
  final bool isMine;
  final DateTime sentAt;
  final ChatBubbleKind kind;
  final String? text;
  final String? imageAssetPath;
  final Uint8List? imageBytes;
  final String? pdfDisplayName;

  // --- عروض أسعار / تعاقد (وهمية) ---
  final String? offerId;
  final String? offerCrop;
  final double? offerQtyKg;
  final double? offerPricePerKg;
  final DateTime? offerDeliveryDate;
  /// للعروض الواردة: هل ما زال بانتظار رد المزارع؟
  final bool? offerPendingFarmerAction;

  final String? contractMaterial;
  final double? contractTotalTons;
  final String? contractScheduleSummary;

  const ChatMessageModel({
    required this.id,
    required this.isMine,
    required this.sentAt,
    required this.kind,
    this.text,
    this.imageAssetPath,
    this.imageBytes,
    this.pdfDisplayName,
    this.offerId,
    this.offerCrop,
    this.offerQtyKg,
    this.offerPricePerKg,
    this.offerDeliveryDate,
    this.offerPendingFarmerAction,
    this.contractMaterial,
    this.contractTotalTons,
    this.contractScheduleSummary,
  });

  ChatMessageModel copyWith({
    bool? offerPendingFarmerAction,
  }) {
    return ChatMessageModel(
      id: id,
      isMine: isMine,
      sentAt: sentAt,
      kind: kind,
      text: text,
      imageAssetPath: imageAssetPath,
      imageBytes: imageBytes,
      pdfDisplayName: pdfDisplayName,
      offerId: offerId,
      offerCrop: offerCrop,
      offerQtyKg: offerQtyKg,
      offerPricePerKg: offerPricePerKg,
      offerDeliveryDate: offerDeliveryDate,
      offerPendingFarmerAction: offerPendingFarmerAction ?? this.offerPendingFarmerAction,
      contractMaterial: contractMaterial,
      contractTotalTons: contractTotalTons,
      contractScheduleSummary: contractScheduleSummary,
    );
  }
}

/// محادثة في القائمة — تُصفّى حسب [inboxRole] (دور صاحب التطبيق).
class ChatThreadModel {
  final String id;
  /// لمن تظهر هذه المحادثة في القائمة (مزارع / تاجر / مصنع).
  final UserRole inboxRole;
  final ChatPeerKind peerKind;
  final String peerName;
  final String? avatarAssetPath;
  String lastPreview;
  DateTime updatedAt;
  int unreadCount;

  /// للمزارع: سطر عرض سعري مختصر في القائمة.
  final String? offerSummaryLine;
  /// للمزارع: حالة العرض في القائمة.
  ThreadOfferListStatus offerListStatus;

  /// للتاجر: وقت آخر عرض مرسل (وهمي).
  DateTime? lastOfferSentAt;

  /// للمصنع: نوع العقد وموعد التوريد القادم (وهمي).
  final String? factoryContractKind;
  final DateTime? nextSupplyDate;

  ChatThreadModel({
    required this.id,
    required this.inboxRole,
    required this.peerKind,
    required this.peerName,
    this.avatarAssetPath,
    required this.lastPreview,
    required this.updatedAt,
    this.unreadCount = 0,
    this.offerSummaryLine,
    this.offerListStatus = ThreadOfferListStatus.none,
    this.lastOfferSentAt,
    this.factoryContractKind,
    this.nextSupplyDate,
  });
}
