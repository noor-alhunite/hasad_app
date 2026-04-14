import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/models/product_model.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/chat_inbox_provider.dart';
import '../../core/providers/user_provider.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/chat_models.dart';
import '../../shared/helpers/crop_image_assets.dart';

/// ربط اسم المحصول بمسار صورة محلية (`tomato.png`, `cucumber.png`, …).
String marketplaceProductImageAsset(String cropName) {
  return resolveCropImageAsset(cropName);
}

class MarketplaceScreen extends StatelessWidget {
  final bool isGuestMode;
  final VoidCallback? onGuestExit;

  const MarketplaceScreen({
    super.key,
    this.isGuestMode = false,
    this.onGuestExit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final productProvider = context.watch<ProductProvider>();
    final filters = productProvider.availableFilters;
    final isGuest =
        isGuestMode || (context.watch<UserProvider>().currentUser?.isGuest ?? false);

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
                  if (isGuestMode) ...[
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: onGuestExit,
                          tooltip: 'خروج',
                        ),
                        const Expanded(
                          child: Text(
                            'وضع الزائر — تصفح السوق فقط',
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
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      textAlign: TextAlign.right,
                      onChanged: productProvider.setSearchQuery,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: l10n.searchProduct,
                        hintStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Filter Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = productProvider.selectedFilter == filter;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => productProvider.setFilter(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.lightGrey,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Products Count + Sort/Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sort,
                            color: AppColors.grey, size: 20),
                        onPressed: () => _showSortSheet(context, productProvider, l10n),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.sort,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.filter_list,
                            color: AppColors.grey, size: 20),
                        onPressed: () =>
                            _showFilterDialog(context, productProvider, l10n),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.filter,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${productProvider.filteredProducts.length} ${l10n.no_products.contains('No') ? 'products' : 'منتج'}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Products List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final products = productProvider.filteredProducts;
                if (products.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        l10n.no_products,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                final p = products[index];
                return _DirectMarketProductCard(
                  product: p,
                  onContact: isGuest
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'سجّل الدخول عبر سند للتواصل مع المزارعين',
                              ),
                            ),
                          );
                        }
                      : () => _showContactDialog(context, p, l10n),
                  onMakeOffer: isGuest
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'سجّل الدخول عبر سند لإرسال العروض',
                              ),
                            ),
                          );
                        }
                      : () => _showOfferDialog(context, p, l10n),
                );
              },
              childCount: productProvider.filteredProducts.isEmpty
                  ? 1
                  : productProvider.filteredProducts.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _showSortSheet(
    BuildContext context,
    ProductProvider productProvider,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.sort,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                title: const Text('السعر: من الأقل', textAlign: TextAlign.right),
                onTap: () {
                  productProvider.setSortOrder(ProductSortOrder.priceAsc);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('السعر: من الأعلى', textAlign: TextAlign.right),
                onTap: () {
                  productProvider.setSortOrder(ProductSortOrder.priceDesc);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('الأقرب مسافة', textAlign: TextAlign.right),
                onTap: () {
                  productProvider.setSortOrder(ProductSortOrder.distanceAsc);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('إلغاء الترتيب', textAlign: TextAlign.right),
                onTap: () {
                  productProvider.setSortOrder(ProductSortOrder.none);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog(
    BuildContext context,
    ProductProvider productProvider,
    AppLocalizations l10n,
  ) {
    String? region = productProvider.regionFilter;
    String? quality = productProvider.qualityFilter;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setSt) {
            return AlertDialog(
              title: Text(l10n.filter, textAlign: TextAlign.right),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('المنطقة', textAlign: TextAlign.right),
                  DropdownButtonFormField<String?>(
                    value: region,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('الكل', textAlign: TextAlign.right),
                      ),
                      ...productProvider.availableRegions.map(
                        (r) => DropdownMenuItem<String?>(
                          value: r,
                          child: Text(r, textAlign: TextAlign.right),
                        ),
                      ),
                    ],
                    onChanged: (v) => setSt(() => region = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('الجودة', textAlign: TextAlign.right),
                  DropdownButtonFormField<String?>(
                    value: quality,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('الكل', textAlign: TextAlign.right),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'premium',
                        child: Text('ممتاز', textAlign: TextAlign.right),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'high',
                        child: Text('عالي', textAlign: TextAlign.right),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'medium',
                        child: Text('متوسط', textAlign: TextAlign.right),
                      ),
                    ],
                    onChanged: (v) => setSt(() => quality = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    productProvider.clearAdvancedFilters();
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('مسح'),
                ),
                FilledButton(
                  onPressed: () {
                    productProvider.setRegionFilter(region);
                    productProvider.setQualityFilter(quality);
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('تطبيق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOfferDialog(
    BuildContext context,
    ProductModel product,
    AppLocalizations l10n,
  ) {
    final qty = TextEditingController(text: '100');
    final price = TextEditingController(
        text: product.price.toStringAsFixed(1),
    );
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('${l10n.send_offer} — ${product.cropType}',
              textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'الكمية'),
              ),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'السعر المقترح'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال عرض: ${qty.text} ${product.unit} بسعر ${price.text}',
                    ),
                  ),
                );
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(
    BuildContext context,
    ProductModel product,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${l10n.contact} ${product.farmerName}',
          textAlign: TextAlign.right,
          style:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContactOption(
              icon: Icons.chat_bubble_outline,
              label: l10n.conversations,
              onTap: () {
                Navigator.pop(dialogCtx);
                final u = context.read<UserProvider>().currentUser;
                if (u == null) return;
                // المزارع لا يفتح محادثة مع مزارع آخر — القائمة مخصصة للتجار والمصانع معهم فقط.
                if (u.role == UserRole.farmer) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'محادثات المزارع في التطبيق مع التجار والمصانع فقط.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  );
                  return;
                }
                final threadId = context.read<ChatInboxProvider>().openOrCreateThread(
                      peerName: product.farmerName,
                      topicSubtitle: product.cropType,
                      avatarAssetPath: resolveCropImageAsset(product.cropType),
                      viewerRole: u.role,
                      peerKind: ChatPeerKind.farmer,
                    );
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChatDetailScreen(threadId: threadId),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _ContactOption(
              icon: Icons.phone,
              label: l10n.contact,
              onTap: () {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الاتصال غير مفعّل في النسخة التجريبية')),
                );
              },
            ),
            const SizedBox(height: 8),
            _ContactOption(
              icon: Icons.local_offer,
              label: l10n.send_offer,
              onTap: () {
                Navigator.pop(dialogCtx);
                _showOfferDialog(context, product, l10n);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.cancel,
              style:
                  const TextStyle(fontFamily: 'Cairo', color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

/// صورة المنتج للسوق: شبكة إن وُجد [ProductModel.imageUrl]، وإلا أصول + احتياطي.
class _MarketplaceProductImage extends StatelessWidget {
  final ProductModel product;
  final double size;

  const _MarketplaceProductImage({
    required this.product,
    this.size = 80,
  });

  Widget _placeholder() {
    return Image.asset(
      'assets/images/crop_default.png',
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.agriculture_outlined,
          color: Colors.grey.shade600,
          size: size * 0.45,
        ),
      ),
    );
  }

  Widget _assetLayer(String path, BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/crop_default.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.2);
    final url = product.imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) =>
                _assetLayer(marketplaceProductImageAsset(product.cropType), radius),
          ),
        ),
      );
    }
    return _assetLayer(marketplaceProductImageAsset(product.cropType), radius);
  }
}

class _DirectMarketProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onContact;
  final VoidCallback? onMakeOffer;

  const _DirectMarketProductCard({
    required this.product,
    this.onContact,
    this.onMakeOffer,
  });

  Color get _qualityColor {
    switch (product.quality) {
      case 'premium':
        return AppColors.primaryGreen;
      case 'high':
        return AppColors.secondaryGreen;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.06).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _MarketplaceProductImage(product: product, size: 80),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _qualityColor.withAlpha((255 * 0.1).round()),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.qualityDisplayName,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: _qualityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        product.cropType,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        product.farmerName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            '${product.distanceKm.toStringAsFixed(0)} كم',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.location_on,
                              size: 12, color: AppColors.grey),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            product.farmerRating.toString(),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'الكمية: ${product.quantity.toStringAsFixed(0)} ${product.unit}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (onMakeOffer != null)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onMakeOffer,
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_offer,
                                        size: 14,
                                        color: AppColors.primaryGreen),
                                    SizedBox(width: 4),
                                    Text(
                                      'عرض',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onContact,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'تواصل',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${product.price} ${product.priceUnit}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
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

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: AppColors.primaryGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
