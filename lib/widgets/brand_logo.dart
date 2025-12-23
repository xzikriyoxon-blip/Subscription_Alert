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
      final candidates = _buildCandidateLogoUrls(iconUrl!, pixelSize: (size * 2).round());
      child = _MultiSourceNetworkImage(
        urls: candidates,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fallback: _fallbackLetter(context),
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

  List<String> _buildCandidateLogoUrls(String rawUrl, {required int pixelSize}) {
    final urls = <String>[];

    final trimmed = rawUrl.trim();
    Uri? uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      uri = null;
    }

    // 1) Original URL (Clearbit for most brands in this app).
    if (trimmed.isNotEmpty) {
      urls.add(trimmed);
    }

    // 2) If it's Clearbit, also try with explicit size.
    if (uri != null && uri.scheme.startsWith('http') && uri.host.toLowerCase() == 'logo.clearbit.com') {
      final withSize = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'size': pixelSize.toString(),
      });
      urls.add(withSize.toString());
    }

    // 3) Derive the brand domain and try common favicon endpoints.
    final domain = _extractBrandDomain(uri);
    if (domain != null && domain.isNotEmpty) {
      // Google S2 favicon service.
      urls.add('https://www.google.com/s2/favicons?domain=$domain&sz=$pixelSize');

      // DuckDuckGo favicon proxy.
      urls.add('https://icons.duckduckgo.com/ip3/$domain.ico');
    }

    // Unique while preserving order.
    final seen = <String>{};
    final unique = <String>[];
    for (final u in urls) {
      final key = u.trim();
      if (key.isEmpty) continue;
      if (seen.add(key)) unique.add(key);
    }
    return unique;
  }

  String? _extractBrandDomain(Uri? uri) {
    if (uri == null) return null;

    // Our icon urls are typically: https://logo.clearbit.com/<domain>
    if (uri.host.toLowerCase() == 'logo.clearbit.com') {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
      return null;
    }

    // Otherwise, attempt to use host.
    final host = uri.host;
    if (host.isEmpty) return null;
    return host;
  }
}

class _MultiSourceNetworkImage extends StatefulWidget {
  final List<String> urls;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget fallback;

  const _MultiSourceNetworkImage({
    required this.urls,
    required this.width,
    required this.height,
    required this.fit,
    required this.fallback,
  });

  @override
  State<_MultiSourceNetworkImage> createState() => _MultiSourceNetworkImageState();
}

class _MultiSourceNetworkImageState extends State<_MultiSourceNetworkImage> {
  int _index = 0;

  void _next() {
    if (!mounted) return;
    setState(() {
      _index += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty || _index >= widget.urls.length) {
      return widget.fallback;
    }

    final url = widget.urls[_index];

    return Image.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        // Try the next URL.
        WidgetsBinding.instance.addPostFrameCallback((_) => _next());
        return widget.fallback;
      },
    );
  }
}
