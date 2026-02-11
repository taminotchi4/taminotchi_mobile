import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/routes.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';
import '../widgets/phone_input_step.dart';
import '../widgets/otp_verification_step.dart';
import '../widgets/password_creation_step.dart';
import '../widgets/profile_setup_step.dart';

class AuthMainPage extends StatefulWidget {
  const AuthMainPage({super.key});

  @override
  State<AuthMainPage> createState() => _AuthMainPageState();
}

class _AuthMainPageState extends State<AuthMainPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(AuthStep step) {
    int page = 0;
    switch (step) {
      case AuthStep.phoneInput:
        page = 0;
        break;
      case AuthStep.otpVerification:
        page = 1;
        break;
      case AuthStep.passwordCreation:
        page = 2;
        break;
      case AuthStep.profileSetup:
        page = 3;
        break;
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.step != current.step || previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            context.go(Routes.home);
          }
          _onStepChanged(state.step);
        },
        child: Scaffold(
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                PhoneInputStep(),
                OtpVerificationStep(),
                PasswordCreationStep(),
                ProfileSetupStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
