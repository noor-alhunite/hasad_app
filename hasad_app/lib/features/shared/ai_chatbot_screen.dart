import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import 'ai_chatbot_mock_service.dart';

// ألوان الفقاعات كما في المواصفات
const Color _kUserBubbleColor = Color(0xFF4CAF50);
const Color _kAiBubbleColor = Color(0xFFEEEEEE);

/// شاشة دردشة المساعد الذكي (تصميم قريب من واتساب).
/// الألوان: مستخدم [#4CAF50]، الذكاء الاصطناعي [#EEEEEE].
class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({
    super.key,
    required this.userRole,
  });

  final UserRole userRole;

  /// فتح الشاشة من الصفحة الرئيسية أو أي مكان.
  static Future<void> open(BuildContext context, {required UserRole userRole}) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiChatbotScreen(userRole: userRole),
      ),
    );
  }

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _ChatLine {
  _ChatLine({
    required this.isUser,
    required this.text,
    this.isImageCaption = false,
  });

  final bool isUser;
  final String text;
  final bool isImageCaption;
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatLine> _messages = [];
  bool _welcomeCheckDone = false;

  static String _prefsKey(UserRole r) => 'hasad_ai_chat_welcome_${r.name}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowWelcome());
  }

  Future<void> _maybeShowWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKey(widget.userRole);
    final seen = prefs.getBool(key) ?? false;
    if (!seen) {
      await prefs.setBool(key, true);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatLine(
            isUser: false,
            text: AiChatbotMockService.welcomeMessage(DateTime.now()),
          ),
        );
      });
      _scrollToBottom();
    }
    if (!mounted) return;
    setState(() => _welcomeCheckDone = true);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText() async {
    final raw = _input.text.trim();
    if (raw.isEmpty) return;
    _input.clear();
    setState(() {
      _messages.add(_ChatLine(isUser: true, text: raw));
    });
    _scrollToBottom();

    final reply = AiChatbotMockService.getMockReply(
      role: widget.userRole,
      userMessage: raw,
      messageHadImage: false,
    );

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatLine(isUser: false, text: reply));
    });
    _scrollToBottom();
  }

  Future<void> _pickAndAnalyzeImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (x == null || !mounted) return;

    setState(() {
      _messages.add(
        _ChatLine(
          isUser: true,
          text: '📷 تم اختيار صورة للمرفقات',
          isImageCaption: true,
        ),
      );
    });
    _scrollToBottom();

    // رد وهمي لمسار «إرفاق» كما في المواصفات (تحليل حقيقي لاحقاً عبر API).
    final reply = AiChatbotMockService.mockImageAnalysisReply();

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatLine(isUser: false, text: reply));
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.userRole) {
      UserRole.farmer => 'المساعد الذكي — مزارع',
      UserRole.trader => 'المساعد الذكي — تاجر',
      UserRole.factory => 'المساعد الذكي — مصنع',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.smart_toy, color: Colors.white70),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: !_welcomeCheckDone
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'اكتب سؤالك في الأسفل، أو استخدم 📎 لإرفاق صورة (تحليل وهمي).',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final m = _messages[index];
                          return _Bubble(line: m);
                        },
                      ),
          ),
          // TODO: استبدال منطق [AiChatbotMockService] بطلب POST إلى API حقيقي (مفتاح من البيئة).
          SafeArea(
            child: Material(
              color: const Color(0xFFF0F0F0),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 8,
                  top: 6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'إرفاق صورة',
                      onPressed: _pickAndAnalyzeImage,
                      icon: const Text('📎', style: TextStyle(fontSize: 22)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textAlign: TextAlign.right,
                        minLines: 1,
                        maxLines: 5,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'اكتب سؤالك...',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendText(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Material(
                      color: AppColors.primaryGreen,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _sendText,
                        child: const SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(Icons.send, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.line});

  final _ChatLine line;

  @override
  Widget build(BuildContext context) {
    final isUser = line.isUser;
    final bg = isUser ? _kUserBubbleColor : _kAiBubbleColor;
    final fg = isUser ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.06).round()),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          line.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            height: 1.35,
            color: fg,
          ),
        ),
      ),
    );
  }
}
