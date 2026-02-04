import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taminotchi_app/core/routing/routes.dart';
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/datasources/home_media_picker.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/usecases/create_post_usecase.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_comment_counts_usecase.dart';
import '../../features/home/domain/usecases/get_comments_usecase.dart';
import '../../features/home/domain/usecases/get_current_user_id_usecase.dart';
import '../../features/home/domain/usecases/get_current_user_role_usecase.dart';
import '../../features/home/domain/usecases/get_post_by_id_usecase.dart';
import '../../features/home/domain/usecases/get_all_posts_usecase.dart';
import '../../features/home/domain/usecases/get_my_posts_usecase.dart';
import '../../features/home/presentation/managers/home_bloc.dart';
import '../../features/home/presentation/managers/home_event.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/post_detail_page.dart';
import '../../features/my_posts/presentation/pages/my_posts_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/data/datasources/products_local_data_source.dart';
import '../../features/products/data/datasources/product_comments_local_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/data/repositories/product_comments_repository_impl.dart';
import '../../features/products/domain/usecases/get_product_by_id_usecase.dart';
import '../../features/products/domain/usecases/get_product_categories_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/get_product_comments_usecase.dart';
import '../../features/products/domain/usecases/add_product_comment_usecase.dart';
import '../../features/products/domain/usecases/update_product_comment_usecase.dart';
import '../../features/products/domain/usecases/delete_product_comment_usecase.dart';
import '../../features/products/presentation/managers/products_bloc.dart';
import '../../features/products/presentation/managers/products_event.dart';
import '../../features/products/presentation/managers/product_comments_bloc.dart';
import '../../features/products/presentation/managers/product_details_bloc.dart';
import '../../features/products/presentation/pages/all_products_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
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
import '../../features/chat/data/datasources/chat_local_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/usecases/get_or_create_chat_usecase.dart';
import '../../features/chat/domain/usecases/get_messages_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/presentation/managers/chat_bloc.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../global/widgets/main_shell_page.dart';

final router = GoRouter(
  initialLocation: Routes.home,

  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final homeRepository = HomeRepositoryImpl(HomeLocalDataSource());
        final productsRepository = ProductsRepositoryImpl(ProductsLocalDataSource());
        final sellerRepository = SellerRepositoryImpl(SellerLocalDataSource());
        final commentsRepository =
            ProductCommentsRepositoryImpl(ProductCommentsLocalDataSource());
        final chatRepository = ChatRepositoryImpl(ChatLocalDataSource());
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => HomeBloc(
                getAllPostsUseCase: GetAllPostsUseCase(homeRepository),
                getMyPostsUseCase: GetMyPostsUseCase(homeRepository),
                createPostUseCase: CreatePostUseCase(homeRepository),
                getPostByIdUseCase: GetPostByIdUseCase(homeRepository),
                getCommentsUseCase: GetCommentsUseCase(homeRepository),
                getCommentCountsUseCase: GetCommentCountsUseCase(homeRepository),
                getCategoriesUseCase: GetCategoriesUseCase(homeRepository),
                getCurrentUserIdUseCase: GetCurrentUserIdUseCase(homeRepository),
                getCurrentUserRoleUseCase: GetCurrentUserRoleUseCase(homeRepository),
                mediaPicker: HomeMediaPicker(),
              )..add(const HomeStarted()),
            ),
            BlocProvider(
              create: (_) => ProductsBloc(
                getProductsUseCase: GetProductsUseCase(productsRepository),
                getProductByIdUseCase: GetProductByIdUseCase(productsRepository),
                getCategoriesUseCase: GetProductCategoriesUseCase(productsRepository),
              )..add(const ProductsStarted()),
            ),
            BlocProvider(
              create: (_) => SellerProfileBloc(
                getSellerProfileUseCase:
                    GetSellerProfileUseCase(sellerRepository),
                getFollowersUseCase: GetFollowersUseCase(sellerRepository),
                toggleFollowUseCase: ToggleFollowUseCase(sellerRepository),
                getCurrentUserProfileUseCase:
                    GetCurrentUserProfileUseCase(sellerRepository),
                getProductsUseCase: GetProductsUseCase(productsRepository),
              ),
            ),
            BlocProvider(
              create: (_) => FollowersBloc(
                getFollowersUseCase: GetFollowersUseCase(sellerRepository),
              ),
            ),
            BlocProvider(
              create: (_) => ProductDetailsBloc(),
            ),
            BlocProvider(
              create: (_) => ProductCommentsBloc(
                getCommentsUseCase:
                    GetProductCommentsUseCase(commentsRepository),
                addCommentUseCase: AddProductCommentUseCase(commentsRepository),
                updateCommentUseCase:
                    UpdateProductCommentUseCase(commentsRepository),
                deleteCommentUseCase:
                    DeleteProductCommentUseCase(commentsRepository),
              ),
            ),
            BlocProvider(
              create: (_) => ChatBloc(
                getOrCreateChatUseCase:
                    GetOrCreateChatUseCase(chatRepository),
                getMessagesUseCase: GetMessagesUseCase(chatRepository),
                sendMessageUseCase: SendMessageUseCase(chatRepository),
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
            return ChatPage(sellerId: sellerId, userId: 'user_1');
          },
        ),
      ],
    ),
  ],
);
