class GroupEntity {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String? supCategoryId;
  final String? profilePhoto;
  final int membersCount;
  final bool isJoined;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.supCategoryId,
    this.profilePhoto,
    required this.membersCount,
    required this.isJoined,
  });
}
