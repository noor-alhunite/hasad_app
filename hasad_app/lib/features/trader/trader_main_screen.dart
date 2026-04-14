// القشرة الرئيسية للتاجر: 6 تبويبات فقط (خريطة، محادثات، ذكاء، رئيسية، تنبيهات، حساب).
// لا تُستورد هنا شاشات المصنع أو العقود — الدوران منفصلان في التنقل والملفات.
import 'package:flutter/material.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/shell_tab_bridge.dart';
import '../chat/chats_list_screen.dart';
import '../marketplace/smart_map_screen.dart';
import '../shared/ai_chatbot_screen.dart';
import '../shared/notifications_screen.dart';
import 'trader_dashboard_screen.dart';
import 'trader_profile_screen.dart';

class TraderMainScreen extends StatefulWidget {
  const TraderMainScreen({super.key});

  @override
  State<TraderMainScreen> createState() => _TraderMainScreenState();
}

class _TraderMainScreenState extends State<TraderMainScreen> {
  int _currentIndex = 3;
  late final ShellTabBridge _shell;

  static const int _tabCount = 6;

  @override
  void initState() {
    super.initState();
    _shell = context.read<ShellTabBridge>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _shell.bind((i) {
        if (mounted) {
          setState(() => _currentIndex = i.clamp(0, _tabCount - 1));
        }
      });
    });
  }

  @override
  void dispose() {
    _shell.unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final role =
        context.watch<UserProvider>().currentUser?.role ?? UserRole.trader;
    final screens = <Widget>[
      const SmartMapScreen(),
      const ChatsListScreen(),
      AiChatbotScreen(userRole: role),
      const TraderDashboardScreen(),
      const NotificationsScreen(),
      const TraderProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.smartMapTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            activeIcon: const Icon(Icons.chat_bubble),
            label: l10n.chatsTitle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'الذكاء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'التنبيهات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
