import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

class CachedImage extends ConsumerWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  String _getFullUrl(String baseUrl) {
    if (imageUrl.startsWith('http')) return imageUrl;
    // Remove /api/v1 from the end if it exists to get the root URL
    final base = baseUrl.endsWith('/api/v1') 
        ? baseUrl.substring(0, baseUrl.length - 7) 
        : baseUrl.replaceAll('/api/v1', '');
    
    if (imageUrl.startsWith('/')) return '$base$imageUrl';
    return '$base/$imageUrl';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dioClient = ref.watch(dioClientProvider);
    final baseUrl = dioClient.dio.options.baseUrl;
    final fullUrl = _getFullUrl(baseUrl);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark
        ? const Color(0xFF2D3748)
        : Colors.grey[200];
    final errorColor = isDark ? const Color(0xFF2D3748) : Colors.grey[200];

    final image = CachedNetworkImage(
      imageUrl: fullUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: placeholderColor,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? Colors.white54 : null,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: errorColor,
        child: Icon(
          Icons.image_not_supported,
          color: isDark ? Colors.white38 : Colors.grey,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
