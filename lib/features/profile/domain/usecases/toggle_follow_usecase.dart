import '../../../../core/utils/result.dart';
import '../repositories/seller_repository.dart';

class ToggleFollowUseCase {
  final SellerRepository repository;

  const ToggleFollowUseCase(this.repository);

  Future<Result<int>> call(String sellerId, String userId) {
    return repository.toggleFollow(sellerId, userId);
  }
}
