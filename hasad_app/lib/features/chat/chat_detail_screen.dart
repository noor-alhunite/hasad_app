// شاشة الدردشة: نفس فقاعات النص/الصورة/PDF.
// — مزارع: قبول/رفض على incomingPriceOffer + نص توضيحي لصور الجودة في المرفقات.
// — تاجر: أزرار «إرسال عرض» (بطاقة purchaseOfferCard) و«إلغاء آخر عرض».
// — مصنع: شريط تذكير توريد، «طلب تعاقد»، توقيع وهمي بعد PDF.
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/chat_inbox_provider.dart';
import 'chat_models.dart';
import 'chat_time_format.dart';

const Color _bubbleMine = Color(0xFF4CAF50);
const Color _bubbleOther = Color(0xFFE8E8E8);

/// شاشة دردشة — نفس فقاعات النص/الصورة، مع لوحات إضافية حسب [ChatThreadModel.inboxRole].
class ChatDetailScreen extends StatefulWidget {
  final String threadId;

  const ChatDetailScreen({super.key, required this.threadId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _textCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatInboxProvider>().markRead(widget.threadId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (!kIsWeb && source == ImageSource.camera) {
        final st = await Permission.camera.request();
        if (!st.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يلزم السماح بالكاميرا')),
            );
          }
          return;
        }
      }
      final x = await _picker.pickImage(source: source, imageQuality: 85);
      if (x == null || !mounted) return;
      final bytes = await x.readAsBytes();
      context.read<ChatInboxProvider>().sendImageBytes(widget.threadId, bytes);
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر اختيار الصورة: $e')),
        );
      }
    }
  }

  Future<void> _pickPdf() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (r == null || r.files.isEmpty || !mounted) return;
    final name = r.files.single.name;
    context.read<ChatInboxProvider>().sendPdfName(widget.threadId, name);
    SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _showAttachSheet(UserRole inboxRole) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (inboxRole == UserRole.farmer)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'صورة للمحصول تساعد على إثبات الجودة للتاجر أو المصنع.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('صورة من المعرض', textAlign: TextAlign.right),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('التقاط صورة', textAlign: TextAlign.right),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('ملف PDF (عقد)', textAlign: TextAlign.right),
              onTap: () {
                Navigator.pop(ctx);
                _pickPdf();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenImage({Uint8List? bytes, String? assetPath}) {
    late ImageProvider provider;
    if (bytes != null) {
      provider = MemoryImage(bytes);
    } else if (assetPath != null) {
      provider = AssetImage(assetPath);
    } else {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image(image: provider, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: MediaQuery.of(ctx).padding.top + 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTraderOfferDialog(ChatInboxProvider inbox) async {
    final cropCtrl = TextEditingController(text: 'خيار');
    final qtyCtrl = TextEditingController(text: '300');
    final priceCtrl = TextEditingController(text: '2.80');
    DateTime delivery = DateTime.now().add(const Duration(days: 7));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSt) => AlertDialog(
          title: const Text('عرض شراء', textAlign: TextAlign.right),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cropCtrl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'نوع المنتج'),
                ),
                TextField(
                  controller: qtyCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية (كجم)'),
                ),
                TextField(
                  controller: priceCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'السعر المقترح (د.أ/كجم)'),
                ),
                ListTile(
                  title: Text(
                    'تاريخ التسليم: ${delivery.day}/${delivery.month}/${delivery.year}',
                    textAlign: TextAlign.right,
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: delivery,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setSt(() => delivery = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('إرسال عرض')),
          ],
        ),
      ),
    );

    if (ok == true && mounted) {
      final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0;
      final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
      inbox.traderSendPurchaseOffer(
        threadId: widget.threadId,
        crop: cropCtrl.text.trim().isEmpty ? 'منتج' : cropCtrl.text.trim(),
        qtyKg: qty,
        pricePerKg: price,
        deliveryDate: delivery,
      );
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    cropCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }

  Future<void> _showFactoryContractDialog(ChatInboxProvider inbox) async {
    final matCtrl = TextEditingController(text: 'طماطم معالجة');
    final tonsCtrl = TextEditingController(text: '25');
    final schedCtrl = TextEditingController(text: 'كل أحد — 4 أطنان');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('طلب تعاقد موسمي', textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: matCtrl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'نوع المادة الخام'),
              ),
              TextField(
                controller: tonsCtrl,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الكمية الإجمالية (طن)'),
              ),
              TextField(
                controller: schedCtrl,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'جدول التوريد'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('إرسال')),
        ],
      ),
    );

    if (ok == true && mounted) {
      final tons = double.tryParse(tonsCtrl.text.trim()) ?? 0;
      inbox.factorySendSeasonContract(
        threadId: widget.threadId,
        material: matCtrl.text.trim(),
        totalTons: tons,
        schedule: schedCtrl.text.trim(),
      );
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    matCtrl.dispose();
    tonsCtrl.dispose();
    schedCtrl.dispose();
  }

  IconData _peerIcon(ChatPeerKind k) {
    switch (k) {
      case ChatPeerKind.farmer:
        return Icons.agriculture;
      case ChatPeerKind.trader:
        return Icons.storefront;
      case ChatPeerKind.factory:
        return Icons.factory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inbox = context.watch<ChatInboxProvider>();
    final thread = inbox.threadById(widget.threadId);
    if (thread == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('محادثة')),
        body: const Center(child: Text('غير موجودة')),
      );
    }

    final messages = inbox.messagesFor(widget.threadId);
    final inboxRole = thread.inboxRole;

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(
                    thread.avatarAssetPath ?? 'assets/images/crop_default.png',
                  ),
                ),
                Positioned(
                  left: -4,
                  bottom: -4,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Icon(_peerIcon(thread.peerKind), size: 12, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    thread.peerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الاتصال غير مفعّل في النسخة التجريبية')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // مصنع: تذكير بموعد التوريد القادم (وهمي من القائمة)
          if (inboxRole == UserRole.factory && thread.nextSupplyDate != null)
            Material(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.amber.shade900, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تذكير: موعد التوريد القادم ${formatOfferDateShortAr(thread.nextSupplyDate)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                return _MessageBubble(
                  message: messages[i],
                  inboxRole: inboxRole,
                  onImageTap: _openFullScreenImage,
                  onFarmerDecision: (accept) {
                    inbox.farmerRespondToOffer(
                      threadId: widget.threadId,
                      messageId: messages[i].id,
                      accept: accept,
                    );
                    SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  },
                );
              },
            ),
          ),
          // تاجر: إرسال عرض شراء / إلغاء قبل رد المزارع (محاكاة)
          if (inboxRole == UserRole.trader)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        inbox.traderCancelLastOffer(widget.threadId);
                        SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('إلغاء آخر عرض', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showTraderOfferDialog(inbox),
                      icon: const Icon(Icons.local_offer_outlined, size: 18),
                      label: const Text('إرسال عرض', style: TextStyle(fontFamily: 'Cairo')),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          // مصنع: تعاقد موسمي + توقيع وهمي
          if (inboxRole == UserRole.factory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        inbox.factoryMockEsign(widget.threadId);
                        SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      },
                      icon: const Icon(Icons.draw_outlined, size: 18),
                      label: const Text('توقيع عقد (تجريبي)', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showFactoryContractDialog(inbox),
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: const Text('طلب تعاقد', style: TextStyle(fontFamily: 'Cairo')),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          Material(
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: MediaQuery.of(context).padding.bottom + 6,
                top: 6,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _showAttachSheet(inboxRole),
                    icon: const Icon(Icons.attach_file, color: AppColors.primaryGreen),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      textAlign: TextAlign.right,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'رسالة...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: _bubbleMine,
                    borderRadius: BorderRadius.circular(24),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final t = _textCtrl.text.trim();
                        if (t.isEmpty) return;
                        context.read<ChatInboxProvider>().sendText(widget.threadId, t);
                        _textCtrl.clear();
                        SchedulerBinding.instance
                            .addPostFrameCallback((_) => _scrollToBottom());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final UserRole inboxRole;
  final void Function({Uint8List? bytes, String? assetPath}) onImageTap;
  final void Function(bool accept)? onFarmerDecision;

  const _MessageBubble({
    required this.message,
    required this.inboxRole,
    required this.onImageTap,
    this.onFarmerDecision,
  });

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final align = mine ? Alignment.centerRight : Alignment.centerLeft;
    final bg = mine ? _bubbleMine : _bubbleOther;
    final fg = mine ? Colors.white : Colors.black87;
    final maxW = MediaQuery.of(context).size.width * 0.85;

    Widget inner;
    switch (message.kind) {
      case ChatBubbleKind.text:
        inner = Text(
          message.text ?? '',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', color: fg, fontSize: 15),
        );
        break;
      case ChatBubbleKind.imageAsset:
        inner = GestureDetector(
          onTap: () => onImageTap(assetPath: message.imageAssetPath),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              message.imageAssetPath!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        );
        break;
      case ChatBubbleKind.imageBytes:
        inner = GestureDetector(
          onTap: () => onImageTap(bytes: message.imageBytes),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              message.imageBytes!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        );
        break;
      case ChatBubbleKind.pdf:
        inner = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf, color: fg),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.pdfDisplayName ?? 'ملف PDF',
                style: TextStyle(fontFamily: 'Cairo', color: fg),
              ),
            ),
          ],
        );
        break;
      case ChatBubbleKind.incomingPriceOffer:
        inner = _incomingOfferCard(
          context: context,
          message: message,
          fg: fg,
          inboxRole: inboxRole,
          onFarmerDecision: onFarmerDecision,
        );
        break;
      case ChatBubbleKind.purchaseOfferCard:
        inner = _purchaseOfferCard(message, fg);
        break;
      case ChatBubbleKind.factoryContractCard:
        inner = _factoryContractCard(message, fg);
        break;
      case ChatBubbleKind.deliveryReminder:
        inner = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, color: fg),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.text ?? 'تذكير توريد',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Cairo', color: fg, fontSize: 14),
              ),
            ),
          ],
        );
        break;
      case ChatBubbleKind.esignAck:
        inner = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: fg),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.text ?? 'توقيع',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Cairo', color: fg, fontSize: 14),
              ),
            ),
          ],
        );
        break;
    }

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(mine ? 12 : 2),
            bottomRight: Radius.circular(mine ? 2 : 12),
          ),
        ),
        child: inner,
      ),
    );
  }

  static Widget _purchaseOfferCard(ChatMessageModel m, Color fg) {
    final d = m.offerDeliveryDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'عرض شراء',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
        const SizedBox(height: 6),
        _line('المنتج', m.offerCrop ?? '—', fg),
        _line('الكمية', '${m.offerQtyKg?.toStringAsFixed(0) ?? '—'} كجم', fg),
        _line('السعر', '${m.offerPricePerKg?.toStringAsFixed(2) ?? '—'} د.أ/كجم', fg),
        if (d != null) _line('التسليم', formatOfferDateShortAr(d), fg),
      ],
    );
  }

  static Widget _factoryContractCard(ChatMessageModel m, Color fg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'طلب تعاقد',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
        const SizedBox(height: 6),
        _line('المادة', m.contractMaterial ?? '—', fg),
        _line('الإجمالي', '${m.contractTotalTons?.toStringAsFixed(1) ?? '—'} طن', fg),
        _line('الجدول', m.contractScheduleSummary ?? '—', fg),
      ],
    );
  }

  static Widget _line(String k, String v, Color fg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$k: $v',
        textAlign: TextAlign.right,
        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: fg),
      ),
    );
  }

  static Widget _incomingOfferCard({
    required BuildContext context,
    required ChatMessageModel message,
    required Color fg,
    required UserRole inboxRole,
    required void Function(bool accept)? onFarmerDecision,
  }) {
    final pending = message.offerPendingFarmerAction == true;
    final d = message.offerDeliveryDate;

    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'عرض سعري',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
        const SizedBox(height: 6),
        _line('المنتج', message.offerCrop ?? '—', fg),
        _line('الكمية', '${message.offerQtyKg?.toStringAsFixed(0) ?? '—'} كجم', fg),
        _line('السعر المقترح', '${message.offerPricePerKg?.toStringAsFixed(2) ?? '—'} د.أ/كجم', fg),
        if (d != null) _line('التسليم', formatOfferDateShortAr(d), fg),
        if (inboxRole == UserRole.farmer && pending && onFarmerDecision != null) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () => onFarmerDecision(false),
                style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                child: const Text('رفض', style: TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => onFarmerDecision(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
                child: const Text('قبول', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ],
      ],
    );

    return card;
  }
}
