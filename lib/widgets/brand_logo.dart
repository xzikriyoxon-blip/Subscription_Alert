import 'package:flutter/material.dart';

import '../services/brand_icon_registry.dart';

class BrandLogo extends StatelessWidget {
  final String? brandId;
  final String? brandName;
  final String? iconUrl;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;

  const BrandLogo({
    super.key,
    this.brandId,
    this.brandName,
    this.iconUrl,
    required this.size,
    this.borderRadius = 12,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final spec = BrandIconRegistry.forBrand(brandId: brandId, brandName: brandName);

    final bg = backgroundColor ?? (spec?.color.withValues(alpha: 0.10) ?? Colors.grey.withValues(alpha: 0.10));

    Widget child;
    if (spec != null) {
      child = Icon(spec.icon, color: spec.color, size: size * 0.55);
    } else if (iconUrl != null && iconUrl!.trim().isNotEmpty) {
      child = Image.network(
        iconUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackLetter(context),
      );
    } else {
      child = _fallbackLetter(context);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }

  Widget _fallbackLetter(BuildContext context) {
    final letter = (brandName?.trim().isNotEmpty ?? false)
        ? brandName!.trim()[0].toUpperCase()
        : ((brandId?.trim().isNotEmpty ?? false) ? brandId!.trim()[0].toUpperCase() : '?');

    return Text(
      letter,
      style: TextStyle(
        fontSize: size * 0.40,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
