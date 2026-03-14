class PostCategoryEntity {
  final String id;
  final String name;
  final String iconPath;
  final List<PostCategoryEntity>? subcategories;
  final String? parentId;
  final String? hintText;

  const PostCategoryEntity({
    required this.id,
    required this.name,
    required this.iconPath,
    this.subcategories,
    this.parentId,
    this.hintText,
  });

  bool get hasSubcategories => subcategories != null && subcategories!.isNotEmpty;
}
