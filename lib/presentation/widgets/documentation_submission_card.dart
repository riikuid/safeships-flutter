import 'package:flutter/material.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/document_model.dart';
import 'package:safeships_flutter/presentation/pages/document/detail_document_page.dart';
import 'package:safeships_flutter/theme.dart';

class DocumentationSubmissionCard extends StatelessWidget {
  final DocumentModel doc;
  const DocumentationSubmissionCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailDocumentPage(
            viewMode: DocumentViewMode.mySubmission,
            userId: 0, // Not used in view-only mode
            doc: doc,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          border: Border(
            left: BorderSide(
              width: 5.0,
              color: AppHelper.getColorBasedOnStatus(doc.status),
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
                    doc.category.code,
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
            const SizedBox(height: 10),
            Text(
              doc.title,
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Submitted at: ${AppHelper.formatDateToString(doc.createdAt)}',
              style: primaryTextStyle.copyWith(
                color: subtitleTextColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Last Updated: ${AppHelper.formatDateToString(doc.updatedAt)}',
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
