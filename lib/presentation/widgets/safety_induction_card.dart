import 'package:flutter/material.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/safety_induction/induction_card_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_card_model.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyInductionCard extends StatelessWidget {
  final InductionCardModel induction;

  final VoidCallback onTap;

  const SafetyInductionCard({
    super.key,
    required this.onTap,
    required this.induction,
  });

  @override
  Widget build(BuildContext context) {
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
          color: whiteColor,
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
                    color: primaryColor50,
                  ),
                  child: Text(
                    induction.type.toUpperCase(),
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
                      color: AppHelper.getColorBasedOnStatus(induction.status),
                    ),
                    color: AppHelper.getColorBasedOnStatus(induction.status)
                        .withOpacity(0.1),
                  ),
                  child: Text(
                    induction.status.replaceAll('_', ' ').toUpperCase(),
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: AppHelper.getColorBasedOnStatus(induction.status),
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
              induction.name,
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              AppHelper.formatDateToString(induction.createdAt),
              style: primaryTextStyle.copyWith(
                color: subtitleTextColor,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
