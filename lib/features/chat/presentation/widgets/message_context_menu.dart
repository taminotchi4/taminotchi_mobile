import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taminotchi_app/core/utils/colors.dart';
import 'package:taminotchi_app/core/utils/styles.dart';
import '../../domain/entities/chat_message_entity.dart';

enum MessageAction { reply, edit, copy, forward, delete, select }

class MessageContextMenu extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMine;
  final Function(MessageAction) onAction;

  final BorderRadius? borderRadius;

  const MessageContextMenu({
    super.key,
    required this.message,
    required this.isMine,
    required this.onAction,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      width: 220.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(
            icon: Icons.reply,
            text: "Javob yozish",
            action: MessageAction.reply,
            color: AppColors.black,
          ),
          if (isMine && message.type == ChatMessageType.text)
            _buildItem(
              icon: Icons.edit,
              text: "Taxrirlash",
              action: MessageAction.edit,
              color: AppColors.black,
            ),
          if (message.type == ChatMessageType.text)
            _buildItem(
              icon: Icons.copy,
              text: "Nusxalash",
              action: MessageAction.copy,
              color: AppColors.black,
            ),
          _buildItem(
            icon: Icons.forward,
            text: "Uzatish",
            action: MessageAction.forward,
            color: AppColors.black,
          ),
          Divider(color: Colors.grey.withOpacity(0.2)),
          _buildItem(
            icon: Icons.check_circle_outline,
            text: "Tanlash",
            action: MessageAction.select,
            color: AppColors.black,
          ),
          _buildItem(
            icon: Icons.delete_outline,
            text: "O'chirish",
            action: MessageAction.delete,
            color: Colors.red,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String text,
    required MessageAction action,
    required Color color,
  }) {
    return InkWell(
      onTap: () => onAction(action),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 16.w),
            Text(
              text,
              style: AppStyles.bodyMedium.copyWith(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
