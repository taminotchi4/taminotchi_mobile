import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/post_entity.dart';
import 'post_card.dart';

class UserPostsCarousel extends StatefulWidget {
  final List<PostEntity> posts;

  const UserPostsCarousel({super.key, required this.posts});

  @override
  State<UserPostsCarousel> createState() => _UserPostsCarouselState();
}

class _UserPostsCarouselState extends State<UserPostsCarousel> {
  static const Duration _autoScrollInterval = Duration(seconds: 3);
  static const Duration _autoScrollDuration = Duration(milliseconds: 300);
  late final PageController _controller;
  Timer? _timer;
  int _currentIndex = 0;

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

    // Determine height based on whether any post in the carousel has an image
    // To keep carousel height consistent
    final hasImages = widget.posts.any((p) => p.images.isNotEmpty);
    final carouselHeight = hasImages ? 400.h : 200.h;

    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.posts.length,
        onPageChanged: (index) => _currentIndex = index,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.xs.w),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: PostCard(
                post: post,
                commentCount: post.content.length,
                onTap: () => context.push(Routes.getPostDetail(post.id)),
              ),
            ),
          );
        },
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
