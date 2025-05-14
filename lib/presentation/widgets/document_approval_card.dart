import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/auth_model.dart';
import 'package:safeships_flutter/models/document_model.dart';
import 'package:safeships_flutter/presentation/pages/approval/detail_document_approval_page.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/theme.dart';

class DocumentApprovalCard extends StatelessWidget {
  final DocumentModel doc;
  final int userId;
  const DocumentApprovalCard(
      {super.key, required this.doc, required this.userId});

  @override
  Widget build(BuildContext context) {
    String approval = doc.documentApprovals!
        .firstWhere(
          (approval) => approval.approverId == userId,
        )
        .status;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailDocumentApprovalPage(
              isViewOnly: false,
              userId: userId,
              doc: doc,
            ),
          )),
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
          border: Border(
              left: BorderSide(
            width: 5.0,
            color: AppHelper.getColorBasedOnStatus(approval),
          )),
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
                    doc.category.code,
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
                      color: AppHelper.getColorBasedOnStatus(doc.status),
                    ),
                    color: AppHelper.getColorBasedOnStatus(doc.status)
                        .withOpacity(0.1),
                  ),
                  child: Text(
                    doc.status.replaceAll('_', ' ').toUpperCase(),
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: AppHelper.getColorBasedOnStatus(doc.status),
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
              doc.title,
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Submitted at: ${AppHelper.formatDateToString(doc.createdAt)}',
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
                  'Approval by You: ',
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
