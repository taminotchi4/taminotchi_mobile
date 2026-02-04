import '../../../../core/utils/result.dart';
import '../entities/seller_profile_entity.dart';
import '../repositories/seller_repository.dart';

class GetSellerProfileUseCase {
  final SellerRepository repository;

  const GetSellerProfileUseCase(this.repository);

  Future<Result<SellerProfileEntity>> call(String sellerId) {
    return repository.getSellerProfile(sellerId);
  }
}
