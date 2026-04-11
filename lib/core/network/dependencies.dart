import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_phone_usecase.dart';
import '../../features/auth/domain/usecases/request_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/complete_register_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/check_username_usecase.dart';
import 'auth_interceptor.dart';
import 'client.dart';
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/datasources/category_remote_data_source.dart';
import '../../features/home/data/datasources/elon_remote_datasource.dart';
import '../../features/home/data/datasources/home_sql_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_all_posts_usecase.dart';
import '../../features/home/domain/usecases/get_my_posts_usecase.dart';
import '../../features/home/domain/usecases/create_post_usecase.dart';
import '../../features/home/domain/usecases/get_post_by_id_usecase.dart';
import '../../features/home/domain/usecases/get_comments_usecase.dart';
import '../../features/home/domain/usecases/get_comment_counts_usecase.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_current_user_id_usecase.dart';
import '../../features/home/domain/usecases/get_current_user_role_usecase.dart';
import '../../features/home/domain/usecases/reply_to_comment_usecase.dart';
import '../../features/home/domain/usecases/update_post_status_usecase.dart';
import '../../features/home/domain/usecases/get_posts_by_category_usecase.dart';
import '../../features/home/domain/usecases/get_groups_by_category_usecase.dart';
import '../../features/home/domain/usecases/get_posts_by_group_usecase.dart';
import '../../features/profile/data/datasources/client_profile_local_data_source.dart';
import '../../features/profile/data/datasources/client_profile_remote_data_source.dart';
import '../../features/profile/data/repositories/client_profile_repository_impl.dart';
import '../../features/profile/domain/repositories/client_profile_repository.dart';
import '../../features/profile/domain/usecases/get_client_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_client_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_profile_photo_usecase.dart';
import '../../features/profile/domain/usecases/logout_usecase.dart' as profile_logout;
import '../../features/profile/domain/usecases/delete_account_usecase.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/datasources/group_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/data/datasources/chat_local_data_source.dart';
import '../../features/chat/data/services/audio_player_service.dart';
import '../../features/chat/data/services/audio_recorder_service.dart';
import '../../features/chat/data/services/chat_media_service.dart';
import '../../features/chat/presentation/managers/notification_proxy_bloc.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/datasources/product_comments_remote_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/data/repositories/product_comments_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/domain/repositories/product_comments_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/get_product_by_id_usecase.dart';
import '../../features/products/domain/usecases/get_product_categories_usecase.dart';
import '../../features/products/domain/usecases/get_product_comments_usecase.dart';
import '../../features/products/domain/usecases/add_product_comment_usecase.dart';
import '../../features/products/domain/usecases/update_product_comment_usecase.dart';
import '../../features/products/domain/usecases/delete_product_comment_usecase.dart';
import '../../features/products/data/datasources/product_comments_local_data_source.dart';

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
  RepositoryProvider<AuthLocalDataSource>(
    create: (context) => AuthLocalDataSourceImpl(
      secureStorage: context.read<FlutterSecureStorage>(),
    ),
  ),
  RepositoryProvider<AuthRepository>(
    create: (context) => AuthRepositoryImpl(
      remoteDataSource: context.read<AuthRemoteDataSource>(),
      localDataSource: context.read<AuthLocalDataSource>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => CheckPhoneUseCase(context.read<AuthRepository>()),
  ),
  RepositoryProvider(
    create: (context) => CheckUsernameUseCase(context.read<AuthRepository>()),
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

  // Home dependencies
  RepositoryProvider(
    create: (context) => HomeLocalDataSource(prefs: context.read<SharedPreferences>()),
  ),
  RepositoryProvider(
    create: (context) => HomeSqlDataSource(),
  ),
  RepositoryProvider<CategoryRemoteDataSource>(
    create: (context) => CategoryRemoteDataSourceImpl(client: context.read<ApiClient>()),
  ),
  RepositoryProvider<ElonRemoteDataSource>(
    create: (context) => ElonRemoteDataSourceImpl(client: context.read<ApiClient>()),
  ),
  RepositoryProvider<HomeRepository>(
    create: (context) => HomeRepositoryImpl(
      localDataSource: context.read<HomeLocalDataSource>(),
      sqlDataSource: context.read<HomeSqlDataSource>(),
      categoryRemoteDataSource: context.read<CategoryRemoteDataSource>(),
      authLocalDataSource: context.read<AuthLocalDataSource>(),
      elonRemoteDataSource: context.read<ElonRemoteDataSource>(),
    ),
  ),
  RepositoryProvider(create: (context) => GetAllPostsUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetMyPostsUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => CreatePostUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetPostByIdUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetCommentsUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetCommentCountsUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetCategoriesUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetCurrentUserIdUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetCurrentUserRoleUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => ReplyToCommentUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => UpdatePostStatusUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetPostsByCategoryUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetGroupsByCategoryUseCase(context.read<HomeRepository>())),
  RepositoryProvider(create: (context) => GetPostsByGroupUseCase(context.read<HomeRepository>())),

  // Profile dependencies
  RepositoryProvider(create: (context) => ClientProfileLocalDataSource()),
  RepositoryProvider<ClientProfileRemoteDataSource>(
    create: (context) => ClientProfileRemoteDataSourceImpl(client: context.read<ApiClient>()),
  ),
  RepositoryProvider<ClientProfileRepository>(
    create: (context) => ClientProfileRepositoryImpl(
      localDataSource: context.read<ClientProfileLocalDataSource>(),
      remoteDataSource: context.read<ClientProfileRemoteDataSource>(),
    ),
  ),
  RepositoryProvider(create: (context) => GetClientProfileUseCase(context.read<ClientProfileRepository>())),
  RepositoryProvider(create: (context) => UpdateClientProfileUseCase(context.read<ClientProfileRepository>())),
  RepositoryProvider(create: (context) => UploadProfilePhotoUseCase(context.read<ClientProfileRepository>())),
  RepositoryProvider(create: (context) => profile_logout.LogoutUseCase(context.read<ClientProfileRepository>())),
  RepositoryProvider(create: (context) => DeleteAccountUseCase(context.read<ClientProfileRepository>())),

  // Chat dependencies
  RepositoryProvider<ChatRemoteDataSource>(
    create: (context) => ChatRemoteDataSourceImpl(client: context.read<ApiClient>()),
  ),
  RepositoryProvider<GroupRemoteDataSource>(
    create: (context) => GroupRemoteDataSourceImpl(client: context.read<ApiClient>()),
  ),
  RepositoryProvider<ChatLocalDataSource>(
    create: (context) => ChatLocalDataSourceImpl(),
  ),
  RepositoryProvider(create: (context) => ChatMediaService()),
  RepositoryProvider<ChatRepository>(
    create: (context) => ChatRepositoryImpl(
      chatRemoteDataSource: context.read<ChatRemoteDataSource>(),
      groupRemoteDataSource: context.read<GroupRemoteDataSource>(),
      localDataSource: context.read<ChatLocalDataSource>(),
      mediaService: context.read<ChatMediaService>(),
    ),
  ),
  RepositoryProvider(create: (context) => AudioPlayerService()),
  RepositoryProvider(create: (context) => AudioRecorderService()),
  RepositoryProvider<NotificationRepositoryImpl>(
    create: (context) => NotificationRepositoryImpl(client: context.read<ApiClient>()),
  ),
  BlocProvider<NotificationProxyBloc>(
    create: (context) => NotificationProxyBloc(
      repository: context.read<NotificationRepositoryImpl>(),
      authRepository: context.read<AuthRepository>(),
    ),
    lazy: false,
  ),

  // Products dependencies
  RepositoryProvider<ProductsRemoteDataSource>(
    create: (context) => ProductsRemoteDataSourceImpl(client: context.read<ApiClient>()),
  ),
  RepositoryProvider<ProductsRepository>(
    create: (context) => ProductsRepositoryImpl(
      remoteDataSource: context.read<ProductsRemoteDataSource>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => GetProductsUseCase(context.read<ProductsRepository>()),
  ),
  RepositoryProvider(
    create: (context) => GetProductByIdUseCase(context.read<ProductsRepository>()),
  ),
  RepositoryProvider(
    create: (context) => GetProductCategoriesUseCase(context.read<ProductsRepository>()),
  ),

  // Product Comments dependencies
  RepositoryProvider(create: (_) => ProductCommentsLocalDataSource()),
  RepositoryProvider<ProductCommentsRemoteDataSource>(
    create: (context) => ProductCommentsRemoteDataSourceImpl(client: context.read<ApiClient>()),
  ),
  RepositoryProvider<ProductCommentsRepository>(
    create: (context) => ProductCommentsRepositoryImpl(
      remoteDataSource: context.read<ProductCommentsRemoteDataSource>(),
      localDataSource: context.read<ProductCommentsLocalDataSource>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => GetProductCommentsUseCase(context.read<ProductCommentsRepository>()),
  ),
  RepositoryProvider(
    create: (context) => AddProductCommentUseCase(context.read<ProductCommentsRepository>()),
  ),
  RepositoryProvider(
    create: (context) => UpdateProductCommentUseCase(context.read<ProductCommentsRepository>()),
  ),
  RepositoryProvider(
    create: (context) => DeleteProductCommentUseCase(context.read<ProductCommentsRepository>()),
  ),
];
