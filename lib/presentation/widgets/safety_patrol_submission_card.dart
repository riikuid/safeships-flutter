import 'package:flutter/material.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyPatrolSubmissionCard extends StatelessWidget {
  final SafetyPatrolModel patrol;
  const SafetyPatrolSubmissionCard({super.key, required this.patrol});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapped on patrol: ${patrol.location}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          border: Border(
            left: BorderSide(
              width: 5.0,
              color: AppHelper.getColorBasedOnStatus(
                  patrol.status.toString().split('.').last),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                    border: Border.all(width: 0.5, color: primaryColor500),
                    color: primaryColor50,
                  ),
                  child: Text(
                    patrol.type.toString().split('.').last.toUpperCase(),
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: primaryColor500,
                      fontWeight: semibold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                    border: Border.all(
                      width: 0.5,
                      color: AppHelper.getColorBasedOnStatus(
                          patrol.status.toString().split('.').last),
                    ),
                    color: AppHelper.getColorBasedOnStatus(
                            patrol.status.toString().split('.').last)
                        .withOpacity(0.1),
                  ),
                  child: Text(
                    patrol.status
                        .toString()
                        .split('.')
                        .last
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: AppHelper.getColorBasedOnStatus(
                          patrol.status.toString().split('.').last),
                      fontWeight: semibold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              patrol.location,
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              patrol.description,
              style: primaryTextStyle.copyWith(
                color: subtitleTextColor,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              'Submitted at: ${AppHelper.formatDateToString(patrol.createdAt)}',
              style: primaryTextStyle.copyWith(
                color: subtitleTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
