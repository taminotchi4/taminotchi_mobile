class Routes {
  static final home = '/home';
  static final myPosts = '/my-posts';
  static final chats = '/chats';
  static final orders = '/orders';
  static final profile = '/profile';
  static final allProducts = '/products';
  static final productDetail = '/products/:productId';
  static final sellerProfile = '/seller/:sellerId';
  static final sellerFollowers = '/seller/:sellerId/followers';
  static final sellerChat = '/seller/:sellerId/chat';
  static final auth = '/auth';
  static final login = '/login';
  static final postDetail = '/post/:postId';
  static const categoryFeed = '/category/:categoryId';
  static const notifications = '/notifications';

  static String getPostDetail(String postId) => '/post/$postId';
  static String getProductDetail(String productId) => '/products/$productId';
  static String getSellerProfile(String sellerId) => '/seller/$sellerId';
  static String getSellerFollowers(String sellerId) =>
      '/seller/$sellerId/followers';
  static String getSellerChat(String sellerId) => '/seller/$sellerId/chat';
  static String getCategoryFeed(String categoryId) => '/category/$categoryId';
}
