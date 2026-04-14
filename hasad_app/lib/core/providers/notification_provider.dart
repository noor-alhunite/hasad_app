import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  String _selectedTab = 'weather';
  bool _weatherAlertsEnabled = true;

  NotificationProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _weatherAlertsEnabled = p.getBool('hasad_weather_alerts') ?? true;
    notifyListeners();
  }

  bool get weatherAlertsEnabled => _weatherAlertsEnabled;

  Future<void> setWeatherAlertsEnabled(bool value) async {
    _weatherAlertsEnabled = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool('hasad_weather_alerts', value);
    notifyListeners();
  }

  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      title: 'أمطار متوقعة',
      body: 'أمطار غزيرة متوقعة يوم غد. يُنصح بتأجيل الري',
      type: NotificationType.weather,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'n2',
      title: 'رياح قوية',
      body: 'رياح قوية متوقعة مساء اليوم. تأكد من تثبيت الأغطية',
      type: NotificationType.weather,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'n3',
      title: 'تحذير من الصقيع',
      body: 'انخفاض في درجات الحرارة ليلاً. احمِ المحاصيل الحساسة',
      type: NotificationType.weather,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'n4',
      title: 'موعد الري',
      body: 'حان موعد ري محصول الطماطم في القطعة الشمالية',
      type: NotificationType.reminder,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'n5',
      title: 'موعد التسميد',
      body: 'موعد إضافة السماد الأسبوعي لمحصول الخيار',
      type: NotificationType.reminder,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NotificationModel(
      id: 'n6',
      title: 'عرض شراء جديد',
      body: 'تاجر - محمد الشمري أرسل عرضاً لشراء 200 كجم طماطم بسعر 5 ر.س/كجم',
      type: NotificationType.offer,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: 'n7',
      title: 'طلب توريد',
      body: 'مصنع الأغذية الوطني يطلب 500 كجم خيار للتوريد الأسبوعي',
      type: NotificationType.offer,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  String get selectedTab => _selectedTab;

  List<NotificationModel> get allNotifications => _notifications;

  List<NotificationModel> get weatherNotifications =>
      _notifications.where((n) => n.type == NotificationType.weather).toList();

  List<NotificationModel> get reminderNotifications =>
      _notifications.where((n) => n.type == NotificationType.reminder).toList();

  List<NotificationModel> get offerNotifications =>
      _notifications.where((n) => n.type == NotificationType.offer).toList();

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        createdAt: _notifications[index].createdAt,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      _notifications[i] = NotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        createdAt: n.createdAt,
        isRead: true,
      );
    }
    notifyListeners();
  }
}
