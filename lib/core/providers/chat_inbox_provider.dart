import 'package:flutter/foundation.dart';
import 'package:hasad_app/core/models/user_model.dart';
import 'package:hasad_app/features/chat/chat_models.dart';
import 'package:uuid/uuid.dart';

/// صندوق محادثات وهمي يختلف حسب دور المستخدم ([threadsFor]).
class ChatInboxProvider extends ChangeNotifier {
  ChatInboxProvider() {
    _seedMock();
  }

  final _uuid = const Uuid();
  final List<ChatThreadModel> _threads = [];
  final Map<String, List<ChatMessageModel>> _messages = {};

  /// محادثات المناسبة لدور المستخدم الحالي فقط (مع استبعاد أزواج غير مسموحة مثل مزارع↔مزارع).
  List<ChatThreadModel> threadsFor(UserRole? role) {
    if (role == null) return List.unmodifiable(_threads);
    return _threads.where((t) {
      if (t.inboxRole != role) return false;
      switch (role) {
        case UserRole.farmer:
          return t.peerKind == ChatPeerKind.trader ||
              t.peerKind == ChatPeerKind.factory;
        case UserRole.trader:
        case UserRole.factory:
          return t.peerKind == ChatPeerKind.farmer;
      }
    }).toList();
  }

  /// للتوافق مع الشيفرة القديمة — يُفضّل استخدام [threadsFor].
  List<ChatThreadModel> get threads => List.unmodifiable(_threads);

  List<ChatMessageModel> messagesFor(String threadId) =>
      List.unmodifiable(_messages[threadId] ?? const []);

  String _previewForMessage(ChatMessageModel m) {
    switch (m.kind) {
      case ChatBubbleKind.text:
        return m.text ?? '';
      case ChatBubbleKind.imageAsset:
      case ChatBubbleKind.imageBytes:
        return '📷 صورة جودة';
      case ChatBubbleKind.pdf:
        return '📄 ${m.pdfDisplayName ?? 'ملف'}';
      case ChatBubbleKind.incomingPriceOffer:
        return 'عرض: ${m.offerPricePerKg?.toStringAsFixed(2)} د.أ/كجم — ${m.offerCrop}';
      case ChatBubbleKind.purchaseOfferCard:
        return 'عرض شراء: ${m.offerCrop} — ${m.offerQtyKg?.toStringAsFixed(0)} كجم';
      case ChatBubbleKind.factoryContractCard:
        return '📋 طلب تعاقد: ${m.contractMaterial}';
      case ChatBubbleKind.deliveryReminder:
        return '⏰ ${m.text ?? 'تذكير توريد'}';
      case ChatBubbleKind.esignAck:
        return '✓ ${m.text ?? 'توقيع'}';
    }
  }

  void _seedMock() {
    final now = DateTime.now();
    String mid() => _uuid.v4();

    // ——— محادثات المزارع: تاجر ومصنع فقط ———
    final f1 = _uuid.v4();
    final f2 = _uuid.v4();
    final f3 = _uuid.v4();

    _threads.addAll([
      ChatThreadModel(
        id: f1,
        inboxRole: UserRole.farmer,
        peerKind: ChatPeerKind.trader,
        peerName: 'تاجر — مؤسسة الخيرات',
        avatarAssetPath: 'assets/images/cucumber.png',
        lastPreview: 'عرض: 4.50 دينار/كجم لـ 500 كجم طماطم',
        updatedAt: now.subtract(const Duration(minutes: 12)),
        unreadCount: 1,
        offerSummaryLine: 'عرض: 4.50 دينار/كجم لـ 500 كجم طماطم',
        offerListStatus: ThreadOfferListStatus.pendingReview,
      ),
      ChatThreadModel(
        id: f2,
        inboxRole: UserRole.farmer,
        peerKind: ChatPeerKind.factory,
        peerName: 'مصنع الخليج للتعليب',
        avatarAssetPath: 'assets/images/crop_default.png',
        lastPreview: 'عرض: 3.20 دينار/كجم لـ 2 طن خيار',
        updatedAt: now.subtract(const Duration(hours: 1)),
        unreadCount: 0,
        offerSummaryLine: 'عرض: 3.20 دينار/كجم لـ 2 طن خيار',
        offerListStatus: ThreadOfferListStatus.accepted,
      ),
    ]);

    _threads.add(
      ChatThreadModel(
        id: f3,
        inboxRole: UserRole.farmer,
        peerKind: ChatPeerKind.trader,
        peerName: 'تاجر — سوق الجملة',
        avatarAssetPath: 'assets/images/pepper.png',
        lastPreview: 'عرض: 2.10 دينار/كجم لـ 300 كجم فلفل',
        updatedAt: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        offerSummaryLine: 'عرض: 2.10 دينار/كجم لـ 300 كجم فلفل',
        offerListStatus: ThreadOfferListStatus.rejected,
      ),
    );

    _messages[f1] = [
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(hours: 3)),
        kind: ChatBubbleKind.text,
        text: 'نرغب بشراء طماطم درجة أولى لهذا الأسبوع.',
      ),
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(minutes: 12)),
        kind: ChatBubbleKind.incomingPriceOffer,
        offerId: 'OF-${f1.substring(0, 6)}',
        offerCrop: 'طماطم',
        offerQtyKg: 500,
        offerPricePerKg: 4.5,
        offerDeliveryDate: now.add(const Duration(days: 5)),
        offerPendingFarmerAction: true,
      ),
    ];

    _messages[f2] = [
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(hours: 5)),
        kind: ChatBubbleKind.incomingPriceOffer,
        offerId: 'OF-f2',
        offerCrop: 'خيار',
        offerQtyKg: 2000,
        offerPricePerKg: 3.2,
        offerPendingFarmerAction: false,
      ),
      ChatMessageModel(
        id: mid(),
        isMine: true,
        sentAt: now.subtract(const Duration(hours: 4)),
        kind: ChatBubbleKind.text,
        text: 'تم قبول العرض — نجهز الشحن.',
      ),
    ];

    _messages[f3] = [
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(days: 2)),
        kind: ChatBubbleKind.incomingPriceOffer,
        offerId: 'OF-f3',
        offerCrop: 'فلفل',
        offerQtyKg: 300,
        offerPricePerKg: 2.1,
        offerPendingFarmerAction: false,
      ),
      ChatMessageModel(
        id: mid(),
        isMine: true,
        sentAt: now.subtract(const Duration(days: 1)),
        kind: ChatBubbleKind.text,
        text: 'نعتذر، لا يمكن قبول هذا العرض حالياً.',
      ),
    ];

    // ——— محادثات التاجر: مزارعون فقط ———
    final t1 = _uuid.v4();
    final t2 = _uuid.v4();
    final t3 = _uuid.v4();

    _threads.addAll([
      ChatThreadModel(
        id: t1,
        inboxRole: UserRole.trader,
        peerKind: ChatPeerKind.farmer,
        peerName: 'مزارع — فهد الحربي',
        avatarAssetPath: 'assets/images/tomato.png',
        lastPreview: 'أرسل عرض سعر لـ 300 كجم خيار',
        updatedAt: now.subtract(const Duration(minutes: 30)),
        unreadCount: 1,
        lastOfferSentAt: now.subtract(const Duration(minutes: 30)),
      ),
      ChatThreadModel(
        id: t2,
        inboxRole: UserRole.trader,
        peerKind: ChatPeerKind.farmer,
        peerName: 'مزارع — عمر الزريقات',
        avatarAssetPath: 'assets/images/eggplant.png',
        lastPreview: 'تم استلام عرضك، نراجع الكمية.',
        updatedAt: now.subtract(const Duration(hours: 4)),
        unreadCount: 0,
        lastOfferSentAt: now.subtract(const Duration(days: 1)),
      ),
      ChatThreadModel(
        id: t3,
        inboxRole: UserRole.trader,
        peerKind: ChatPeerKind.farmer,
        peerName: 'مزارع — ليث العموش',
        avatarAssetPath: 'assets/images/melon.png',
        lastPreview: 'هل يمكن تعديل تاريخ التسليم؟',
        updatedAt: now.subtract(const Duration(days: 2)),
        unreadCount: 0,
        lastOfferSentAt: now.subtract(const Duration(days: 3)),
      ),
    ]);

    _messages[t1] = [
      ChatMessageModel(
        id: mid(),
        isMine: true,
        sentAt: now.subtract(const Duration(hours: 2)),
        kind: ChatBubbleKind.purchaseOfferCard,
        offerId: 'PO-t1',
        offerCrop: 'خيار',
        offerQtyKg: 300,
        offerPricePerKg: 2.8,
        offerDeliveryDate: now.add(const Duration(days: 7)),
      ),
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(minutes: 30)),
        kind: ChatBubbleKind.text,
        text: 'أرسل عرض سعر لـ 300 كجم خيار',
      ),
    ];
    _messages[t2] = [
      ChatMessageModel(
        id: mid(),
        isMine: true,
        sentAt: now.subtract(const Duration(days: 1)),
        kind: ChatBubbleKind.purchaseOfferCard,
        offerId: 'PO-t2',
        offerCrop: 'باذنجان',
        offerQtyKg: 150,
        offerPricePerKg: 3.1,
        offerDeliveryDate: now.add(const Duration(days: 10)),
      ),
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(hours: 4)),
        kind: ChatBubbleKind.text,
        text: 'تم استلام عرضك، نراجع الكمية.',
      ),
    ];
    _messages[t3] = [
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(days: 2)),
        kind: ChatBubbleKind.text,
        text: 'هل يمكن تعديل تاريخ التسليم؟',
      ),
    ];

    // ——— محادثات المصنع: مزارعون (عقود) ———
    final fc1 = _uuid.v4();
    final fc2 = _uuid.v4();
    final fc3 = _uuid.v4();

    _threads.addAll([
      ChatThreadModel(
        id: fc1,
        inboxRole: UserRole.factory,
        peerKind: ChatPeerKind.farmer,
        peerName: 'مزارع — بسام النابلسي',
        avatarAssetPath: 'assets/images/tomato.png',
        lastPreview: 'توريد أسبوعي — طماطم',
        updatedAt: now.subtract(const Duration(hours: 2)),
        unreadCount: 1,
        factoryContractKind: 'موسمي',
        nextSupplyDate: now.add(const Duration(days: 3)),
      ),
      ChatThreadModel(
        id: fc2,
        inboxRole: UserRole.factory,
        peerKind: ChatPeerKind.farmer,
        peerName: 'مزارع — هيثم المفرقي',
        avatarAssetPath: 'assets/images/cucumber.png',
        lastPreview: 'طلبية واحدة — خيار',
        updatedAt: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        factoryContractKind: 'طلبية واحدة',
        nextSupplyDate: now.add(const Duration(days: 14)),
      ),
      ChatThreadModel(
        id: fc3,
        inboxRole: UserRole.factory,
        peerKind: ChatPeerKind.farmer,
        peerName: 'مزارع — رامي جرش',
        avatarAssetPath: 'assets/images/pepper.png',
        lastPreview: '📄 عقد_توريد_موسمي.pdf',
        updatedAt: now.subtract(const Duration(days: 3)),
        unreadCount: 0,
        factoryContractKind: 'موسمي',
        nextSupplyDate: now.add(const Duration(days: 30)),
      ),
    ]);

    _messages[fc1] = [
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(days: 5)),
        kind: ChatBubbleKind.factoryContractCard,
        offerId: 'CT-fc1',
        contractMaterial: 'طماطم معالجة',
        contractTotalTons: 40,
        contractScheduleSummary: 'كل أحد — 5 أطنان',
      ),
      ChatMessageModel(
        id: mid(),
        isMine: true,
        sentAt: now.subtract(const Duration(hours: 3)),
        kind: ChatBubbleKind.text,
        text: 'تم الاتفاق على الجدول الأسبوعي.',
      ),
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(hours: 2)),
        kind: ChatBubbleKind.deliveryReminder,
        text: 'التوريد القادم خلال 3 أيام — تجهيز الكمية',
      ),
    ];
    _messages[fc2] = [
      ChatMessageModel(
        id: mid(),
        isMine: true,
        sentAt: now.subtract(const Duration(days: 2)),
        kind: ChatBubbleKind.factoryContractCard,
        contractMaterial: 'خيار',
        contractTotalTons: 12,
        contractScheduleSummary: 'توريد لمرة واحدة — تاريخ محدد',
      ),
    ];
    _messages[fc3] = [
      ChatMessageModel(
        id: mid(),
        isMine: false,
        sentAt: now.subtract(const Duration(days: 4)),
        kind: ChatBubbleKind.pdf,
        pdfDisplayName: 'عقد_توريد_موسمي.pdf',
      ),
      ChatMessageModel(
        id: mid(),
        isMine: true,
        sentAt: now.subtract(const Duration(days: 3)),
        kind: ChatBubbleKind.esignAck,
        text: 'تم التوقيع إلكترونياً (تجريبي)',
      ),
    ];

    _threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  String openOrCreateThread({
    required String peerName,
    String? topicSubtitle,
    String? avatarAssetPath,
    required UserRole viewerRole,
    ChatPeerKind peerKind = ChatPeerKind.farmer,
  }) {
    ChatThreadModel? existing;
    for (final t in _threads) {
      if (t.peerName == peerName && t.inboxRole == viewerRole) {
        existing = t;
        break;
      }
    }
    if (existing != null) {
      notifyListeners();
      return existing.id;
    }

    final id = _uuid.v4();
    final preview = topicSubtitle != null && topicSubtitle.isNotEmpty
        ? 'محادثة: $topicSubtitle'
        : 'بدء المحادثة';

    _threads.insert(
      0,
      ChatThreadModel(
        id: id,
        inboxRole: viewerRole,
        peerKind: peerKind,
        peerName: peerName,
        avatarAssetPath: avatarAssetPath ?? 'assets/images/crop_default.png',
        lastPreview: preview,
        updatedAt: DateTime.now(),
        unreadCount: 0,
      ),
    );

    _messages[id] = [
      ChatMessageModel(
        id: _uuid.v4(),
        isMine: false,
        sentAt: DateTime.now(),
        kind: ChatBubbleKind.text,
        text: 'مرحباً، كيف يمكنني مساعدتك؟',
      ),
      if (topicSubtitle != null && topicSubtitle.isNotEmpty)
        ChatMessageModel(
          id: _uuid.v4(),
          isMine: true,
          sentAt: DateTime.now(),
          kind: ChatBubbleKind.text,
          text: 'أتواصل بخصوص: $topicSubtitle',
        ),
    ];

    notifyListeners();
    return id;
  }

  void markRead(String threadId) {
    for (final t in _threads) {
      if (t.id == threadId) {
        if (t.unreadCount > 0) {
          t.unreadCount = 0;
          notifyListeners();
        }
        return;
      }
    }
  }

  void deleteThread(String threadId) {
    _threads.removeWhere((t) => t.id == threadId);
    _messages.remove(threadId);
    notifyListeners();
  }

  void sendText(String threadId, String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final list = _messages.putIfAbsent(threadId, () => []);
    list.add(
      ChatMessageModel(
        id: _uuid.v4(),
        isMine: true,
        sentAt: DateTime.now(),
        kind: ChatBubbleKind.text,
        text: t,
      ),
    );
    _touchThread(threadId, _previewForMessage(list.last));
    notifyListeners();
  }

  void sendImageBytes(String threadId, Uint8List bytes) {
    final list = _messages.putIfAbsent(threadId, () => []);
    final m = ChatMessageModel(
      id: _uuid.v4(),
      isMine: true,
      sentAt: DateTime.now(),
      kind: ChatBubbleKind.imageBytes,
      imageBytes: bytes,
    );
    list.add(m);
    _touchThread(threadId, _previewForMessage(m));
    notifyListeners();
  }

  void sendPdfName(String threadId, String name) {
    final list = _messages.putIfAbsent(threadId, () => []);
    final m = ChatMessageModel(
      id: _uuid.v4(),
      isMine: true,
      sentAt: DateTime.now(),
      kind: ChatBubbleKind.pdf,
      pdfDisplayName: name,
    );
    list.add(m);
    _touchThread(threadId, _previewForMessage(m));
    notifyListeners();
  }

  /// المزارع: قبول أو رفض عرض سعري وارد.
  void farmerRespondToOffer({
    required String threadId,
    required String messageId,
    required bool accept,
  }) {
    final list = _messages[threadId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    final m = list[idx];
    if (m.kind != ChatBubbleKind.incomingPriceOffer) return;
    list[idx] = m.copyWith(offerPendingFarmerAction: false);
    list.add(
      ChatMessageModel(
        id: _uuid.v4(),
        isMine: true,
        sentAt: DateTime.now(),
        kind: ChatBubbleKind.text,
        text: accept ? '✓ تم قبول العرض.' : '✗ تم رفض العرض.',
      ),
    );
    final th = _threads.firstWhere((t) => t.id == threadId);
    th.offerListStatus = accept
        ? ThreadOfferListStatus.accepted
        : ThreadOfferListStatus.rejected;
    th.lastPreview = accept ? 'تم قبول العرض' : 'تم رفض العرض';
    th.updatedAt = DateTime.now();
    _threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  /// التاجر: إرسال عرض شراء منظم.
  void traderSendPurchaseOffer({
    required String threadId,
    required String crop,
    required double qtyKg,
    required double pricePerKg,
    required DateTime deliveryDate,
  }) {
    final list = _messages.putIfAbsent(threadId, () => []);
    final oid = 'PO-${_uuid.v4().substring(0, 8)}';
    list.add(
      ChatMessageModel(
        id: _uuid.v4(),
        isMine: true,
        sentAt: DateTime.now(),
        kind: ChatBubbleKind.purchaseOfferCard,
        offerId: oid,
        offerCrop: crop,
        offerQtyKg: qtyKg,
        offerPricePerKg: pricePerKg,
        offerDeliveryDate: deliveryDate,
      ),
    );
    final th = _threads.firstWhere((t) => t.id == threadId);
    th.lastOfferSentAt = DateTime.now();
    th.lastPreview = 'عرض شراء: $crop — ${qtyKg.toStringAsFixed(0)} كجم';
    th.updatedAt = DateTime.now();
    _touchThread(threadId, th.lastPreview);
    notifyListeners();
  }

  /// المصنع: إرسال طلب تعاقد موسمي (بطاقة).
  void factorySendSeasonContract({
    required String threadId,
    required String material,
    required double totalTons,
    required String schedule,
  }) {
    final list = _messages.putIfAbsent(threadId, () => []);
    list.add(
      ChatMessageModel(
        id: _uuid.v4(),
        isMine: true,
        sentAt: DateTime.now(),
        kind: ChatBubbleKind.factoryContractCard,
        contractMaterial: material,
        contractTotalTons: totalTons,
        contractScheduleSummary: schedule,
      ),
    );
    _touchThread(threadId, _previewForMessage(list.last));
    notifyListeners();
  }

  /// إلغاء آخر عرض شراء من التاجر (رسالة نصية).
  /// مصنع: محاكاة توقيع إلكتروني بسيط بعد رفع PDF.
  void factoryMockEsign(String threadId) {
    final list = _messages.putIfAbsent(threadId, () => []);
    list.add(
      ChatMessageModel(
        id: _uuid.v4(),
        isMine: true,
        sentAt: DateTime.now(),
        kind: ChatBubbleKind.esignAck,
        text: 'تم التوقيع الإلكتروني على العقد (وهمي)',
      ),
    );
    _touchThread(threadId, '✓ توقيع إلكتروني');
    notifyListeners();
  }

  void traderCancelLastOffer(String threadId) {
    final list = _messages.putIfAbsent(threadId, () => []);
    list.add(
      ChatMessageModel(
        id: _uuid.v4(),
        isMine: true,
        sentAt: DateTime.now(),
        kind: ChatBubbleKind.text,
        text: '— تم إلغاء آخر عرض شراء قبل رد المزارع —',
      ),
    );
    _touchThread(threadId, 'إلغاء عرض');
    notifyListeners();
  }

  void updateMessage(String threadId, ChatMessageModel updated) {
    final list = _messages[threadId];
    if (list == null) return;
    final i = list.indexWhere((m) => m.id == updated.id);
    if (i >= 0) {
      list[i] = updated;
      notifyListeners();
    }
  }

  void _touchThread(String threadId, String preview) {
    final th = _threads.firstWhere((t) => t.id == threadId);
    th.lastPreview = preview;
    th.updatedAt = DateTime.now();
    _threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  ChatThreadModel? threadById(String id) {
    for (final t in _threads) {
      if (t.id == id) return t;
    }
    return null;
  }
}
