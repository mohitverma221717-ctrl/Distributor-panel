import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';

class DemandProductRow extends StatelessWidget {
  final DemandProduct product;
  final VoidCallback onTap;

  const DemandProductRow({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.68),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular product image container matching reference
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: product.imageAsset != null
                      ? Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            product.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.primaryOrange,
                              size: 22,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primaryOrange,
                          size: 22,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Product Name
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // Demand Count & Chevron
              Text(
                '${product.totalDemand}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
