sealed class FollowersEvent {
  const FollowersEvent();
}

class FollowersStarted extends FollowersEvent {
  final String sellerId;

  const FollowersStarted(this.sellerId);
}

class FollowersSearchChanged extends FollowersEvent {
  final String query;

  const FollowersSearchChanged(this.query);
}
