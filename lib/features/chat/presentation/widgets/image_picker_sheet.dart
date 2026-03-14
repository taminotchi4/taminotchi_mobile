import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../data/services/gallery_service.dart';
import '../managers/chat_bloc.dart';
import '../managers/chat_event.dart';
import '../managers/chat_state.dart';

class ChatImagePickerSheet extends StatefulWidget {
  final GalleryService galleryService;

  const ChatImagePickerSheet({super.key, required this.galleryService});

  @override
  State<ChatImagePickerSheet> createState() => _ChatImagePickerSheetState();
}

class _ChatImagePickerSheetState extends State<ChatImagePickerSheet> {
  List<File> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final images = await widget.galleryService.getRecentImages(count: 50);
    if (mounted) {
      setState(() {
        _images = images;
        _isLoading = false;
      });
    }
  }

  void _pickFromCamera() async {
    final file = await widget.galleryService.pickFromCamera();
    if (file != null && mounted) {
      // Camera picks usually add single image and return?
      // Or we can add to selection.
      // Let's add to selection.
      context.read<ChatBloc>().add(ChatAddSelectedImage(file.path));
      // For camera, user usually wants to snap and go.
      // We can pop or keep open. Let's keep open to match flow, or pop.
      // Telegram pops on camera use usually?
      // Let's just add to selection for consistency with grid value.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppDimens.lg.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rasm tanlang",
                      style: AppStyles.h4Bold.copyWith(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Row(
                      children: [
                        if (state.selectedImages.isNotEmpty)
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child:
                                Text("Add (${state.selectedImages.length})"),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: EdgeInsets.all(8.r),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _images.length + 1,
                        itemBuilder: (ctx, index) {
                          if (index == 0) {
                            return InkWell(
                              onTap: _pickFromCamera,
                              child: Container(
                                color: Theme.of(context).dividerColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            );
                          }
                          final image = _images[index - 1];
                          final isSelected =
                              state.selectedImages.contains(image.path);
                          final selectionIndex =
                              state.selectedImages.indexOf(image.path) + 1;

                          return InkWell(
                            onTap: () {
                              if (isSelected) {
                                context
                                    .read<ChatBloc>()
                                    .add(ChatRemoveSelectedImage(image.path));
                              } else {
                                context
                                    .read<ChatBloc>()
                                    .add(ChatAddSelectedImage(image.path));
                              }
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(image, fit: BoxFit.cover),
                                if (isSelected)
                                  Container(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: EdgeInsets.all(6.r),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    width: 24.w,
                                    height: 24.w,
                                    child: isSelected
                                        ? Center(
                                            child: Text(
                                              "$selectionIndex",
                                              style: AppStyles.bodySmall.copyWith(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      },
    );
  }
}
