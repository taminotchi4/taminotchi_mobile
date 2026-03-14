import '../../../../core/utils/result.dart';
import '../../domain/entities/follower_entity.dart';
import '../../domain/entities/profile_user_role.dart';
import '../../domain/entities/seller_profile_entity.dart';
import '../../domain/repositories/seller_repository.dart';
import '../datasources/seller_local_data_source.dart';

class SellerRepositoryImpl implements SellerRepository {
  final SellerLocalDataSource localDataSource;

  const SellerRepositoryImpl(this.localDataSource);

  @override
  Future<Result<SellerProfileEntity>> getSellerProfile(String sellerId) async {
    try {
      final seller = localDataSource.getSeller(sellerId);
      if (seller == null) {
        return Result.error(Exception('Seller not found'));
      }
      final followersCount = localDataSource.getFollowers(sellerId).length;
      final isFollowing = localDataSource.isFollowing(sellerId);
      return Result.ok(SellerProfileEntity(
        id: seller.id,
        name: seller.name,
        description: seller.description,
        avatarPath: seller.avatar,
        address: seller.address,
        followersCount: followersCount,
        productsCount: 0,
        isFollowing: isFollowing,
      ));
    } catch (e) {
      return Result.error(Exception('Failed to load seller'));
    }
  }

  @override
  Future<Result<List<FollowerEntity>>> getFollowers(String sellerId) async {
    try {
      final followers = localDataSource.getFollowers(sellerId).map((item) {
        return FollowerEntity(
          id: item.id,
          name: item.name,
          avatarPath: item.avatar,
        );
      }).toList();
      return Result.ok(followers);
    } catch (e) {
      return Result.error(Exception('Failed to load followers'));
    }
  }

  @override
  Future<Result<int>> toggleFollow(String sellerId, String userId) async {
    try {
      final count = localDataSource.toggleFollow(sellerId, userId);
      return Result.ok(count);
    } catch (e) {
      return Result.error(Exception('Failed to toggle follow'));
    }
  }

  @override
  Future<Result<bool>> isFollowing(String sellerId, String userId) async {
    try {
      return Result.ok(localDataSource.isFollowing(sellerId));
    } catch (e) {
      return Result.error(Exception('Failed to load follow state'));
    }
  }

  @override
  Future<Result<String>> getCurrentUserId() async {
    try {
      return Result.ok(localDataSource.getCurrentUserId());
    } catch (e) {
      return Result.error(Exception('Failed to load user'));
    }
  }

  @override
  Future<Result<ProfileUserRole>> getCurrentUserRole() async {
    try {
      return Result.ok(localDataSource.getCurrentUserRole());
    } catch (e) {
      return Result.error(Exception('Failed to load role'));
    }
  }
}
