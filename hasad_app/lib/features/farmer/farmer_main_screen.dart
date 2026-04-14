import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/shell_tab_bridge.dart';
import '../chat/chats_list_screen.dart';
import 'farmer_map_screen.dart';
import '../shared/ai_chatbot_screen.dart';
import '../shared/notifications_screen.dart';
import 'farmer_contracts_list_screen.dart';
import 'farmer_dashboard_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerMainScreen extends StatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 3;
  late final ShellTabBridge _shell;

  static const int _tabCount = 7;

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
        context.watch<UserProvider>().currentUser?.role ?? UserRole.farmer;
    final screens = <Widget>[
      const FarmerMapScreen(),
      const ChatsListScreen(),
      AiChatbotScreen(userRole: role),
      const FarmerDashboardScreen(),
      const FarmerContractsListScreen(),
      const NotificationsScreen(),
      const FarmerProfileScreen(),
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
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
        ),
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
            icon: const Icon(Icons.psychology_outlined),
            activeIcon: const Icon(Icons.psychology),
            label: l10n.aiAssistant,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grass_outlined),
            activeIcon: const Icon(Icons.grass),
            label: l10n.seasons,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description_outlined),
            activeIcon: const Icon(Icons.description),
            label: 'عقود',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: l10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
