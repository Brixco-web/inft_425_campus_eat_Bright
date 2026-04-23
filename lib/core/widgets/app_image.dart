import 'dart:convert';
import 'package:flutter/material.dart';

/// A robust image widget that handles both asset paths and network URLs.
class AppImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? placeholderColor;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildPlaceholder();
    }

    final isAsset = url!.startsWith('assets/');
    final isBase64 = url!.startsWith('data:image');

    Widget image;
    if (isAsset) {
      image = Image.asset(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (isBase64) {
      try {
        final base64Content = url!.split(',').last;
        image = Image.memory(
          base64Decode(base64Content),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        image = _buildPlaceholder();
      }
    } else {
      image = Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading();
        },
      );
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? Colors.white.withValues(alpha: 0.05),
      child: const Center(
        child: Icon(Icons.restaurant_rounded, color: Colors.white10),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? Colors.white.withValues(alpha: 0.05),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white10),
          ),
        ),
      ),
    );
  }
}
