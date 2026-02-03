class Routes {
  static final home = '/home';
  static final myPosts = '/my-posts';
  static final orders = '/orders';
  static final profile = '/profile';
  static final allProducts = '/products';
  static final productDetail = '/products/:productId';
  static final sellerProfile = '/seller/:sellerId';
  static final login = '/login';
  static final postDetail = '/post/:postId';

  static String getPostDetail(String postId) => '/post/$postId';
  static String getProductDetail(String productId) => '/products/$productId';
  static String getSellerProfile(String sellerId) => '/seller/$sellerId';
}
