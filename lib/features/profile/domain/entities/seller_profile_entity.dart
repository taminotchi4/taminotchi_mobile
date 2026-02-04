class SellerProfileEntity {
  final String id;
  final String name;
  final String description;
  final String avatarPath;
  final int followersCount;
  final int productsCount;
  final bool isFollowing;

  const SellerProfileEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarPath,
    required this.followersCount,
    required this.productsCount,
    required this.isFollowing,
  });
}
