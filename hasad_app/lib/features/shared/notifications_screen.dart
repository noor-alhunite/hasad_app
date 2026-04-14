import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/models/notification_model.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/shell_tab_bridge.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<NotificationProvider>();

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
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (provider.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((255 * 0.2).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${provider.unreadCount} ${l10n.newNotifications}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        l10n.notificationsTitle,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _TabButton(
                        label: l10n.offers,
                        isSelected: provider.selectedTab == 'offers',
                        onTap: () => provider.setSelectedTab('offers'),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: l10n.reminders,
                        isSelected: provider.selectedTab == 'reminders',
                        onTap: () => provider.setSelectedTab('reminders'),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: l10n.weather,
                        isSelected: provider.selectedTab == 'weather',
                        onTap: () => provider.setSelectedTab('weather'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (provider.unreadCount == 0) return;
                          provider.markAllAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تم تعليم كل التنبيهات كمقروءة')),
                          );
                        },
                        child: const Text(
                          'تحديد الكل كمقروء',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'تنبيهات جوية',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        ),
                        Switch(
                          value: provider.weatherAlertsEnabled,
                          onChanged: (v) => provider.setWeatherAlertsEnabled(v),
                          activeThumbColor: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // AI Recommendation Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.read<ShellTabBridge>().goToTab(2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((255 * 0.2).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.viewDetails,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.smartRecommendations,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.viewMarketAnalysis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.psychology, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
          ),
          // Notifications List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final List<NotificationModel> notifications;
                switch (provider.selectedTab) {
                  case 'weather':
                    notifications = provider.weatherNotifications;
                    break;
                  case 'reminders':
                    notifications = provider.reminderNotifications;
                    break;
                  case 'offers':
                    notifications = provider.offerNotifications;
                    break;
                  default:
                    notifications = provider.allNotifications;
                }

                if (notifications.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        l10n.no_notifications,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                final notif = notifications[index];
                return _NotificationCard(
                  notification: notif,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          notif.title,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                        content: SingleChildScrollView(
                          child: Text(
                            notif.body,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إغلاق'),
                          ),
                        ],
                      ),
                    );
                    provider.markAsRead(notif.id);
                  },
                );
              },
              childCount: () {
                switch (provider.selectedTab) {
                  case 'weather':
                    return provider.weatherNotifications.isEmpty
                        ? 1
                        : provider.weatherNotifications.length;
                  case 'reminders':
                    return provider.reminderNotifications.isEmpty
                        ? 1
                        : provider.reminderNotifications.length;
                  case 'offers':
                    return provider.offerNotifications.isEmpty
                        ? 1
                        : provider.offerNotifications.length;
                  default:
                    return provider.allNotifications.isEmpty
                        ? 1
                        : provider.allNotifications.length;
                }
              }(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withAlpha((255 * 0.2).round()),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.weather:
        return Icons.cloud;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.change:
        return Icons.trending_up;
      case NotificationType.ai:
        return Icons.psychology;
    }
  }

  Color get _color {
    switch (notification.type) {
      case NotificationType.weather:
        return const Color(0xFF1565C0);
      case NotificationType.reminder:
        return AppColors.primaryGreen;
      case NotificationType.offer:
        return const Color(0xFFE65100);
      case NotificationType.change:
        return const Color(0xFF7B1FA2);
      case NotificationType.ai:
        return const Color(0xFF7B1FA2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.white
              : _color.withAlpha((255 * 0.04).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? AppColors.lightGrey
                : _color.withAlpha((255 * 0.2).round()),
          ),
        ),
        child: Row(
          children: [
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.timeAgo,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _color.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
