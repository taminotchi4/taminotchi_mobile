import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/routes.dart';
import 'animated_bottom_nav.dart';

class MainShellPage extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShellPage({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowNav = _shouldShowNav(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: shouldShowNav
          ? AnimatedBottomNav(
              currentIndex: _indexForLocation(location),
              onTap: (index) => _onTabSelected(context, index),
            )
          : null,
    );
  }

  int _indexForLocation(String location) {
    if (location.startsWith(Routes.myPosts)) return 1;
    if (location.startsWith(Routes.orders)) return 2;
    if (location.startsWith(Routes.profile)) return 3;
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go(Routes.myPosts);
        return;
      case 2:
        context.go(Routes.orders);
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
    if (location.startsWith('/post')) return false;
    if (location.startsWith('/products/') && location != Routes.allProducts) {
      return false;
    }
    if (location.startsWith('/seller')) return false;
    return true;
  }
}
