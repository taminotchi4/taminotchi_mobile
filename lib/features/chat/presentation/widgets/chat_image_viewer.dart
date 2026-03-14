import 'dart:io';
import 'package:flutter/material.dart';


import '../../../../core/utils/file_utils.dart';

class GalleryImageItem {
  final String path;
  final String tag;
  
  const GalleryImageItem({required this.path, required this.tag});
}

class ChatImageViewer extends StatefulWidget {
  final List<GalleryImageItem> items;
  final int initialIndex;

  const ChatImageViewer({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<ChatImageViewer> createState() => _ChatImageViewerState();
}

class _ChatImageViewerState extends State<ChatImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  double _verticalDragOffset = 0.0;
  double _scale = 1.0;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isZoomed) return;
    setState(() {
      _verticalDragOffset += details.delta.dy;
      _scale = (1 - (_verticalDragOffset.abs() / 1000)).clamp(0.5, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isZoomed) return;
    if (_verticalDragOffset.abs() > 100 || details.primaryVelocity!.abs() > 500) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _verticalDragOffset = 0.0;
        _scale = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = (1 - (_verticalDragOffset.abs() / 300)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(opacity),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            if (widget.items.length > 1)
              Text(
                "${_currentIndex + 1} / ${widget.items.length}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            Text(
              FileUtils.getFileSize(widget.items[_currentIndex].path),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _isZoomed ? null : _onVerticalDragUpdate,
        onVerticalDragEnd: _isZoomed ? null : _onVerticalDragEnd,
        child: Container(
          color: Colors.transparent,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _isZoomed = false;
              });
            },
            physics: _isZoomed || _verticalDragOffset.abs() > 0
                ? const NeverScrollableScrollPhysics() 
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Transform.translate(
                offset: Offset(0, _verticalDragOffset),
                child: Transform.scale(
                  scale: _scale,
                  child: _ZoomableImageItem(
                    path: item.path,
                    tag: item.tag,
                    onZoomChanged: (isZoomed) {
                      if (_isZoomed != isZoomed) {
                         setState(() {
                           _isZoomed = isZoomed;
                         });
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ZoomableImageItem extends StatefulWidget {
  final String path;
  final String tag;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImageItem({
    required this.path,
    required this.tag,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableImageItem> createState() => _ZoomableImageItemState();
}

class _ZoomableImageItemState extends State<_ZoomableImageItem> with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformationChange);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _onTransformationChange() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.01);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformationChange);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    Matrix4 current = _controller.value;
    double scale = current.getMaxScaleOnAxis();

    Matrix4 target;
    if (scale > 1.05) {
      target = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      const double targetScale = 3.0;
      final x = position.dx * (1 - targetScale);
      final y = position.dy * (1 - targetScale);
      
      target = Matrix4.identity()
        ..translate(x, y, 0.0)
        ..scale(targetScale, targetScale, targetScale);
    }
    
    _animation = Matrix4Tween(begin: current, end: target).animate(
      CurveTween(curve: Curves.easeInOut).animate(_animationController),
    );
    _animation!.addListener(() {
      _controller.value = _animation!.value;
    });
    
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: Hero(
        tag: widget.tag,
        child: InteractiveViewer(
          transformationController: _controller,
          maxScale: 4.0,
          minScale: 1.0,
          clipBehavior: Clip.none,
          child: Image.file(
            File(widget.path),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
