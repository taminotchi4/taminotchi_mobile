import '../../domain/entities/follower_entity.dart';

class FollowersState {
  final List<FollowerEntity> followers;
  final List<FollowerEntity> filtered;
  final String query;
  final bool isLoading;

  const FollowersState({
    required this.followers,
    required this.filtered,
    required this.query,
    required this.isLoading,
  });

  factory FollowersState.initial() => const FollowersState(
    followers: [],
    filtered: [],
    query: '',
    isLoading: false,
  );

  FollowersState copyWith({
    List<FollowerEntity>? followers,
    List<FollowerEntity>? filtered,
    String? query,
    bool? isLoading,
  }) {
    return FollowersState(
      followers: followers ?? this.followers,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
