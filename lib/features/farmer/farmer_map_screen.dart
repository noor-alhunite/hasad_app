import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as lm;
import '../../core/app_colors.dart';
import '../../shared/helpers/crop_image_assets.dart';
import 'add_season_screen.dart';
import 'farmer_map_mock.dart';
import 'season_detail_screen.dart';

// -----------------------------------------------------------------------------
// وضع الطبقات: أراضيي، سوق الآخرين، أو الاثنين معاً.
// -----------------------------------------------------------------------------
enum FarmerMapLayerMode {
  myLands,
  market,
  both,
}

class FarmerMapScreen extends StatefulWidget {
  const FarmerMapScreen({super.key});

  @override
  State<FarmerMapScreen> createState() => _FarmerMapScreenState();
}

class _FarmerMapScreenState extends State<FarmerMapScreen> {
  FarmerMapLayerMode _layerMode = FarmerMapLayerMode.myLands;
  LatLng? _userLatLng;
  bool _locationDenied = false;

  Set<Marker> _gParcelMarkers = {};
  Set<Marker> _gMarketMarkers = {};
  final Map<String, BitmapDescriptor> _gIconCache = {};

  static const LatLng _jordanCenter = LatLng(31.15, 36.0);
  static const double _zoomFarmer = 9.2;

  @override
  void initState() {
    super.initState();
    _initUserLocation();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoogleMarkers());
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
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
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

  double _haversineKm(LatLng a, LatLng b) {
    const earthKm = 6371.0;
    double rad(double d) => d * math.pi / 180.0;
    final dLat = rad(b.latitude - a.latitude);
    final dLng = rad(b.longitude - a.longitude);
    final lat1 = rad(a.latitude);
    final lat2 = rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthKm * c;
  }

  Color _maturityColor(FarmerLandMaturity m) => Color(maturityColorArgb(m));

  Future<BitmapDescriptor> _bitmapForCrop(String cropName, FarmerLandMaturity m) async {
    final cacheKey = '${resolveCropImageAsset(cropName)}_${m.index}';
    final cached = _gIconCache[cacheKey];
    if (cached != null) return cached;
    try {
      const double canvasSize = 52;
      const double imgD = 40;
      const double borderW = 3;
      final assetPath = resolveCropImageAsset(cropName);
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: imgD.toInt(),
        targetHeight: imgD.toInt(),
      );
      final fi = await codec.getNextFrame();
      final uiImage = fi.image;
      final col = _maturityColor(m);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final center = const Offset(canvasSize / 2, canvasSize / 2);
      final outerR = imgD / 2 + borderW / 2;

      final glow = Paint()
        ..color = col.withAlpha(90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, outerR + 2, glow);

      final border = Paint()
        ..color = col
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
      _gIconCache[cacheKey] = desc;
      return desc;
    } catch (_) {
      final fb = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _gIconCache[cacheKey] = fb;
      return fb;
    }
  }

  Future<void> _loadGoogleMarkers() async {
    final parcels = <Marker>{};
    final market = <Marker>{};

    for (final p in kMockFarmerParcels) {
      final pos = latLngFromParcel(p);
      final icon = await _bitmapForCrop(p.cropName, p.maturity);
      parcels.add(
        Marker(
          markerId: MarkerId('parcel_${p.id}'),
          position: pos,
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          onTap: () => _openParcelSheet(p),
        ),
      );
    }

    for (final o in kMockMarketForFarmer) {
      final pos = latLngFromOffer(o);
      final icon = await _bitmapForCrop(o.cropName, o.maturity);
      market.add(
        Marker(
          markerId: MarkerId('mkt_${o.id}'),
          position: pos,
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          onTap: () => _openMarketSheet(o),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _gParcelMarkers = parcels;
        _gMarketMarkers = market;
      });
    }
  }

  Set<Marker> get _activeGoogleMarkers {
    switch (_layerMode) {
      case FarmerMapLayerMode.myLands:
        return _gParcelMarkers;
      case FarmerMapLayerMode.market:
        return _gMarketMarkers;
      case FarmerMapLayerMode.both:
        return {..._gParcelMarkers, ..._gMarketMarkers};
    }
  }

  void _openParcelSheet(FarmerParcelMock p) {
    final season = seasonModelFromParcel(p);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _PinRingAvatar(
                        cropName: p.cropName,
                        maturity: p.maturity,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.landLabel,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _row('المحصول', p.cropName),
                  _row(
                    'تاريخ الزراعة',
                    '${p.plantingDate.year}-${p.plantingDate.month.toString().padLeft(2, '0')}-${p.plantingDate.day.toString().padLeft(2, '0')}',
                  ),
                  _row(
                    'الحصاد المتوقع',
                    '${p.expectedHarvestDate.year}-${p.expectedHarvestDate.month.toString().padLeft(2, '0')}-${p.expectedHarvestDate.day.toString().padLeft(2, '0')}',
                  ),
                  _row('المساحة', '${p.areaDunum.toStringAsFixed(0)} دونم'),
                  _row(
                    'الإنتاج المتوقع',
                    '${p.expectedProductionTons.toStringAsFixed(1)} طن',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        maturityLabelAr(p.maturity),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          color: _maturityColor(p.maturity),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PinRingAvatar(
                        cropName: p.cropName,
                        maturity: p.maturity,
                        size: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SeasonDetailScreen(season: season),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: const Text('تفاصيل الموسم', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AddSeasonScreen(),
                        ),
                      );
                    },
                    child: const Text('تعديل الموسم', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _openMarketSheet(FarmerMarketOfferMock o) {
    final user = _userLatLng;
    final pos = latLngFromOffer(o);
    final dist = user != null
        ? _haversineKm(user, pos)
        : 40.0 + (o.id.hashCode % 50).toDouble();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _PinRingAvatar(
                        cropName: o.cropName,
                        maturity: o.maturity,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              o.farmerName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              o.cropName,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _row('السعر', '${o.pricePerKgJd.toStringAsFixed(2)} دينار/كجم'),
                  _row('الكمية', '${o.quantityKg.toStringAsFixed(0)} كجم'),
                  _row('المسافة', '${dist.toStringAsFixed(0)} كم'),
                  if (_locationDenied || _userLatLng == null)
                    Text(
                      'تقدير المسافة — فعّل الموقع لدقة أعلى',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        maturityLabelAr(o.maturity),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _maturityColor(o.maturity),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PinRingAvatar(
                        cropName: o.cropName,
                        maturity: o.maturity,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // مزارع↔مزارع غير مدعوم في صندوق المحادثات — التواصل مع التجار والمصانع من تبويب المحادثات.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'محادثات المزارع هنا مع التجار والمصانع فقط. تصفّح عروضهم من تبويب المحادثات.',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('تواصل', style: TextStyle(fontFamily: 'Cairo')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
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

  bool get _showMy => _layerMode == FarmerMapLayerMode.myLands ||
      _layerMode == FarmerMapLayerMode.both;
  bool get _showMarket => _layerMode == FarmerMapLayerMode.market ||
      _layerMode == FarmerMapLayerMode.both;

  Widget _buildWebMap() {
    final markers = <fm.Marker>[];
    if (_showMy) {
      for (final p in kMockFarmerParcels) {
        markers.add(
          fm.Marker(
            point: lm.LatLng(p.latitude, p.longitude),
            width: 52,
            height: 52,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _openParcelSheet(p),
              child: _PinRingAvatar(
                cropName: p.cropName,
                maturity: p.maturity,
                size: 40,
              ),
            ),
          ),
        );
      }
    }
    if (_showMarket) {
      for (final o in kMockMarketForFarmer) {
        markers.add(
          fm.Marker(
            point: lm.LatLng(o.latitude, o.longitude),
            width: 52,
            height: 52,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _openMarketSheet(o),
              child: _PinRingAvatar(
                cropName: o.cropName,
                maturity: o.maturity,
                size: 40,
              ),
            ),
          ),
        );
      }
    }

    return fm.FlutterMap(
      options: fm.MapOptions(
        initialCenter: lm.LatLng(_jordanCenter.latitude, _jordanCenter.longitude),
        initialZoom: _zoomFarmer,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'hasad_app',
        ),
        fm.MarkerLayer(markers: markers),
        fm.SimpleAttributionWidget(
          alignment: Alignment.bottomLeft,
          source: const Text('OpenStreetMap', style: TextStyle(fontSize: 11)),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLayerChips() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip('أراضي', FarmerMapLayerMode.myLands),
            _chip('السوق', FarmerMapLayerMode.market),
            _chip('كلاهما', FarmerMapLayerMode.both),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, FarmerMapLayerMode mode) {
    final sel = _layerMode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
        selected: sel,
        selectedColor: AppColors.primaryGreen.withAlpha(200),
        onSelected: (_) => setState(() => _layerMode = mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: kIsWeb
                ? _buildWebMap()
                : GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _jordanCenter,
                      zoom: _zoomFarmer,
                    ),
                    markers: _activeGoogleMarkers,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: _userLatLng != null,
                  ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'خريطة المزرعة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'أراضيك، أو أسعار السوق من المزارعين الآخرين',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: _buildLayerChips(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AddSeasonScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('إضافة موسم', style: TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }
}

/// دبوس محصول مع إطار نضج (ويب والورقة السفلية).
class _PinRingAvatar extends StatelessWidget {
  final String cropName;
  final FarmerLandMaturity maturity;
  final double size;

  const _PinRingAvatar({
    required this.cropName,
    required this.maturity,
    this.size = 40,
  });

  Color get _ring {
    switch (maturity) {
      case FarmerLandMaturity.ripe:
        return const Color(0xFF4CAF50);
      case FarmerLandMaturity.halfRipe:
        return const Color(0xFFFFC107);
      case FarmerLandMaturity.unripe:
        return const Color(0xFF795548);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = resolveCropImageAsset(cropName);
    final ring = size > 36 ? 3.0 : 2.5;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _ring.withAlpha(100), blurRadius: 6),
        ],
      ),
      child: Container(
        width: size + ring * 2,
        height: size + ring * 2,
        padding: EdgeInsets.all(ring * 0.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _ring, width: ring),
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
