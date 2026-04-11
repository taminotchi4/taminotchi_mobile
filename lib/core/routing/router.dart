import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taminotchi_app/core/routing/routes.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_username_usecase.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/home/data/datasources/home_media_picker.dart';
import '../../features/home/domain/usecases/create_post_usecase.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_comment_counts_usecase.dart';
import '../../features/home/domain/usecases/get_comments_usecase.dart';
import '../../features/home/domain/usecases/get_current_user_id_usecase.dart';
import '../../features/home/domain/usecases/get_current_user_role_usecase.dart';
import '../../features/home/domain/usecases/get_post_by_id_usecase.dart';
import '../../features/home/domain/usecases/get_all_posts_usecase.dart';
import '../../features/home/domain/usecases/get_my_posts_usecase.dart';
import '../../features/home/domain/usecases/get_posts_by_category_usecase.dart';
import '../../features/home/domain/usecases/reply_to_comment_usecase.dart';
import '../../features/home/domain/usecases/update_post_status_usecase.dart';
import '../../features/home/domain/usecases/get_groups_by_category_usecase.dart';
import '../../features/home/domain/usecases/get_posts_by_group_usecase.dart';
import '../../features/home/presentation/managers/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/post_detail_page.dart';
import '../../features/my_posts/presentation/pages/my_posts_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/domain/usecases/get_product_by_id_usecase.dart';
import '../../features/products/domain/usecases/get_product_categories_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/get_product_comments_usecase.dart';
import '../../features/products/domain/usecases/add_product_comment_usecase.dart';
import '../../features/products/domain/usecases/update_product_comment_usecase.dart';
import '../../features/products/domain/usecases/delete_product_comment_usecase.dart';
import '../../features/products/presentation/managers/products_bloc.dart';
import '../../features/products/presentation/managers/product_comments_bloc.dart';
import '../../features/products/presentation/managers/product_details_bloc.dart';
import '../../features/products/presentation/pages/all_products_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/profile/domain/usecases/delete_account_usecase.dart';
import '../../features/profile/presentation/managers/client_profile_event.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/seller_profile_page.dart';
import '../../features/profile/presentation/pages/followers_page.dart';
import '../../features/profile/presentation/managers/seller_profile_bloc.dart';
import '../../features/profile/presentation/managers/followers_bloc.dart';
import '../../features/profile/domain/usecases/get_seller_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_followers_usecase.dart';
import '../../features/profile/domain/usecases/toggle_follow_usecase.dart';
import '../../features/profile/domain/usecases/get_current_user_profile_usecase.dart';
import '../../features/profile/data/datasources/seller_local_data_source.dart';
import '../../features/profile/data/repositories/seller_repository_impl.dart';
import '../../features/chat/data/services/audio_recorder_service.dart';
import '../../features/chat/data/services/audio_player_service.dart';
import '../../features/chat/data/services/gallery_service.dart';
import '../../features/chat/domain/usecases/get_or_create_chat_usecase.dart';
import '../../features/chat/domain/usecases/get_messages_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/presentation/managers/chat_bloc.dart';
import '../../features/chat/presentation/managers/private_chat_bloc.dart';
import '../../features/chat/presentation/managers/private_chat_list_bloc.dart';
import '../../features/chat/presentation/managers/group_chat_bloc.dart';
import '../../features/chat/presentation/managers/notification_proxy_bloc.dart';
import '../../features/chat/presentation/pages/chats_home_page.dart';
import '../../features/chat/presentation/pages/private_chat_page.dart';
import '../../features/chat/presentation/pages/group_chat_page.dart';
import '../../features/chat/presentation/managers/comment_bloc.dart';
import '../../features/products/presentation/pages/product_comment_chat_page.dart';
import '../../features/profile/domain/usecases/get_client_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_client_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_profile_photo_usecase.dart';
import '../../features/profile/domain/usecases/logout_usecase.dart' as profile_logout;
import '../../features/profile/presentation/managers/client_profile_bloc.dart';
import '../../features/category_feed/presentation/pages/category_feed_page.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/become_seller_page.dart';
import '../../features/auth/presentation/pages/auth_main_page.dart';
import '../../global/widgets/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

final router = GoRouter(
  initialLocation: Routes.splash,

  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.auth,
      builder: (context, state) => const AuthMainPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => HomeBloc(
                getAllPostsUseCase: context.read<GetAllPostsUseCase>(),
                getMyPostsUseCase: context.read<GetMyPostsUseCase>(),
                createPostUseCase: context.read<CreatePostUseCase>(),
                getPostByIdUseCase: context.read<GetPostByIdUseCase>(),
                getCommentsUseCase: context.read<GetCommentsUseCase>(),
                getCommentCountsUseCase: context.read<GetCommentCountsUseCase>(),
                getCategoriesUseCase: context.read<GetCategoriesUseCase>(),
                getCurrentUserIdUseCase: context.read<GetCurrentUserIdUseCase>(),
                getCurrentUserRoleUseCase: context.read<GetCurrentUserRoleUseCase>(),
                mediaPicker: HomeMediaPicker(),
                replyToCommentUseCase: context.read<ReplyToCommentUseCase>(),
                updatePostStatusUseCase: context.read<UpdatePostStatusUseCase>(),
                getPostsByCategoryUseCase: context.read<GetPostsByCategoryUseCase>(),
                getGroupsByCategoryUseCase: context.read<GetGroupsByCategoryUseCase>(),
                getPostsByGroupUseCase: context.read<GetPostsByGroupUseCase>(),
              ),
            ),
            BlocProvider(
              create: (context) => ProductsBloc(
                getProductsUseCase: context.read<GetProductsUseCase>(),
                getProductByIdUseCase: context.read<GetProductByIdUseCase>(),
                getCategoriesUseCase: context.read<GetProductCategoriesUseCase>(),
              ),
            ),
            BlocProvider(
              create: (context) => SellerProfileBloc(
                getSellerProfileUseCase:
                    GetSellerProfileUseCase(SellerRepositoryImpl(SellerLocalDataSource())),
                getFollowersUseCase: GetFollowersUseCase(SellerRepositoryImpl(SellerLocalDataSource())),
                toggleFollowUseCase: ToggleFollowUseCase(SellerRepositoryImpl(SellerLocalDataSource())),
                getCurrentUserProfileUseCase:
                    GetCurrentUserProfileUseCase(SellerRepositoryImpl(SellerLocalDataSource())),
                getProductsUseCase: context.read<GetProductsUseCase>(),
              ),
            ),
            BlocProvider(
              create: (context) => FollowersBloc(
                getFollowersUseCase: GetFollowersUseCase(SellerRepositoryImpl(SellerLocalDataSource())),
              ),
            ),
            BlocProvider(create: (_) => ProductDetailsBloc()),
            BlocProvider(
              create: (context) => ProductCommentsBloc(
                getCommentsUseCase: context.read<GetProductCommentsUseCase>(),
                addCommentUseCase: context.read<AddProductCommentUseCase>(),
                updateCommentUseCase: context.read<UpdateProductCommentUseCase>(),
                deleteCommentUseCase: context.read<DeleteProductCommentUseCase>(),
              ),
            ),
            BlocProvider(
              create: (context) => ChatBloc(
                getOrCreateChatUseCase:
                    GetOrCreateChatUseCase(context.read<ChatRepository>()),
                getMessagesUseCase: GetMessagesUseCase(context.read<ChatRepository>()),
                sendMessageUseCase: SendMessageUseCase(context.read<ChatRepository>()),
                audioRecorder: AudioRecorderService(),
                audioPlayer: AudioPlayerService(),
                galleryService: GalleryService(),
              ),
            ),
            BlocProvider(
              create: (context) => ClientProfileBloc(
                getProfileUseCase: context.read<GetClientProfileUseCase>(),
                updateProfileUseCase: context.read<UpdateClientProfileUseCase>(),
                uploadPhotoUseCase: context.read<UploadProfilePhotoUseCase>(),
                logoutUseCase: context.read<profile_logout.LogoutUseCase>(),
                deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
                checkUsernameUseCase: context.read<CheckUsernameUseCase>(),
              )..add(const ClientProfileStarted()),
            ),
            // --- New BLoCs ---
            BlocProvider(
              create: (context) => PrivateChatListBloc(
                repository: context.read<ChatRepository>(),
                authRepository: context.read<AuthRepository>(),
              )..add(PrivateChatListLoad()),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => NotificationProxyBloc(
                repository: context.read<NotificationRepositoryImpl>(),
                authRepository: context.read<AuthRepository>(),
              ),
            ),
          ],
          child: MainShellPage(
            location: state.uri.toString(),
            child: child,
          ),
        );
      },
      routes: [
        GoRoute(path: Routes.home, builder: (context, state) => const HomePage()),
        GoRoute(
          path: Routes.myPosts,
          builder: (context, state) => const MyPostsPage(),
        ),
        GoRoute(
          path: Routes.orders,
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: Routes.chats,
          builder: (context, state) => const ChatsHomePage(),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: Routes.allProducts,
          builder: (context, state) => const AllProductsPage(),
        ),
        GoRoute(
          path: Routes.postDetail,
          builder: (context, state) {
            final postId = state.pathParameters['postId'] ?? '';
            return PostDetailPage(postId: postId);
          },
        ),
        GoRoute(
          path: Routes.productDetail,
          builder: (context, state) {
            final productId = state.pathParameters['productId'] ?? '';
            return ProductDetailPage(productId: productId);
          },
        ),
        GoRoute(
          path: Routes.sellerProfile,
          builder: (context, state) {
            final sellerId = state.pathParameters['sellerId'] ?? '';
            return SellerProfilePage(sellerId: sellerId);
          },
        ),
        GoRoute(
          path: Routes.sellerFollowers,
          builder: (context, state) {
            final sellerId = state.pathParameters['sellerId'] ?? '';
            return FollowersPage(sellerId: sellerId);
          },
        ),
        GoRoute(
          path: Routes.sellerChat,
          builder: (context, state) {
            final sellerId = state.pathParameters['sellerId'] ?? '';
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final name = extra['name'] as String?;
            final role = extra['role'] as String? ?? 'market';
            
            return BlocProvider(
              create: (_) => PrivateChatBloc(
                repository: context.read<ChatRepository>(),
                authRepository: context.read<AuthRepository>(),
              )..add(PrivateChatStarted(receiverId: sellerId, receiverRole: role)),
              child: PrivateChatPage(
                receiverId: sellerId,
                receiverRole: role,
                receiverName: name,
              ),
            );
          },
        ),
        // Private chat
        GoRoute(
          path: Routes.privateChat,
          builder: (context, state) {
            final chatId = state.pathParameters['chatId'] ?? '';
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final name = extra['name'] as String?;
            return BlocProvider(
              create: (_) {
                final bloc = PrivateChatBloc(
                  repository: context.read<ChatRepository>(),
                  authRepository: context.read<AuthRepository>(),
                );
                // If chatId is in extra, the chat was already opened via REST (search flow)
                // Just connect to socket directly
                if (extra.containsKey('chatId')) {
                  bloc.add(PrivateChatStartedWithId(chatId));
                } else {
                  // legacy: receiverId + role
                  final receiverId = extra['receiverId'] as String? ?? chatId;
                  final receiverRole = extra['receiverRole'] as String? ?? 'market';
                  bloc.add(PrivateChatStarted(receiverId: receiverId, receiverRole: receiverRole));
                }
                return bloc;
              },
              child: PrivateChatPage(
                receiverId: extra['receiverId'] as String? ?? chatId,
                receiverRole: extra['receiverRole'] as String? ?? 'market',
                receiverName: name,
              ),
            );
          },
        ),
        // Group chat
        GoRoute(
          path: Routes.groupChat,
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            return BlocProvider(
              create: (_) => GroupChatBloc(
                repository: context.read<ChatRepository>(),
                authRepository: context.read<AuthRepository>(),
              ),
              child: GroupChatPage(groupId: groupId),
            );
          },
        ),
        GoRoute(
          path: Routes.categoryFeed,
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId'] ?? '';
            final showAll = state.uri.queryParameters['showAll'] == 'true';
            return CategoryFeedPage(
              categoryId: categoryId,
              showAllPosts: showAll,
            );
          },
        ),
        GoRoute(
          path: Routes.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: Routes.becomeSeller,
          builder: (context, state) => const BecomeSellerPage(),
        ),
        // Product Comment Chat
        GoRoute(
          path: Routes.productCommentChat,
          builder: (context, state) {
            final productId = state.pathParameters['productId'] ?? '';
            final commentId = state.pathParameters['commentId'] ?? '';
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final productName = extra['productName'] as String? ?? 'Izohlar';
            return BlocProvider(
              create: (_) => CommentBloc(
                authRepository: context.read<AuthRepository>(),
                chatRepository: context.read<ChatRepository>(),
              ),
              child: ProductCommentChatPage(
                productName: productName,
                commentId: commentId,
              ),
            );
          },
        ),
      ],
    ),
  ],
);
