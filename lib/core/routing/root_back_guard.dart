import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class RootBackGuard extends StatefulWidget {
  final Widget child;
  const RootBackGuard({super.key, required this.child});

  @override
  State<RootBackGuard> createState() => _RootBackGuardState();
}

class _RootBackGuardState extends State<RootBackGuard> {
  DateTime? _lastBackTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 🔒 global exit block
      onPopInvokedWithResult: (didPop, result) {
        final now = DateTime.now();

        if (_lastBackTime == null ||
            now.difference(_lastBackTime!) > const Duration(seconds: 2)) {
          _lastBackTime = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chiqish uchun yana bosing')),
          );
        } else {
          SystemNavigator.pop(); // real exit
        }
      },
      child: widget.child,
    );
  }
}
