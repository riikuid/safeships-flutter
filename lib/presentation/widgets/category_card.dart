// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/presentation/pages/document/list_document_page.dart';
import 'package:safeships_flutter/theme.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${category.name}',
              style: primaryTextStyle.copyWith(
                fontSize: 16,
                color: subtitleTextColor,
                fontWeight: semibold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: greyBackgroundColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => Divider(),
                itemCount:
                    category.children != null ? category.children!.length : 0,
                itemBuilder: (context, index) {
                  // log('ID CATEGORY: ${category.children![index].id}');
                  return ListTile(
                    leading: Icon(
                      Icons.folder,
                      color: primaryColor300,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListDocumentPage(
                                category: category.children![index]),
                          ));
                    },
                    title: Text(
                      '${category.children![index].code} ${category.children![index].name}',
                      style: primaryTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: semibold,
                        color: primaryColor900,
                      ),
                    ),
                  );
                },
                // children: category.children != null
                //     ? category.children!.map(
                //         (e) {
                //           return ListTile(
                //             leading: Icon(
                //               Icons.folder,
                //               color: primaryColor300,
                //             ),
                //             onTap: () {
                //               print('coba');
                //             },
                //             title: Text(
                //               e.name,
                //               style: primaryTextStyle.copyWith(
                //                 fontSize: 12,
                //                 fontWeight: semibold,
                //                 color: primaryColor900,
                //               ),
                //             ),
                //           );
                //         },
                //       ).toList()
                //     : [],
              ),
            )
          ],
        ),
      ),
    );
  }
}
