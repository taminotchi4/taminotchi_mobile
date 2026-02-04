import '../../../../core/utils/result.dart';
import '../entities/follower_entity.dart';
import '../entities/profile_user_role.dart';
import '../entities/seller_profile_entity.dart';

abstract class SellerRepository {
  Future<Result<SellerProfileEntity>> getSellerProfile(String sellerId);

  Future<Result<List<FollowerEntity>>> getFollowers(String sellerId);

  Future<Result<int>> toggleFollow(String sellerId, String userId);

  Future<Result<bool>> isFollowing(String sellerId, String userId);

  Future<Result<String>> getCurrentUserId();

  Future<Result<ProfileUserRole>> getCurrentUserRole();
}
