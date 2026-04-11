enum PostStatus {
  active,
  archived,
  agreed,
  negotiation,
}

extension PostStatusX on PostStatus {
  String get label {
    switch (this) {
      case PostStatus.active:
        return 'Active';
      case PostStatus.archived:
        return 'Archived';
      case PostStatus.agreed:
        return 'Kelishilgan';
      case PostStatus.negotiation:
        return 'Kelishilmoqda';
    }
  }

  String get value {
    switch (this) {
      case PostStatus.active:
        return 'active';
      case PostStatus.archived:
        return 'archived';
      case PostStatus.agreed:
        return 'agreed';
      case PostStatus.negotiation:
        return 'negotiation';
    }
  }
}
