import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? false;

  static const _kSanadId = 'hasad_sanad_national_id';
  static const _kRole = 'hasad_saved_role';
  static const _kIsGuest = 'hasad_is_guest';

  // Demo users
  static final UserModel _demoFarmer = UserModel(
    id: 'farmer_001',
    email: 'ahmed@example.com',
    name: 'أحمد محمد العتيبي',
    role: UserRole.farmer,
    phoneNumber: '+966 50 123 4567',
    location: 'الرياض، المملكة العربية السعودية',
    rating: 4.8,
    reviewCount: 12,
    status: UserStatus.approved,
    createdAt: DateTime(2025, 1, 15),
  );

  static final UserModel _demoTrader = UserModel(
    id: 'trader_001',
    email: 'trader@example.com',
    name: 'محمد الشمري',
    role: UserRole.trader,
    phoneNumber: '+966 55 987 6543',
    location: 'جدة، المملكة العربية السعودية',
    rating: 4.5,
    reviewCount: 8,
    status: UserStatus.approved,
    createdAt: DateTime(2025, 2, 10),
  );

  static final UserModel _demoFactory = UserModel(
    id: 'factory_001',
    email: 'factory@example.com',
    name: 'مصنع الأغذية الوطني',
    role: UserRole.factory,
    phoneNumber: '+966 12 345 6789',
    location: 'الدمام، المملكة العربية السعودية',
    rating: 4.7,
    reviewCount: 25,
    status: UserStatus.approved,
    createdAt: DateTime(2024, 11, 5),
  );

  static UserRole _roleFromName(String? name) {
    switch (name) {
      case 'trader':
        return UserRole.trader;
      case 'factory':
        return UserRole.factory;
      case 'farmer':
      default:
        return UserRole.farmer;
    }
  }

  /// استعادة جلسة سند أو زائر من التخزين المحلي (محاكاة).
  Future<bool> tryRestoreSession() async {
    final p = await SharedPreferences.getInstance();
    final isGuest = p.getBool(_kIsGuest) ?? false;
    if (isGuest) {
      _applyGuestUser();
      notifyListeners();
      return true;
    }
    final nid = p.getString(_kSanadId);
    final roleName = p.getString(_kRole);
    if (nid != null && nid.length == 10 && roleName != null) {
      _applySanadUser(nationalId: nid, role: _roleFromName(roleName));
      notifyListeners();
      return true;
    }
    return false;
  }

  void _applySanadUser({required String nationalId, required UserRole role}) {
    final name = switch (role) {
      UserRole.farmer => 'مستخدم سند — مزارع',
      UserRole.trader => 'مستخدم سند — تاجر',
      UserRole.factory => 'مستخدم سند — مصنع',
    };
    _currentUser = UserModel(
      id: 'sanad_$nationalId',
      email: '$nationalId@sanad.mock',
      name: name,
      role: role,
      phoneNumber: nationalId,
      location: 'الأردن',
      status: UserStatus.approved,
      createdAt: DateTime.now(),
      nationalId: nationalId,
      isGuest: false,
    );
  }

  void _applyGuestUser() {
    _currentUser = UserModel(
      id: 'guest',
      email: '',
      name: 'زائر',
      role: UserRole.farmer,
      phoneNumber: '',
      status: UserStatus.approved,
      createdAt: DateTime.now(),
      isGuest: true,
    );
  }

  Future<void> _persistSanad(String nationalId, UserRole role) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSanadId, nationalId);
    await p.setString(_kRole, role.name);
    await p.setBool(_kIsGuest, false);
  }

  Future<void> _persistGuest() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSanadId);
    await p.remove(_kRole);
    await p.setBool(_kIsGuest, true);
  }

  Future<void> _clearPersistedSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSanadId);
    await p.remove(_kRole);
    await p.remove(_kIsGuest);
  }

  /// محاكاة تسجيل الدخول عبر سند (كلمة السر لا تُخزَّن).
  Future<void> loginWithSanadMock({
    required String nationalId,
    required UserRole role,
  }) async {
    _applySanadUser(nationalId: nationalId, role: role);
    await _persistSanad(nationalId, role);
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    _applyGuestUser();
    await _persistGuest();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (password.length >= 6) {
      if (email.contains('trader')) {
        _currentUser = _demoTrader;
      } else if (email.contains('factory')) {
        _currentUser = _demoFactory;
      } else {
        _currentUser = _demoFarmer;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _error = 'بيانات الدخول غير صحيحة';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signup(
      String name, String email, String phone, String password, UserRole role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
      phoneNumber: phone,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void loginAsFarmer() {
    _currentUser = _demoFarmer;
    notifyListeners();
  }

  void loginAsTrader() {
    _currentUser = _demoTrader;
    notifyListeners();
  }

  void loginAsFactory() {
    _currentUser = _demoFactory;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _error = null;
    await _clearPersistedSession();
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}
