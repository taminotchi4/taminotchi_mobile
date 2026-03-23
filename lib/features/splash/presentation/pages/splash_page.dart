import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/styles.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/domain/repositories/client_profile_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for branding and ensuring dependencies are ready
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authRepo = context.read<AuthRepository>();
    final profileRepo = context.read<ClientProfileRepository>();

    try {
      final token = await authRepo.getToken();

      if (token == null || token.isEmpty) {
        if (mounted) context.go(Routes.auth);
        return;
      }

      // Verify token by trying to fetch the profile
      // This will also trigger the AuthInterceptor if the token needs refresh
      await profileRepo.getProfile();
      
      if (mounted) context.go(Routes.home);
    } catch (e) {
      // If profile fetch fails (e.g., 401 Unauthorized after internal refresh attempt fails)
      if (mounted) context.go(Routes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation/Logo Hero region
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(
                    'assets/icons/app_icon.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Text branding
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Padding(
                    padding: EdgeInsets.only(top: (1 - value) * 20),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    'Taminotchi',
                    style: AppStyles.h1Bold.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sizning ishonchli hamkoringiz',
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            // Minimalist loading indicator
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
