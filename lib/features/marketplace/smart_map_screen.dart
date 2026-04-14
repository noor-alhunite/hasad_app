import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as lm;
import 'package:hasad_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/chat_inbox_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/helpers/crop_image_assets.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/chat_models.dart';
import 'price_comparison_screen.dart';

// -----------------------------------------------------------------------------
// درجة النضج: يُعرَف لونها بالإطار فقط (أخضر / أصفر / بني).
// -----------------------------------------------------------------------------
enum CropMaturityFrame {
  ripe, // #4CAF50
  halfRipe, // #FFC107
  unripe, // #795548
}

extension on CropMaturityFrame {
  Color get frameColor {
    switch (this) {
      case CropMaturityFrame.ripe:
        return const Color(0xFF4CAF50);
      case CropMaturityFrame.halfRipe:
        return const Color(0xFFFFC107);
      case CropMaturityFrame.unripe:
        return const Color(0xFF795548);
    }
  }

  /// وصف نصي لدرجة النضج (يُعرض مع الإطار الملوّن في الورقة السفلية).
  String get labelAr {
    switch (this) {
      case CropMaturityFrame.ripe:
        return 'ناضج بالكامل';
      case CropMaturityFrame.halfRipe:
        return 'نصف ناضج';
      case CropMaturityFrame.unripe:
        return 'غير ناضج';
    }
  }
}

/// إزاحة بسيطة لكل منتج داخل المحافظة حتى لا تتكدس الدبابيس فوق بعضها.
LatLng _pinLatLng(JordanGovernorate g, int productIndex) {
  final n = g.products.length;
  final angle = 2 * math.pi * productIndex / math.max(n, 1);
  const base = 0.028;
  final r = base * (1 + 0.35 * productIndex);
  return LatLng(
    g.center.latitude + r * math.cos(angle),
    g.center.longitude + r * math.sin(angle),
  );
}

lm.LatLng _pinLm(JordanGovernorate g, int productIndex) {
  final p = _pinLatLng(g, productIndex);
  return lm.LatLng(p.latitude, p.longitude);
}

/// عنصر منتج في الخريطة (بيانات وهمية).
class SmartMapProduct {
  final String cropName;
  final String farmerName;
  final double quantityKg;
  /// سعر الدينار الأردني للكيلوغرام
  final double pricePerKgJd;
  final CropMaturityFrame maturity;

  const SmartMapProduct({
    required this.cropName,
    required this.farmerName,
    required this.quantityKg,
    required this.pricePerKgJd,
    required this.maturity,
  });
}

/// محافظة أردنية مع مركز تقريبي على الخريطة.
class JordanGovernorate {
  final String id;
  final String nameAr;
  final LatLng center;
  final List<SmartMapProduct> products;

  const JordanGovernorate({
    required this.id,
    required this.nameAr,
    required this.center,
    required this.products,
  });
}

/// بيانات وهمية: محافظات + منتجات وأسعار بالدينار الأردني.
final List<JordanGovernorate> kJordanSmartMapMock = [
  JordanGovernorate(
    id: 'amman',
    nameAr: 'عمان',
    center: const LatLng(31.9539, 35.9106),
    products: [
      SmartMapProduct(
        cropName: 'طماطم',
        farmerName: 'أحمد الشمري',
        quantityKg: 500,
        pricePerKgJd: 4.5,
        maturity: CropMaturityFrame.ripe,
      ),
      SmartMapProduct(
        cropName: 'خيار',
        farmerName: 'خالد أبو ليلى',
        quantityKg: 320,
        pricePerKgJd: 3.2,
        maturity: CropMaturityFrame.halfRipe,
      ),
      SmartMapProduct(
        cropName: 'فلفل',
        farmerName: 'سامر النابلسي',
        quantityKg: 180,
        pricePerKgJd: 5.0,
        maturity: CropMaturityFrame.unripe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'zarqa',
    nameAr: 'الزرقاء',
    center: const LatLng(32.0756, 36.0879),
    products: [
      SmartMapProduct(
        cropName: 'باذنجان',
        farmerName: 'محمود العبادي',
        quantityKg: 410,
        pricePerKgJd: 3.8,
        maturity: CropMaturityFrame.ripe,
      ),
      SmartMapProduct(
        cropName: 'كوسة',
        farmerName: 'يوسف الزريقات',
        quantityKg: 260,
        pricePerKgJd: 2.9,
        maturity: CropMaturityFrame.halfRipe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'irbid',
    nameAr: 'إربد',
    center: const LatLng(32.5556, 35.8500),
    products: [
      SmartMapProduct(
        cropName: 'خيار',
        farmerName: 'طارق الحسن',
        quantityKg: 600,
        pricePerKgJd: 2.7,
        maturity: CropMaturityFrame.ripe,
      ),
      SmartMapProduct(
        cropName: 'طماطم',
        farmerName: 'ليث الكردي',
        quantityKg: 900,
        pricePerKgJd: 4.1,
        maturity: CropMaturityFrame.halfRipe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'aghwar',
    nameAr: 'الأغوار',
    center: const LatLng(32.2880, 35.5500),
    products: [
      SmartMapProduct(
        cropName: 'فلفل',
        farmerName: 'عمر الدعجة',
        quantityKg: 1200,
        pricePerKgJd: 4.8,
        maturity: CropMaturityFrame.ripe,
      ),
      SmartMapProduct(
        cropName: 'باذنجان',
        farmerName: 'رامي الطراونة',
        quantityKg: 340,
        pricePerKgJd: 3.5,
        maturity: CropMaturityFrame.unripe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'mafraq',
    nameAr: 'المفرق',
    center: const LatLng(32.3427, 36.2256),
    products: [
      SmartMapProduct(
        cropName: 'بطاطس',
        farmerName: 'فادي السالم',
        quantityKg: 2000,
        pricePerKgJd: 1.2,
        maturity: CropMaturityFrame.halfRipe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'balqa',
    nameAr: 'البلقاء',
    center: const LatLng(32.0392, 35.7272),
    products: [
      SmartMapProduct(
        cropName: 'طماطم',
        farmerName: 'هشام السلطي',
        quantityKg: 750,
        pricePerKgJd: 4.3,
        maturity: CropMaturityFrame.ripe,
      ),
      SmartMapProduct(
        cropName: 'خيار',
        farmerName: 'علي العموش',
        quantityKg: 400,
        pricePerKgJd: 3.0,
        maturity: CropMaturityFrame.unripe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'karak',
    nameAr: 'الكرك',
    center: const LatLng(31.1853, 35.7048),
    products: [
      SmartMapProduct(
        cropName: 'باذنجان',
        farmerName: 'صهيب المجالي',
        quantityKg: 280,
        pricePerKgJd: 3.6,
        maturity: CropMaturityFrame.ripe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'maan',
    nameAr: 'معان',
    center: const LatLng(30.1921, 35.7361),
    products: [
      SmartMapProduct(
        cropName: 'بطاطس',
        farmerName: 'زياد الرقاد',
        quantityKg: 1500,
        pricePerKgJd: 1.1,
        maturity: CropMaturityFrame.halfRipe,
      ),
      SmartMapProduct(
        cropName: 'طماطم',
        farmerName: 'عادل النسور',
        quantityKg: 420,
        pricePerKgJd: 4.0,
        maturity: CropMaturityFrame.unripe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'jerash',
    nameAr: 'جرش',
    center: const LatLng(32.2804, 35.8994),
    products: [
      SmartMapProduct(
        cropName: 'خيار',
        farmerName: 'باسم جرشاوي',
        quantityKg: 510,
        pricePerKgJd: 2.85,
        maturity: CropMaturityFrame.ripe,
      ),
    ],
  ),
  JordanGovernorate(
    id: 'ajloun',
    nameAr: 'عجلون',
    center: const LatLng(32.3322, 35.7518),
    products: [
      SmartMapProduct(
        cropName: 'فلفل',
        farmerName: 'مروان العجلوني',
        quantityKg: 220,
        pricePerKgJd: 5.2,
        maturity: CropMaturityFrame.halfRipe,
      ),
      SmartMapProduct(
        cropName: 'طماطم',
        farmerName: 'أنس العموش',
        quantityKg: 380,
        pricePerKgJd: 4.45,
        maturity: CropMaturityFrame.ripe,
      ),
    ],
  ),
];

/// مسافة تقريبية (كم) بين نقطتين على سطح الكرة — لحساب المسافة من المستخدم للمحافظة.
double haversineKm(LatLng a, LatLng b) {
  const earthKm = 6371.0;
  final dLat = _rad(b.latitude - a.latitude);
  final dLng = _rad(b.longitude - a.longitude);
  final lat1 = _rad(a.latitude);
  final lat2 = _rad(b.latitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return earthKm * c;
}

double _rad(double d) => d * math.pi / 180.0;

/// صورة المحصول 40×40 مع إطار دائري بلون درجة النضج (دبوس الخريطة على الويب والورقة السفلية).
class _MapPinCropAvatar extends StatelessWidget {
  final SmartMapProduct product;
  final double size;

  const _MapPinCropAvatar({
    required this.product,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final asset = resolveCropImageAsset(product.cropName);
    final ring = size > 36 ? 3.0 : 2.5;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: product.maturity.frameColor.withAlpha(110),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        width: size + ring * 2,
        height: size + ring * 2,
        padding: EdgeInsets.all(ring * 0.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: product.maturity.frameColor,
            width: ring,
          ),
          color: Colors.white,
        ),
        child: ClipOval(
          child: Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/crop_default.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class SmartMapScreen extends StatefulWidget {
  final bool isGuestMode;
  final VoidCallback? onGuestExit;

  const SmartMapScreen({
    super.key,
    this.isGuestMode = false,
    this.onGuestExit,
  });

  @override
  State<SmartMapScreen> createState() => _SmartMapScreenState();
}

class _SmartMapScreenState extends State<SmartMapScreen> {
  LatLng? _userLatLng;
  bool _locationDenied = false;

  /// علامات Google (موبايل) — أيقونات مُنشأة من صورة المحصول + إطار النضج.
  Set<Marker> _gmapMarkers = {};
  final Map<String, BitmapDescriptor> _gmapIconCache = {};

  static const LatLng _jordanCenter = LatLng(31.15, 36.0);
  static const double _initialZoom = 7.35;

  @override
  void initState() {
    super.initState();
    _initUserLocation();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoogleMapMarkers());
    }
  }

  Future<void> _initUserLocation() async {
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        if (mounted) setState(() => _locationDenied = true);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationDenied = true);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;
      setState(() {
        _userLatLng = LatLng(pos.latitude, pos.longitude);
        _locationDenied = false;
      });
    } catch (_) {
      if (mounted) setState(() => _locationDenied = true);
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorForProduct(SmartMapProduct p) async {
    final cacheKey = '${resolveCropImageAsset(p.cropName)}_${p.maturity.index}';
    final cached = _gmapIconCache[cacheKey];
    if (cached != null) return cached;

    try {
      const double canvasSize = 52;
      const double imgD = 40;
      const double borderW = 3;
      final assetPath = resolveCropImageAsset(p.cropName);
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: imgD.toInt(),
        targetHeight: imgD.toInt(),
      );
      final fi = await codec.getNextFrame();
      final uiImage = fi.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final center = const Offset(canvasSize / 2, canvasSize / 2);
      final outerR = imgD / 2 + borderW / 2;

      final glow = Paint()
        ..color = p.maturity.frameColor.withAlpha(90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, outerR + 2, glow);

      final border = Paint()
        ..color = p.maturity.frameColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderW;
      canvas.drawCircle(center, outerR, border);

      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: imgD / 2)),
      );
      final src = Rect.fromLTWH(
        0,
        0,
        uiImage.width.toDouble(),
        uiImage.height.toDouble(),
      );
      final dst = Rect.fromCenter(center: center, width: imgD, height: imgD);
      canvas.drawImageRect(uiImage, src, dst, Paint());
      canvas.restore();

      final picture = recorder.endRecording();
      final outImg = await picture.toImage(canvasSize.toInt(), canvasSize.toInt());
      final bd = await outImg.toByteData(format: ui.ImageByteFormat.png);
      final desc = BitmapDescriptor.bytes(bd!.buffer.asUint8List());
      _gmapIconCache[cacheKey] = desc;
      return desc;
    } catch (_) {
      final fallback = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _gmapIconCache[cacheKey] = fallback;
      return fallback;
    }
  }

  Future<void> _loadGoogleMapMarkers() async {
    final next = <Marker>{};
    for (final g in kJordanSmartMapMock) {
      for (var pi = 0; pi < g.products.length; pi++) {
        final p = g.products[pi];
        final pos = _pinLatLng(g, pi);
        final icon = await _bitmapDescriptorForProduct(p);
        next.add(
          Marker(
            markerId: MarkerId('${g.id}_$pi'),
            position: pos,
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            onTap: () => _openProductSheet(g, p),
          ),
        );
      }
    }
    if (mounted) setState(() => _gmapMarkers = next);
  }

  void _openProductSheet(JordanGovernorate gov, SmartMapProduct p) {
    final user = _userLatLng;
    final distanceKm = user != null
        ? haversineKm(user, gov.center)
        : 25.0 + (gov.id.hashCode % 80);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MapPinCropAvatar(product: p, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              p.farmerName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gov.nameAr,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sheetRow('المنتج', p.cropName),
                  _sheetRow('الكمية المتاحة', '${p.quantityKg.toStringAsFixed(0)} كجم'),
                  _sheetRow('السعر', '${p.pricePerKgJd.toStringAsFixed(2)} دينار/كجم'),
                  _sheetRow('المسافة', '${distanceKm.toStringAsFixed(0)} كم'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          p.maturity.labelAr,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: Color.lerp(
                                  p.maturity.frameColor,
                                  Colors.black,
                                  0.35,
                                ) ??
                                p.maturity.frameColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MapPinCropAvatar(product: p, size: 36),
                    ],
                  ),
                  if (_locationDenied || _userLatLng == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'تقدير المسافة — فعّل الموقع لدقة أعلى',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _onContactFarmer(p, gov.nameAr);
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('تواصل', style: TextStyle(fontFamily: 'Cairo')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sheetRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContactFarmer(
    SmartMapProduct product,
    String governorateName,
  ) {
    final isGuest = widget.isGuestMode ||
        (context.read<UserProvider>().currentUser?.isGuest ?? false);
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'سجّل الدخول عبر سند للتواصل مع المزارعين',
          ),
        ),
      );
      return;
    }
    final u = context.read<UserProvider>().currentUser;
    if (u?.role == UserRole.farmer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'محادثات المزارع مع التجار والمصانع فقط — لا يمكن فتح محادثة مع مزارع آخر من هنا.',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }
    final role = u!.role;
    final threadId = context.read<ChatInboxProvider>().openOrCreateThread(
          peerName: product.farmerName,
          topicSubtitle: '${product.cropName} — $governorateName',
          avatarAssetPath: resolveCropImageAsset(product.cropName),
          viewerRole: role,
          peerKind: ChatPeerKind.farmer,
        );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatDetailScreen(threadId: threadId),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// على الويب: OpenStreetMap عبر flutter_map (بدون مفتاح Google). على Android/iOS: Google Maps.
  Widget _buildMapLayer() {
    if (kIsWeb) {
      return fm.FlutterMap(
        options: fm.MapOptions(
          initialCenter: lm.LatLng(_jordanCenter.latitude, _jordanCenter.longitude),
          initialZoom: _initialZoom,
          minZoom: 5,
          maxZoom: 18,
        ),
        children: [
          fm.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'hasad_app',
          ),
          fm.MarkerLayer(
            markers: [
              for (final g in kJordanSmartMapMock)
                for (var pi = 0; pi < g.products.length; pi++)
                  fm.Marker(
                    point: _pinLm(g, pi),
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => _openProductSheet(g, g.products[pi]),
                      child: _MapPinCropAvatar(
                        product: g.products[pi],
                        size: 40,
                      ),
                    ),
                  ),
            ],
          ),
          fm.SimpleAttributionWidget(
            alignment: Alignment.bottomLeft,
            source: const Text(
              'OpenStreetMap',
              style: TextStyle(fontSize: 11, decoration: TextDecoration.underline),
            ),
            onTap: () {},
          ),
        ],
      );
    }
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _jordanCenter,
        zoom: _initialZoom,
      ),
      markers: _gmapMarkers,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: true,
      myLocationEnabled: _userLatLng != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGuest =
        widget.isGuestMode || (context.watch<UserProvider>().currentUser?.isGuest ?? false);
    final role = context.watch<UserProvider>().currentUser?.role;
    final showPriceCompare =
        !isGuest && (role == UserRole.trader || role == UserRole.factory);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildMapLayer()),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.isGuestMode) ...[
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: widget.onGuestExit,
                            tooltip: 'خروج',
                          ),
                          const Expanded(
                            child: Text(
                              'وضع الزائر — تصفح الخريطة فقط',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      l10n.directMarket,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.aiSubtitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isGuest)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'للمحادثة مع المزارعين سجّل الدخول',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          // مقارنة الأسعار — للتاجر والمصنع فقط (زر يفتح [PriceComparisonScreen]).
          if (showPriceCompare)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const PriceComparisonScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📊', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text(
                          'مقارنة الأسعار',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
