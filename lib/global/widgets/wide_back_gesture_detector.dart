import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WideBackGestureDetector extends StatefulWidget {
  final Widget child;
  final Widget? backChild;
  final bool enabled;

  const WideBackGestureDetector({
    super.key,
    required this.child,
    this.backChild,
    this.enabled = true,
  });

  @override
  State<WideBackGestureDetector> createState() => _WideBackGestureDetectorState();
}

class _WideBackGestureDetectorState extends State<WideBackGestureDetector> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    
    final width = MediaQuery.of(context).size.width;
    // Check if dragging from the left 25% of the screen
    if (details.globalPosition.dx < width * 0.25) {
      if (GoRouter.of(context).canPop()) {
        setState(() {
          _isDragging = true;
          _dragOffset = 0;
        });
      }
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    setState(() {
      _dragOffset += details.delta.dx;
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final width = MediaQuery.of(context).size.width;
    final velocity = details.primaryVelocity ?? 0;

    // Popping threshold: 30% width or high velocity
    if (_dragOffset > width * 0.3 || velocity > 700) {
      _controller.forward(from: _dragOffset / width).then((_) {
        if (mounted) {
          context.pop();
          _reset();
        }
      });
    } else {
      _controller.reverse(from: _dragOffset / width).then((_) {
        _reset();
      });
    }
  }

  void _reset() {
    if (mounted) {
      setState(() {
        _isDragging = false;
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Previous Page (Background) with Parallax
          if (_isDragging && widget.backChild != null)
            Transform.translate(
              // Move background page from -width/3 to 0 (Parallax)
              offset: Offset(-width / 3 + (_dragOffset / 3), 0),
              child: Stack(
                children: [
                  widget.backChild!,
                  // Darken overlay that fades out as we swipe
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(
                        (1.0 - (_dragOffset / width)).clamp(0.0, 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Current Page Shadow
          if (_isDragging)
            Positioned(
              left: _dragOffset - 15,
              top: 0,
              bottom: 0,
              child: Container(
                width: 15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Current Page
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
