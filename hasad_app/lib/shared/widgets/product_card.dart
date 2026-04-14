import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import 'product_thumbnail.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onContact;
  final VoidCallback? onMakeOffer;

  const ProductCard({
    super.key,
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
            ProductThumbnail(product: product, size: 80),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _qualityColor.withAlpha((255 * 0.1).round()),
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
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.primaryGreen),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_offer,
                                        size: 14, color: AppColors.primaryGreen),
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
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 14, color: AppColors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'تواصل',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Price
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
