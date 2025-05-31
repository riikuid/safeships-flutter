import 'package:flutter/material.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/notification_model.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/theme.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  // Tentukan ikon dan warna berdasarkan reference_type
  Map<String, dynamic> _getIconAndColor() {
    if (notification.referenceType.startsWith('document')) {
      return {
        'icon': Icons.feed,
        'color': const Color(0xffD5ABA8),
      };
    } else if (notification.referenceType.startsWith('safety_patrol')) {
      return {
        'icon': Icons.forward_to_inbox,
        'color': const Color(0xffD6BB7F),
      };
    } else if (notification.referenceType.startsWith('safety_induction')) {
      return {
        'icon': Icons.badge_outlined,
        'color': const Color(0xffA4C0B6),
      };
    } else {
      // Default
      return {
        'icon': Icons.feed,
        'color': const Color(0xffD5ABA8),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconAndColor = _getIconAndColor();
    final timeAgo = AppHelper.getRelativeTime(notification.createdAt);

    return PrimaryButton(
      elevation: 0,
      onPressed: onTap,
      color: whiteColor,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: CircleAvatar(
                backgroundColor:
                    (iconAndColor['color'] as Color).withOpacity(0.2),
                child: Icon(
                  iconAndColor['icon'] as IconData,
                  size: 25,
                  color: iconAndColor['color'] as Color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: semibold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        timeAgo,
                        style: primaryTextStyle.copyWith(
                          fontSize: 10,
                          fontWeight: regular,
                          color: subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      fontWeight: regular,
                      color: subtitleTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
