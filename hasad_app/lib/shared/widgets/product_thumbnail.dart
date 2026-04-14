import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hasad_app/core/app_colors.dart';
import 'package:hasad_app/core/models/product_model.dart';
import 'package:hasad_app/shared/helpers/crop_image_assets.dart';

/// صورة المنتج (افتراضي 72×72): [ProductModel.imageUrl] عبر الشبكة وإلا أصول `assets/images/`.
class ProductThumbnail extends StatelessWidget {
  final ProductModel product;
  final double size;

  const ProductThumbnail({
    super.key,
    required this.product,
    this.size = 72,
  });

  Widget _fallback() {
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

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl?.trim();
    final radius = BorderRadius.circular(size * 0.2);

    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            memCacheWidth:
                (size * MediaQuery.of(context).devicePixelRatio).round(),
            memCacheHeight:
                (size * MediaQuery.of(context).devicePixelRatio).round(),
            placeholder: (_, __) => ColoredBox(
              color: Colors.grey.shade100,
              child: Center(
                child: SizedBox(
                  width: size * 0.28,
                  height: size * 0.28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => _buildAssetImage(
              context,
              resolveCropImageAsset(product.cropType),
              radius,
            ),
          ),
        ),
      );
    }

    return _buildAssetImage(
      context,
      resolveCropImageAsset(product.cropType),
      radius,
    );
  }

  Widget _buildAssetImage(
    BuildContext context,
    String assetPath,
    BorderRadius radius,
  ) {
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          cacheWidth:
              (size * MediaQuery.of(context).devicePixelRatio).round(),
          cacheHeight:
              (size * MediaQuery.of(context).devicePixelRatio).round(),
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/crop_default.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        ),
      ),
    );
  }
}
