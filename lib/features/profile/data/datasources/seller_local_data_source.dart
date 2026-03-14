import '../../../../core/utils/icons.dart';
import '../../domain/entities/profile_user_role.dart';

class SellerLocalDataSource {
  final String _currentUserId = 'user_1';
  final ProfileUserRole _currentUserRole = ProfileUserRole.user;

  final Map<String, bool> _following = {};
  final Map<String, List<_FollowerModel>> _followers = {
    'seller_1': [
      const _FollowerModel(id: 'user_2', name: 'Dilshod', avatar: AppIcons.user),
      const _FollowerModel(id: 'user_3', name: 'Madina', avatar: AppIcons.user),
    ],
    'seller_2': [
      const _FollowerModel(id: 'user_4', name: 'Aziza', avatar: AppIcons.user),
    ],
  };

  final Map<String, _SellerModel> _sellers = {
    'seller_1': const _SellerModel(
      id: 'seller_1',
      name: 'Market Plus',
      description: 'Sifatli mahsulotlar va tezkor yetkazib berish.',
      avatar: AppIcons.user,
      address: 'Toshkent sh. Chilonzor t. 10-uy',
    ),
    'seller_2': const _SellerModel(
      id: 'seller_2',
      name: 'Smart Store',
      description: 'Zamonaviy texnika va xizmatlar.',
      avatar: AppIcons.user,
      address: 'Toshkent sh. Yunusobod t. 5-mavze',
    ),
  };

  String getCurrentUserId() => _currentUserId;

  ProfileUserRole getCurrentUserRole() => _currentUserRole;

  _SellerModel? getSeller(String sellerId) => _sellers[sellerId];

  List<_FollowerModel> getFollowers(String sellerId) {
    return List.unmodifiable(_followers[sellerId] ?? []);
  }

  bool isFollowing(String sellerId) => _following[sellerId] ?? false;

  int toggleFollow(String sellerId, String userId) {
    final followers = _followers.putIfAbsent(sellerId, () => []);
    final isFollowingNow = !isFollowing(sellerId);
    _following[sellerId] = isFollowingNow;
    if (isFollowingNow) {
      if (followers.every((f) => f.id != userId)) {
        followers.add(_FollowerModel(id: userId, name: 'Mening akkauntim', avatar: AppIcons.user));
      }
    } else {
      followers.removeWhere((f) => f.id == userId);
    }
    return followers.length;
  }
}

class _SellerModel {
  final String id;
  final String name;
  final String description;
  final String avatar;
  final String address;

  const _SellerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.address,
  });
}

class _FollowerModel {
  final String id;
  final String name;
  final String avatar;

  const _FollowerModel({
    required this.id,
    required this.name,
    required this.avatar,
  });
}
