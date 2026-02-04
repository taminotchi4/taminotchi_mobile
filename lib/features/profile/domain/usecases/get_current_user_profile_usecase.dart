import '../../../../core/utils/result.dart';
import '../entities/profile_user_role.dart';
import '../repositories/seller_repository.dart';

class GetCurrentUserProfileUseCase {
  final SellerRepository repository;

  const GetCurrentUserProfileUseCase(this.repository);

  Future<Result<String>> getUserId() => repository.getCurrentUserId();

  Future<Result<ProfileUserRole>> getRole() => repository.getCurrentUserRole();
}
