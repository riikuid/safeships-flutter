import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/category_with_doc_model.dart';
import 'package:safeships_flutter/presentation/pages/document/pengajuan_document_page.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/theme.dart';

class CategoryWithDocsCard extends StatelessWidget {
  final CategoryWithDocModel category;
  final Function(int) onTapDoc;
  final Function(int, int) onDeleteDoc; // New callback for deleting a document
  final Function(int) onDeleteCategory; // New callback for deleting a category

  const CategoryWithDocsCard({
    super.key,
    required this.category,
    required this.onTapDoc,
    required this.onDeleteDoc,
    required this.onDeleteCategory,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                    color: primaryColor400,
                  ),
                  child: Text(
                    category.code,
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: whiteColor,
                      fontWeight: semibold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  category.name,
                  style: primaryTextStyle.copyWith(
                    fontSize: 12,
                    color: subtitleTextColor,
                    fontWeight: semibold,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: greyBackgroundColor.withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: category.items.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada dokumentasi untuk kategori ini',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              color: subtitleTextColor,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: category.items.length,
                          itemBuilder: (context, index) {
                            final doc = category.items[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 5,
                                right: 0,
                              ),
                              leading: Icon(
                                AppHelper.getFileIcon(doc.filePath),
                                color: primaryColor900,
                                size: 20,
                              ),
                              onTap: () {
                                onTapDoc(doc.id);
                              },
                              title: Text(
                                doc.title,
                                style: primaryTextStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: semibold,
                                  color: primaryColor900,
                                ),
                              ),
                              trailing: (context
                                          .read<AuthProvider>()
                                          .user
                                          .role ==
                                      'super_admin')
                                  ? PopupMenuButton<String>(
                                      splashRadius: 1,
                                      elevation: 2,
                                      padding: EdgeInsets.zero,
                                      color: whiteColor,
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: subtitleTextColor,
                                        size: 18,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'hapus') {
                                          onDeleteDoc(doc.id, category.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'hapus',
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.delete,
                                                color: Color(0xfff94449),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Hapus',
                                                style:
                                                    primaryTextStyle.copyWith(
                                                  fontSize: 12,
                                                  color: Color(0xfff94449),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton<String>(
          splashRadius: 1,
          elevation: 2,
          padding: EdgeInsets.zero,
          color: whiteColor,
          icon: Icon(
            Icons.more_vert,
            color: subtitleTextColor,
            size: 18,
          ),
          onSelected: (value) {
            if (value == 'ajukan') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PengajuanDocumentPage(
                    parentModel: category,
                  ),
                ),
              );
            } else if (value == 'hapus') {
              onDeleteCategory(category.id);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'ajukan',
              child: Row(
                children: [
                  Icon(
                    Icons.add_box_rounded,
                    color: subtitleTextColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ajukan Dokumentasi',
                    style: primaryTextStyle.copyWith(
                      fontSize: 12,
                      color: subtitleTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (context.read<AuthProvider>().user.role == 'super_admin')
              PopupMenuItem(
                value: 'hapus',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete,
                      color: Color(0xfff94449),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hapus Semua Dokumentasi',
                      style: primaryTextStyle.copyWith(
                        fontSize: 12,
                        color: Color(0xfff94449),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
