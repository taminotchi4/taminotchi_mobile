import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/home_media_picker.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_comment_counts_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/get_current_user_id_usecase.dart';
import '../../domain/usecases/get_current_user_role_usecase.dart';
import '../../domain/usecases/get_post_by_id_usecase.dart';
import '../../domain/usecases/get_all_posts_usecase.dart';
import '../../domain/usecases/get_my_posts_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const int maxImages = 8;
  final GetAllPostsUseCase getAllPostsUseCase;
  final GetMyPostsUseCase getMyPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final GetPostByIdUseCase getPostByIdUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final GetCommentCountsUseCase getCommentCountsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;
  final GetCurrentUserRoleUseCase getCurrentUserRoleUseCase;
  final HomeMediaPicker mediaPicker;
  final Random _random = Random();

  HomeBloc({
    required this.getAllPostsUseCase,
    required this.getMyPostsUseCase,
    required this.createPostUseCase,
    required this.getPostByIdUseCase,
    required this.getCommentsUseCase,
    required this.getCommentCountsUseCase,
    required this.getCategoriesUseCase,
    required this.getCurrentUserIdUseCase,
    required this.getCurrentUserRoleUseCase,
    required this.mediaPicker,
  }) : super(HomeState.initial()) {
    on<HomeStarted>(_onStarted);
    on<HomeExpandComposer>(_onExpandComposer);
    on<HomeCollapseComposer>(_onCollapseComposer);
    on<HomeSelectCategory>(_onSelectCategory);
    on<HomeSelectSubcategory>(_onSelectSubcategory);
    on<HomeAddImagesFromGallery>(_onAddImagesFromGallery);
    on<HomeAddImageFromCamera>(_onAddImageFromCamera);
    on<HomeAddImagesFromFiles>(_onAddImagesFromFiles);
    on<HomeRemoveImage>(_onRemoveImage);
    on<HomeCreatePost>(_onCreatePost);
    on<HomeLoadPostDetails>(_onLoadPostDetails);
    on<HomeClearActionStatus>(_onClearActionStatus);
    on<HomeClearContentError>(_onClearContentError);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    await _loadUser(emit);
    await _loadCategories(emit);
    await _loadPosts(emit);
    await _loadCommentCounts(emit);
  }

  Future<void> _loadUser(Emitter<HomeState> emit) async {
    final idResult = await getCurrentUserIdUseCase();
    final roleResult = await getCurrentUserRoleUseCase();
    idResult.fold(
      (error) => emit(state.copyWith(
        actionStatus: HomeActionStatus.error,
        errorMessage: error.toString(),
      )),
      (id) => emit(state.copyWith(currentUserId: id)),
    );
    roleResult.fold(
      (error) => emit(state.copyWith(
        actionStatus: HomeActionStatus.error,
        errorMessage: error.toString(),
      )),
      (role) => emit(state.copyWith(currentUserRole: role)),
    );
  }

  Future<void> _loadCategories(Emitter<HomeState> emit) async {
    final result = await getCategoriesUseCase();
    result.fold(
      (error) => emit(state.copyWith(
        actionStatus: HomeActionStatus.error,
        errorMessage: error.toString(),
      )),
      (categories) => emit(state.copyWith(
        categories: categories,
        selectedCategory: categories.isEmpty ? null : categories.first,
      )),
    );
  }

  Future<void> _loadPosts(Emitter<HomeState> emit) async {
    final allPostsResult = await getAllPostsUseCase();
    final myPostsResult = await getMyPostsUseCase(state.currentUserId);
    allPostsResult.fold(
      (error) => emit(state.copyWith(
        actionStatus: HomeActionStatus.error,
        errorMessage: error.toString(),
      )),
      (allPosts) {
        myPostsResult.fold(
          (error) => emit(state.copyWith(
            actionStatus: HomeActionStatus.error,
            errorMessage: error.toString(),
          )),
          (myPosts) => emit(state.copyWith(
            posts: allPosts,
            myPosts: myPosts,
            carouselPosts: _shufflePosts(allPosts),
          )),
        );
      },
    );
  }

  Future<void> _loadCommentCounts(Emitter<HomeState> emit) async {
    final result = await getCommentCountsUseCase();
    result.fold(
      (error) => emit(state.copyWith(
        actionStatus: HomeActionStatus.error,
        errorMessage: error.toString(),
      )),
      (counts) => emit(state.copyWith(commentCounts: counts)),
    );
  }

  void _onExpandComposer(HomeExpandComposer event, Emitter<HomeState> emit) {
    // Only reset categories if composer is currently collapsed
    // If already expanded or categories are pre-selected, preserve them
    if (state.isComposerExpanded) {
      // Already expanded, just ensure it stays expanded
      emit(state.copyWith(isComposerExpanded: true));
    } else {
      // Expanding from collapsed state - reset everything
      emit(state.copyWith(
        isComposerExpanded: true,
        selectedCategory: null,
        selectedSubcategory: null,
        categoryError: null,
        subcategoryError: null,
        contentError: null,
      ));
    }
  }

  void _onCollapseComposer(HomeCollapseComposer event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      isComposerExpanded: false,
      selectedImages: [],
    ));
  }

  void _onSelectCategory(HomeSelectCategory event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      selectedCategory: event.category,
      selectedSubcategory: null,
      categoryError: null,
      subcategoryError: null,
    ));
  }

  void _onSelectSubcategory(HomeSelectSubcategory event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      selectedSubcategory: event.subcategory,
      subcategoryError: null,
    ));
  }

  Future<void> _onAddImagesFromGallery(
    HomeAddImagesFromGallery event,
    Emitter<HomeState> emit,
  ) async {
    final images = await mediaPicker.pickFromGallery();
    _mergeImages(images, emit);
  }

  Future<void> _onAddImageFromCamera(
    HomeAddImageFromCamera event,
    Emitter<HomeState> emit,
  ) async {
    final image = await mediaPicker.pickFromCamera();
    if (image != null) {
      _mergeImages([image], emit);
    }
  }

  Future<void> _onAddImagesFromFiles(
    HomeAddImagesFromFiles event,
    Emitter<HomeState> emit,
  ) async {
    final images = await mediaPicker.pickFromFiles();
    _mergeImages(images, emit);
  }

  void _mergeImages(List<PostImageEntity> images, Emitter<HomeState> emit) {
    final updated = [...state.selectedImages];
    for (final image in images) {
      if (updated.length >= maxImages) break;
      if (updated.any((item) => item.path == image.path)) continue;
      updated.add(image);
    }
    emit(state.copyWith(selectedImages: updated));
  }

  void _onRemoveImage(HomeRemoveImage event, Emitter<HomeState> emit) {
    final updated =
        state.selectedImages.where((e) => e.path != event.path).toList();
    emit(state.copyWith(selectedImages: updated));
  }

  Future<void> _onCreatePost(
    HomeCreatePost event,
    Emitter<HomeState> emit,
  ) async {
    if (!state.canCreatePost) return;
    final content = event.content.trim();
    final category = state.selectedCategory;
    final subcategory = state.selectedSubcategory;
    
    String? categoryError;
    String? subcategoryError;
    String? contentError;
    
    if (category == null) {
      categoryError = 'Kategoriyani tanlash majburiy';
    } else if (category.hasSubcategories && subcategory == null) {
      subcategoryError = 'Ichki kategoriyani tanlash majburiy';
    }
    
    if (content.length < 2) {
      contentError = 'Qidirayotgan maxsulotingiz haqida batafsil ma\'lumot yozishingiz kerak';
    }
    
    if (categoryError != null || subcategoryError != null || contentError != null) {
      emit(state.copyWith(
        categoryError: categoryError,
        subcategoryError: subcategoryError,
        contentError: contentError,
      ));
      return;
    }
    
    emit(state.copyWith(isSubmitting: true));
    // Use subcategory if selected, otherwise use parent category
    final postCategory = subcategory ?? category!;
    final result = await createPostUseCase(
      content: content,
      images: state.selectedImages,
      category: postCategory,
    );
    await result.fold(
      (error) async => emit(state.copyWith(
        isSubmitting: false,
        actionStatus: HomeActionStatus.error,
        errorMessage: error.toString(),
      )),
      (post) async {
        final updatedPosts = [post, ...state.posts];
        final updatedMyPosts = [post, ...state.myPosts];
        final updatedCounts = Map<String, int>.from(state.commentCounts);
        final commentResult = await getCommentsUseCase(post.id);
        commentResult.fold(
          (_) {},
          (comments) => updatedCounts[post.id] = comments.length,
        );
        emit(state.copyWith(
          isSubmitting: false,
          posts: updatedPosts,
          myPosts: updatedMyPosts,
          carouselPosts: _shufflePosts(updatedPosts),
          selectedImages: [],
          isComposerExpanded: false,
          actionStatus: HomeActionStatus.postCreated,
          commentCounts: updatedCounts,
        ));
      },
    );
  }

  Future<void> _onLoadPostDetails(
    HomeLoadPostDetails event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetails: true));
    final postResult = await getPostByIdUseCase(event.postId);
    final commentsResult = await getCommentsUseCase(event.postId);

    postResult.fold(
      (error) => emit(state.copyWith(
        isLoadingDetails: false,
        actionStatus: HomeActionStatus.error,
        errorMessage: error.toString(),
      )),
      (post) {
        commentsResult.fold(
          (commentError) => emit(state.copyWith(
            isLoadingDetails: false,
            actionStatus: HomeActionStatus.error,
            errorMessage: commentError.toString(),
          )),
          (comments) => emit(state.copyWith(
            isLoadingDetails: false,
            activePost: post,
            activeComments: comments,
          )),
        );
      },
    );
  }

  void _onClearActionStatus(
    HomeClearActionStatus event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(actionStatus: HomeActionStatus.initial));
  }

  void _onClearContentError(
    HomeClearContentError event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(contentError: null));
  }

  List<PostEntity> _shufflePosts(List<PostEntity> posts) {
    final shuffled = List<PostEntity>.from(posts);
    for (var i = shuffled.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }
}
