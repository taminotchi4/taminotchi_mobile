import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/usecases/check_phone_usecase.dart';
import '../../domain/usecases/request_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/complete_register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';
import '../widgets/phone_input_step.dart';
import '../widgets/login_step.dart';
import '../widgets/otp_verification_step.dart';
import '../widgets/registration_step.dart';

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
      case AuthStep.login:
        page = 1;
        break;
      case AuthStep.otpVerification:
        page = 2;
        break;
      case AuthStep.registration:
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
      create: (context) => AuthBloc(
        checkPhoneUseCase: context.read<CheckPhoneUseCase>(),
        requestOtpUseCase: context.read<RequestOtpUseCase>(),
        verifyOtpUseCase: context.read<VerifyOtpUseCase>(),
        completeRegisterUseCase: context.read<CompleteRegisterUseCase>(),
        loginUseCase: context.read<LoginUseCase>(),
      ),
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
                LoginStep(),
                OtpVerificationStep(),
                RegistrationStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
