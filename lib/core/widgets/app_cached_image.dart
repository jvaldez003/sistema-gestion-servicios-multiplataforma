import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData errorIcon;

  static final Map<String, Uint8List> _decodedCache = {};
  static const int _maxCacheEntries = 40;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.broken_image_outlined,
  });

  static Uint8List? _decodeBase64(String imageUrl) {
    final cached = _decodedCache[imageUrl];
    if (cached != null) return cached;

    try {
      String base64Content = imageUrl;
      if (base64Content.contains(',')) {
        base64Content = base64Content.split(',').last;
      }
      final bytes = base64Decode(base64Content);
      if (_decodedCache.length >= _maxCacheEntries) {
        _decodedCache.remove(_decodedCache.keys.first);
      }
      _decodedCache[imageUrl] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    final url = imageUrl!;
    final bool isBase64 = url.startsWith('data:image') ||
        (!url.startsWith('http') && url.length > 100);

    Widget imageWidget;

    if (isBase64) {
      final bytes = _decodeBase64(url);
      imageWidget = bytes == null
          ? _buildError()
          : Image.memory(
              bytes,
              key: ValueKey(url),
              width: width,
              height: height,
              fit: fit,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => _buildError(),
            );
    } else {
      imageWidget = CachedNetworkImage(
        key: ValueKey(url),
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        cacheKey: url,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        useOldImageOnUrlChange: true,
        placeholder: (context, url) => _buildLoading(),
        errorWidget: (context, url, error) => _buildError(),
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return RepaintBoundary(child: imageWidget);
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF1F5F9),
            const Color(0xFFE2E8F0),
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textSecondary.withValues(alpha: 0.4),
          size: (height ?? 100) * 0.3,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          errorIcon,
          color: AppColors.error.withValues(alpha: 0.5),
          size: (height ?? 100) * 0.3,
        ),
      ),
    );
  }
}
