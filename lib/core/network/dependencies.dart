import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_phone_usecase.dart';
import '../../features/auth/domain/usecases/request_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/complete_register_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import 'auth_interceptor.dart';
import 'client.dart';

final dependencies = <SingleChildWidget>[
  RepositoryProvider(create: (context) => const FlutterSecureStorage()),
  RepositoryProvider(create: (context) => AuthInterceptor(secureStorage: context.read())),
  RepositoryProvider(create: (context) => ApiClient(interceptor: context.read())),
  
  // Auth dependencies
  RepositoryProvider(
    create: (context) => AuthRemoteDataSource(
      client: context.read<ApiClient>(),
    ),
  ),
  RepositoryProvider<AuthRepository>(
    create: (context) => AuthRepositoryImpl(
      remoteDataSource: context.read<AuthRemoteDataSource>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => CheckPhoneUseCase(context.read<AuthRepository>()),
  ),
  RepositoryProvider(
    create: (context) => RequestOtpUseCase(context.read<AuthRepository>()),
  ),
  RepositoryProvider(
    create: (context) => VerifyOtpUseCase(context.read<AuthRepository>()),
  ),
  RepositoryProvider(
    create: (context) => CompleteRegisterUseCase(context.read<AuthRepository>()),
  ),
  RepositoryProvider(
    create: (context) => LoginUseCase(context.read<AuthRepository>()),
  ),
];
final blocDependencies = <SingleChildWidget>[
  // BlocProvider(create: (context) => CategoryBloc(getCategoriesUseCase: context.read())),
];
