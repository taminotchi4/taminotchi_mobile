enum PostStatus {
  active,
  archived, // Kelishilgan
}

extension PostStatusX on PostStatus {
  String get label {
    switch (this) {
      case PostStatus.active:
        return 'Active';
      case PostStatus.archived:
        return 'Kelishilgan';
    }
  }
}
