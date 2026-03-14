import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/entities/user_role.dart';

enum HomeActionStatus { initial, postCreated, error, authRequired }

class HomeState {
  static const Object _unset = Object();
  final List<PostEntity> posts;
  final List<PostEntity> myPosts;
  final List<PostEntity> carouselPosts;
  final List<PostCategoryEntity> categories;
  final PostCategoryEntity? selectedCategory;
  final bool isComposerExpanded;
  final List<PostImageEntity> selectedImages;
  final bool isSubmitting;
  final HomeActionStatus actionStatus;
  final String? errorMessage;
  final bool isLoadingDetails;
  final PostEntity? activePost;
  final List<CommentEntity> activeComments;
  final Map<String, int> commentCounts;
  final String currentUserId;
  final UserRole currentUserRole;
  final String? categoryError;
  final String? contentError;
  final PostCategoryEntity? selectedSubcategory;
  final String? subcategoryError;

  const HomeState({
    required this.posts,
    required this.myPosts,
    required this.carouselPosts,
    required this.categories,
    required this.selectedCategory,
    required this.isComposerExpanded,
    required this.selectedImages,
    required this.isSubmitting,
    required this.actionStatus,
    required this.errorMessage,
    required this.isLoadingDetails,
    required this.activePost,
    required this.activeComments,
    required this.commentCounts,
    required this.currentUserId,
    required this.currentUserRole,
    this.categoryError,
    this.contentError,
    this.selectedSubcategory,
    this.subcategoryError,
  });

  bool get canCreatePost => true;

  factory HomeState.initial() => const HomeState(
    posts: [],
    myPosts: [],
    carouselPosts: [],
    categories: [],
    selectedCategory: null,
    isComposerExpanded: false,
    selectedImages: [],
    isSubmitting: false,
    actionStatus: HomeActionStatus.initial,
    errorMessage: null,
    isLoadingDetails: false,
    activePost: null,
    activeComments: [],
    commentCounts: {},
    currentUserId: '',
    currentUserRole: UserRole.user,
    categoryError: null,
    contentError: null,
    selectedSubcategory: null,
    subcategoryError: null,
  );

  HomeState copyWith({
    List<PostEntity>? posts,
    List<PostEntity>? myPosts,
    List<PostEntity>? carouselPosts,
    List<PostCategoryEntity>? categories,
    Object? selectedCategory = _unset,
    bool? isComposerExpanded,
    List<PostImageEntity>? selectedImages,
    bool? isSubmitting,
    HomeActionStatus? actionStatus,
    String? errorMessage,
    bool? isLoadingDetails,
    PostEntity? activePost,
    List<CommentEntity>? activeComments,
    Map<String, int>? commentCounts,
    String? currentUserId,
    UserRole? currentUserRole,
    Object? categoryError = _unset,
    Object? contentError = _unset,
    Object? selectedSubcategory = _unset,
    Object? subcategoryError = _unset,
  }) {
    return HomeState(
      posts: posts ?? this.posts,
      myPosts: myPosts ?? this.myPosts,
      carouselPosts: carouselPosts ?? this.carouselPosts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory == _unset
          ? this.selectedCategory
          : selectedCategory as PostCategoryEntity?,
      isComposerExpanded: isComposerExpanded ?? this.isComposerExpanded,
      selectedImages: selectedImages ?? this.selectedImages,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      activePost: activePost ?? this.activePost,
      activeComments: activeComments ?? this.activeComments,
      commentCounts: commentCounts ?? this.commentCounts,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      categoryError: categoryError == _unset ? this.categoryError : categoryError as String?,
      contentError: contentError == _unset ? this.contentError : contentError as String?,
      selectedSubcategory: selectedSubcategory == _unset ? this.selectedSubcategory : selectedSubcategory as PostCategoryEntity?,
      subcategoryError: subcategoryError == _unset ? this.subcategoryError : subcategoryError as String?,
    );
  }
}
