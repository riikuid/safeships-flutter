import 'package:flutter/material.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_card_model.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyPatrolApprovalCard extends StatelessWidget {
  final SafetyPatrolCardModel patrol;
  final int userId;
  final VoidCallback onTap;

  const SafetyPatrolApprovalCard({
    super.key,
    required this.patrol,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String approval = patrol.userApprovalStatus!.replaceAll('_', ' ');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: (approval == 'pending' &&
                  patrol.status != 'done' &&
                  patrol.status != 'rejected')
              ? whiteColor
              : disabledColor.withOpacity(0.4),
          borderRadius: const BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    border: Border.all(
                      width: 0.5,
                      color: primaryColor500,
                    ),
                    color: primaryColor50.withOpacity(0.5),
                  ),
                  child: Text(
                    patrol.type.toUpperCase(),
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: primaryColor500,
                      fontWeight: semibold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    border: Border.all(
                      width: 0.5,
                      color: AppHelper.getColorBasedOnStatus(patrol.status),
                    ),
                    color: AppHelper.getColorBasedOnStatus(patrol.status)
                        .withOpacity(0.1),
                  ),
                  child: Text(
                    patrol.status.replaceAll('_', ' ').toUpperCase(),
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: AppHelper.getColorBasedOnStatus(patrol.status),
                      fontWeight: semibold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              patrol.location,
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              patrol.description,
              style: primaryTextStyle.copyWith(
                color: subtitleTextColor,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Disubmit pada: ${AppHelper.formatDateToString(patrol.createdAt)}',
              style: primaryTextStyle.copyWith(
                color: subtitleTextColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text(
                  'Status anda: ',
                  style: primaryTextStyle.copyWith(
                    color: subtitleTextColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  approval.toUpperCase(),
                  style: primaryTextStyle.copyWith(
                    color: AppHelper.getColorBasedOnStatus(approval),
                    fontSize: 12,
                    fontWeight: semibold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
