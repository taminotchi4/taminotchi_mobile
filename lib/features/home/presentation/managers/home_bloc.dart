import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/datasources/home_media_picker.dart';
import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_comment_counts_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/get_current_user_id_usecase.dart';
import '../../domain/usecases/get_current_user_role_usecase.dart';
import '../../domain/usecases/get_post_by_id_usecase.dart';
import '../../domain/usecases/get_all_posts_usecase.dart';
import '../../domain/usecases/get_my_posts_usecase.dart';
import '../../domain/usecases/reply_to_comment_usecase.dart';
import '../../domain/usecases/update_post_status_usecase.dart';
import '../../domain/usecases/get_posts_by_category_usecase.dart';
import '../../domain/usecases/get_groups_by_category_usecase.dart';
import '../../domain/usecases/get_posts_by_group_usecase.dart';
import '../../domain/entities/group_entity.dart';
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
  final ReplyToCommentUseCase replyToCommentUseCase;
  final UpdatePostStatusUseCase updatePostStatusUseCase;
  final GetPostsByCategoryUseCase getPostsByCategoryUseCase;
  final GetGroupsByCategoryUseCase getGroupsByCategoryUseCase;
  final GetPostsByGroupUseCase getPostsByGroupUseCase;
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
    required this.replyToCommentUseCase,
    required this.updatePostStatusUseCase,
    required this.getPostsByCategoryUseCase,
    required this.getGroupsByCategoryUseCase,
    required this.getPostsByGroupUseCase,
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
    on<HomeReplyToComment>(_onReplyToComment);
    on<HomeUpdatePostStatus>(_onUpdatePostStatus);
    on<HomeUpdatePrice>(_onUpdatePrice);
    on<HomeUpdateAddress>(_onUpdateAddress);
    on<HomeFetchPostsByCategory>(_onFetchPostsByCategory);
    on<HomeFetchGroupsByCategory>(_onFetchGroupsByCategory);
    on<HomeFetchPostsByGroup>(_onFetchPostsByGroup);
    on<HomeRefresh>(_onRefresh);
    
    add(const HomeStarted());
  }

  Future<void> _onRefresh(HomeRefresh event, Emitter<HomeState> emit) async {
    await _onStarted(const HomeStarted(), emit, forceRefresh: true);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit, {bool forceRefresh = false}) async {
    // Immediately set all loading states before parallel execution
    emit(state.copyWith(
      isLoadingCategories: true,
      isLoadingPosts: true,
    ));

    try {
      // Parallelize fetches for improved performance
      final results = await Future.wait([
        _getUserData(),
        getCategoriesUseCase(forceRefresh: forceRefresh),
        getAllPostsUseCase(forceRefresh: forceRefresh),
        getMyPostsUseCase(forceRefresh: forceRefresh),
      ]);

      final userRes = results[0] as Map<String, dynamic>;
      final categoriesRes = results[1] as Result<List<PostCategoryEntity>>;
      final allPostsRes = results[2] as Result<List<PostEntity>>;
      final myPostsRes = results[3] as Result<List<PostEntity>>;

      final categories = categoriesRes.fold((_) => <PostCategoryEntity>[], (c) => c);
      final posts = allPostsRes.fold((_) => <PostEntity>[], (p) => p);
      final myPosts = myPostsRes.fold((_) => <PostEntity>[], (p) => p);

      final hasError = categoriesRes.isError || allPostsRes.isError;
      
      emit(state.copyWith(
        currentUserId: userRes['id'] as String,
        currentUserRole: userRes['role'] as UserRole,
        categories: categories,
        posts: posts,
        myPosts: myPosts,
        carouselPosts: _shufflePosts(posts),
        selectedCategory: state.selectedCategory ?? (categories.isEmpty ? null : categories.first),
        actionStatus: hasError ? HomeActionStatus.error : HomeActionStatus.initial,
        errorMessage: categoriesRes.isError ? categoriesRes.error.toString() : 
                      allPostsRes.isError ? allPostsRes.error.toString() : null,
      ));
    } catch (e) {
      debugPrint('❌ HomeBloc Error: $e');
      emit(state.copyWith(
        actionStatus: HomeActionStatus.error,
        errorMessage: e.toString(),
      ));
    } finally {
      emit(state.copyWith(
        isLoadingCategories: false,
        isLoadingPosts: false,
      ));
    }
    
    // Non-critical background task
    await _loadCommentCounts(emit);
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final idRes = await getCurrentUserIdUseCase();
    final roleRes = await getCurrentUserRoleUseCase();
    
    final Map<String, dynamic> data = {
      'id': idRes.fold((_) => '', (id) => id),
      'role': roleRes.fold((_) => UserRole.guest, (role) => role),
    };
    return data;
  }



  Future<void> _loadCommentCounts(Emitter<HomeState> emit) async {
    final result = await getCommentCountsUseCase();
    result.fold(
          (error) =>
          emit(state.copyWith(
            actionStatus: HomeActionStatus.error,
            errorMessage: error.toString(),
          )),
          (counts) => emit(state.copyWith(commentCounts: counts)),
    );
  }

  void _onExpandComposer(HomeExpandComposer event, Emitter<HomeState> emit) {
    if (state.currentUserRole != UserRole.guest) {
      if (state.isComposerExpanded) {
        emit(state.copyWith(isComposerExpanded: true));
      } else {
        emit(state.copyWith(
          isComposerExpanded: true,
          selectedCategory: null,
          selectedSubcategory: null,
          categoryError: null,
          subcategoryError: null,
          contentError: null,
        ));
      }
    } else {
      emit(state.copyWith(
        actionStatus: HomeActionStatus.authRequired,
      ));
    }
  }

  void _onCollapseComposer(HomeCollapseComposer event,
      Emitter<HomeState> emit) {
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

  void _onSelectSubcategory(HomeSelectSubcategory event,
      Emitter<HomeState> emit) {
    emit(state.copyWith(
      selectedSubcategory: event.subcategory,
      subcategoryError: null,
    ));
  }

  Future<void> _onAddImagesFromGallery(HomeAddImagesFromGallery event,
      Emitter<HomeState> emit,) async {
    final images = await mediaPicker.pickFromGallery();
    _mergeImages(images, emit);
  }

  Future<void> _onAddImageFromCamera(HomeAddImageFromCamera event,
      Emitter<HomeState> emit,) async {
    final image = await mediaPicker.pickFromCamera();
    if (image != null) {
      _mergeImages([image], emit);
    }
  }

  Future<void> _onAddImagesFromFiles(HomeAddImagesFromFiles event,
      Emitter<HomeState> emit,) async {
    final images = await mediaPicker.pickFromFiles();
    _mergeImages(images, emit);
  }

  void _mergeImages(List<PostImageEntity> images, Emitter<HomeState> emit) {
    final updated = [...state.selectedImages];
    String? sizeError;

    for (final image in images) {
      if (updated.length >= maxImages) break;
      if (updated.any((item) => item.path == image.path)) continue;

      final file = File(image.path);
      if (file.existsSync()) {
        final sizeInBytes = file.lengthSync();
        if (sizeInBytes > 5 * 1024 * 1024) {
          sizeError = 'Rasm hajmi 5MB dan oshmasligi kerak';
          continue;
        }
      }

      updated.add(image);
    }

    emit(state.copyWith(
      selectedImages: updated,
      errorMessage: sizeError,
      actionStatus: sizeError != null ? HomeActionStatus.error : state
          .actionStatus,
    ));
  }

  void _onRemoveImage(HomeRemoveImage event, Emitter<HomeState> emit) {
    final updated =
    state.selectedImages.where((e) => e.path != event.path).toList();
    emit(state.copyWith(selectedImages: updated));
  }

  Future<void> _onCreatePost(HomeCreatePost event,
      Emitter<HomeState> emit,) async {
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
      contentError =
      'Qidirayotgan maxsulotingiz haqida batafsil ma\'lumot yozishingiz kerak';
    }

    if (categoryError != null || subcategoryError != null ||
        contentError != null) {
      emit(state.copyWith(
        categoryError: categoryError,
        subcategoryError: subcategoryError,
        contentError: contentError,
      ));
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    final result = await createPostUseCase(
      content: content,
      images: state.selectedImages,
      category: category!,
      price: state.price,
      adressname: state.adressname,
      supCategoryId: subcategory?.id,
    );
    await result.fold(
          (error) async =>
          emit(state.copyWith(
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
          price: '',
          adressname: '',
        ));
      },
    );
  }

  Future<void> _onLoadPostDetails(HomeLoadPostDetails event,
      Emitter<HomeState> emit,) async {
    emit(state.copyWith(isLoadingDetails: true));
    final postResult = await getPostByIdUseCase(event.postId);
    final commentsResult = await getCommentsUseCase(event.postId);

    postResult.fold(
          (error) =>
          emit(state.copyWith(
            isLoadingDetails: false,
            actionStatus: HomeActionStatus.error,
            errorMessage: error.toString(),
          )),
          (post) {
        commentsResult.fold(
              (commentError) =>
              emit(state.copyWith(
                isLoadingDetails: false,
                actionStatus: HomeActionStatus.error,
                errorMessage: commentError.toString(),
              )),
              (comments) =>
              emit(state.copyWith(
                isLoadingDetails: false,
                activePost: post,
                activeComments: comments,
              )),
        );
      },
    );
  }

  void _onClearActionStatus(HomeClearActionStatus event,
      Emitter<HomeState> emit,) {
    emit(state.copyWith(actionStatus: HomeActionStatus.initial));
  }

  void _onClearContentError(HomeClearContentError event,
      Emitter<HomeState> emit,) {
    emit(state.copyWith(contentError: null));
  }

  Future<void> _onReplyToComment(HomeReplyToComment event,
      Emitter<HomeState> emit,) async {
    final result = await replyToCommentUseCase(
      postId: event.postId,
      parentCommentId: event.parentCommentId,
      content: event.content,
    );

    result.fold(
          (error) =>
          emit(state.copyWith(
            actionStatus: HomeActionStatus.error,
            errorMessage: error.toString(),
          )),
          (_) {
        add(HomeLoadPostDetails(event.postId));
      },
    );
  }

  Future<void> _onUpdatePostStatus(HomeUpdatePostStatus event,
      Emitter<HomeState> emit,) async {
    final result = await updatePostStatusUseCase(
      postId: event.postId,
      status: event.status,
    );

    result.fold(
          (error) =>
          emit(state.copyWith(
            actionStatus: HomeActionStatus.error,
            errorMessage: error.toString(),
          )),
          (_) {
        add(const HomeStarted());
        add(HomeLoadPostDetails(event.postId));
      },
    );
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

  void _onUpdatePrice(HomeUpdatePrice event, Emitter<HomeState> emit) {
    emit(state.copyWith(price: event.price));
  }

  void _onUpdateAddress(HomeUpdateAddress event, Emitter<HomeState> emit) {
    emit(state.copyWith(adressname: event.address));
  }

  Future<void> _onFetchPostsByCategory(HomeFetchPostsByCategory event,
      Emitter<HomeState> emit,) async {
    final result = await getPostsByCategoryUseCase(event.categoryId);
    result.fold(
          (error) =>
          emit(state.copyWith(
            actionStatus: HomeActionStatus.error,
            errorMessage: error.toString(),
          )),
          (posts) {
        final updatedPosts = List<PostEntity>.from(state.posts);
        updatedPosts.removeWhere((p) =>
        p.category.id == event.categoryId ||
            p.category.parentId == event.categoryId
        );
        updatedPosts.addAll(posts);

        emit(state.copyWith(posts: updatedPosts));
      },
    );
    add(HomeFetchGroupsByCategory(event.categoryId));
  }

  Future<void> _onFetchGroupsByCategory(HomeFetchGroupsByCategory event,
      Emitter<HomeState> emit,) async {
    emit(state.copyWith(isLoadingGroups: true));
    final result = await getGroupsByCategoryUseCase(event.categoryId);
    result.fold(
          (error) =>
          emit(state.copyWith(
            isLoadingGroups: false,
            groupError: error.toString(),
          )),
          (groups) {
        final updatedCategoryGroups = Map<String, List<GroupEntity>>.from(
            state.categoryGroups);
        updatedCategoryGroups[event.categoryId] = groups;
        emit(state.copyWith(
          isLoadingGroups: false,
          categoryGroups: updatedCategoryGroups,
        ));
      },
    );
  }

  Future<void> _onFetchPostsByGroup(HomeFetchPostsByGroup event,
      Emitter<HomeState> emit,) async {
    final result = await getPostsByGroupUseCase(event.groupId);
    result.fold(
          (error) =>
          emit(state.copyWith(
            actionStatus: HomeActionStatus.error,
            errorMessage: error.toString(),
          )),
          (posts) {
        final updatedPosts = List<PostEntity>.from(state.posts);
        updatedPosts.removeWhere((p) =>
            p.groups.any((g) => g.id == event.groupId));
        updatedPosts.addAll(posts);

        emit(state.copyWith(posts: updatedPosts));
      },
    );
  }
}
