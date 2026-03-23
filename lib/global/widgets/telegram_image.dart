import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/image_cache_service.dart';

class TelegramImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const TelegramImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  State<TelegramImage> createState() => _TelegramImageState();
}

class _TelegramImageState extends State<TelegramImage> {
  final ImageCacheService _cacheService = ImageCacheService();
  String? _localPath;
  bool _isDownloading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  Future<void> _checkCache() async {
    final path = await _cacheService.getLocalPath(widget.imageUrl);
    if (mounted) {
      setState(() {
        _localPath = path;
        _isInitialized = true;
      });
    }
  }

  Future<void> _download() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);
    final path = await _cacheService.downloadAndCache(widget.imageUrl);
    if (mounted) {
      setState(() {
        _localPath = path;
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    Widget content;

    if (_localPath != null && File(_localPath!).existsSync()) {
      // Show full image from file
      content = Image.file(
        File(_localPath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    } else {
      // Show blurred placeholder with download icon
      content = Stack(
        alignment: Alignment.center,
        children: [
          // Blurred Background
          Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: child,
                );
              }
              return Container(color: Colors.grey[300]);
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
          
          // Download Button
          GestureDetector(
            onTap: _download,
            child: Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: _isDownloading
                  ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 28.r,
                    ),
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
      child: content,
    );
  }
}
