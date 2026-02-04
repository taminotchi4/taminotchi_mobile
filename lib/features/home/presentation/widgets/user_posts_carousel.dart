import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/measure_size.dart';
import '../../domain/entities/post_entity.dart';
import 'post_card.dart';

class UserPostsCarousel extends StatefulWidget {
  final List<PostEntity> posts;
  final Map<String, int> commentCounts;

  const UserPostsCarousel({
    super.key,
    required this.posts,
    required this.commentCounts,
  });

  @override
  State<UserPostsCarousel> createState() => _UserPostsCarouselState();
}

class _UserPostsCarouselState extends State<UserPostsCarousel> {
  static const Duration _autoScrollInterval = Duration(seconds: 3);
  static const Duration _autoScrollDuration = Duration(milliseconds: 300);
  late final PageController _controller;
  Timer? _timer;
  int _currentIndex = 0;
  double _currentHeight = AppDimens.carouselHeight.h;
  final Map<int, double> _itemHeights = {};

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant UserPostsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posts.length != widget.posts.length) {
      _currentIndex = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppDimens.lg.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Text(
          'Sizning postlaringiz hozircha yoq',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      );
    }

    return SizedBox(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: SizedBox(
          height: _currentHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.posts.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _currentHeight = _itemHeights[index] ?? _currentHeight;
              });
            },
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              final commentCount = widget.commentCounts[post.id] ?? 0;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.xs.w),
                child: MeasureSize(
                  onChange: (size) {
                    if (!mounted) return;
                    _itemHeights[index] = size.height;
                    if (_currentIndex == index) {
                      setState(() {
                        _currentHeight = _itemHeights[index]!;
                      });
                    }
                  },
                  child: PostCard(
                    post: post,
                    commentCount: commentCount,
                    onTap: () => context.push(Routes.getPostDetail(post.id)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    if (widget.posts.length < 2) return;
    _timer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || widget.posts.isEmpty || !_controller.hasClients) return;
      _currentIndex = (_currentIndex + 1) % widget.posts.length;
      _controller.animateToPage(
        _currentIndex,
        duration: _autoScrollDuration,
        curve: Curves.easeOut,
      );
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }
}
