import 'package:flutter/material.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  int _selectedTab = 0;

  List<Map<String, dynamic>> _getRecommendations(AppLocalizations l10n) => [
        {
          'title': '${l10n.golden_opportunity} - ${l10n.tomatoes}',
          'body': l10n.high_demand,
          'type': 'opportunity',
          'icon': Icons.trending_up,
          'color': AppColors.primaryGreen,
          'tag': l10n.golden_opportunity,
        },
        {
          'title': '${l10n.warning} - ${l10n.cucumber}',
          'body': l10n.shortage,
          'type': 'warning',
          'icon': Icons.warning_amber,
          'color': AppColors.warning,
          'tag': l10n.warning,
        },
        {
          'title': '${l10n.high_demand} - ${l10n.watermelon}',
          'body': '${l10n.high_demand}. 3.5 ${l10n.price_per_kg}',
          'type': 'demand',
          'icon': Icons.local_fire_department,
          'color': const Color(0xFFE65100),
          'tag': l10n.high_demand,
        },
        {
          'title': '${l10n.shortage} - ${l10n.pepper}',
          'body': l10n.shortage,
          'type': 'shortage',
          'icon': Icons.inventory_2,
          'color': const Color(0xFF7B1FA2),
          'tag': l10n.shortage,
        },
      ];

  List<Map<String, dynamic>> _getAnalytics(AppLocalizations l10n) => [
        {
          'title': '${l10n.analytics} - ${l10n.tomatoes}',
          'body': '4.5 ${l10n.price_per_kg} → 5.2 ${l10n.price_per_kg}',
          'icon': Icons.bar_chart,
          'color': AppColors.primaryGreen,
        },
        {
          'title': l10n.analytics,
          'body': l10n.aiSubtitle,
          'icon': Icons.people,
          'color': const Color(0xFF0288D1),
        },
        {
          'title': l10n.weatherAlert,
          'body': l10n.farmSummary,
          'icon': Icons.wb_sunny,
          'color': Colors.amber,
        },
      ];

  List<Map<String, dynamic>> _getPersonal(AppLocalizations l10n) => [
        {
          'title': l10n.personal,
          'body': l10n.aiSubtitle,
          'icon': Icons.agriculture,
          'color': AppColors.primaryGreen,
        },
        {
          'title': l10n.aiRecommendations,
          'body': l10n.viewMarketAnalysis,
          'icon': Icons.lightbulb,
          'color': Colors.amber,
        },
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [l10n.recommendations, l10n.analytics, l10n.personal];
    final items = _selectedTab == 0
        ? _getRecommendations(l10n)
        : _selectedTab == 1
            ? _getAnalytics(l10n)
            : _getPersonal(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((255 * 0.2).round()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.psychology,
                            color: Colors.white, size: 24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.aiAssistantTitle,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.aiSubtitle,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(tabs.length, (index) {
                      final isSelected = _selectedTab == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTab = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withAlpha((255 * 0.2).round()),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: isSelected
                                  ? const Color(0xFF7B1FA2)
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          // AI Items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return _AiCard(item: item, l10n: l10n);
              },
              childCount: items.length,
            ),
          ),
          // Chat Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => _showChatDialog(context, l10n),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.aiAssistantTitle,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    l10n.aiAssistantTitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.psychology, color: Colors.white),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ChatBubble(
                    message: l10n.aiSubtitle,
                    isAi: true,
                  ),
                  _ChatBubble(
                    message: l10n.farmSummary,
                    isAi: false,
                  ),
                  _ChatBubble(
                    message: l10n.viewMarketAnalysis,
                    isAi: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7B1FA2),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: l10n.searchProduct,
                        hintStyle: const TextStyle(
                            fontFamily: 'Cairo', color: AppColors.grey),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final AppLocalizations l10n;

  const _AiCard({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final Color color = item['color'] as Color;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.containsKey('tag'))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha((255 * 0.1).round()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['tag'],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(item['icon'] as IconData, color: color, size: 18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['body'],
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.viewDetails,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_back_ios, size: 12, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isAi;

  const _ChatBubble({required this.message, required this.isAi});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAi ? const Color(0xFFF3E5F5) : AppColors.primaryGreen,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isAi ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight:
                isAi ? const Radius.circular(16) : const Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: isAi ? AppColors.textPrimary : Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
