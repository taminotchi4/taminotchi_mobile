import '../../../../core/utils/result.dart';
import '../entities/follower_entity.dart';
import '../repositories/seller_repository.dart';

class GetFollowersUseCase {
  final SellerRepository repository;

  const GetFollowersUseCase(this.repository);

  Future<Result<List<FollowerEntity>>> call(String sellerId) {
    return repository.getFollowers(sellerId);
  }
}
