import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/routes.dart';
import 'animated_bottom_nav.dart';
import 'wide_back_gesture_detector.dart';

class MainShellPage extends StatefulWidget {
  final Widget child;
  final String location;

  const MainShellPage({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  // We maintain a simple history to show the previous page behind during swipe
  final Map<String, Widget> _pageCache = {};
  String? _previousLocation;
  Widget? _previousWidget;

  @override
  void didUpdateWidget(MainShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      // Before changing, store the current as previous
      _previousLocation = oldWidget.location;
      _previousWidget = oldWidget.child;
      // Cache pages to recover them if needed
      _pageCache[oldWidget.location] = oldWidget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowNav = _shouldShowNav(widget.location);
    
    // Attempt to get background widget from cache if it exists
    final backWidget = _previousWidget ?? _pageCache[_previousLocation ?? ''];

    return Scaffold(
      body: WideBackGestureDetector(
        enabled: !shouldShowNav,
        backChild: backWidget != null ? RepaintBoundary(child: backWidget) : null,
        child: widget.child,
      ),
      bottomNavigationBar: shouldShowNav
          ? AnimatedBottomNav(
              currentIndex: _indexForLocation(widget.location),
              onTap: (index) => _onTabSelected(context, index),
            )
          : null,
    );
  }

  int _indexForLocation(String location) {
    if (location.startsWith(Routes.myPosts)) return 1;
    if (location.startsWith(Routes.chats)) return 2;
    if (location.startsWith(Routes.profile)) return 3;
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go(Routes.myPosts);
        return;
      case 2:
        context.go(Routes.chats);
        return;
      case 3:
        context.go(Routes.profile);
        return;
      case 0:
      default:
        context.go(Routes.home);
    }
  }

  bool _shouldShowNav(String location) {
    // Bottom nav should only be visible on top-level pages
    final topLevelRoutes = [
      Routes.home,
      Routes.myPosts,
      Routes.chats,
      Routes.profile,
    ];
    return topLevelRoutes.contains(location) || location == '/';
  }
}
