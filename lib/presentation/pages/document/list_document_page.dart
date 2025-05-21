import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/models/document_model.dart';
import 'package:safeships_flutter/presentation/pages/document/detail_document_page.dart';
import 'package:safeships_flutter/presentation/widgets/category_with_docs_card.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class ListDocumentPage extends StatefulWidget {
  final CategoryModel category;
  const ListDocumentPage({super.key, required this.category});

  @override
  State<ListDocumentPage> createState() => _ListDocumentPageState();
}

class _ListDocumentPageState extends State<ListDocumentPage> {
  bool _isLoading = false;
  late Future<void> futureGetCategories;
  late DocumentProvider documentProvider;
  String errorText = "Gagal mendapatkan kategori dokumentasi";

  @override
  void initState() {
    super.initState();
    documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    futureGetCategories = getCategories();
  }

  Future<void> getCategories() async {
    await documentProvider.getCategoriesWithDocs(
      categoryId: widget.category.id,
      errorCallback: (p0) => setState(() {
        errorText = p0;
      }),
    );
  }

  String searchKeyword = '';
  TextEditingController searchController = TextEditingController(text: '');

  Future<void> onDeleteDoc(int documentId, int categoryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: primaryTextStyle.copyWith(fontWeight: semibold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus dokumen ini?',
          style: primaryTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: primaryTextStyle.copyWith(color: redLableColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor500,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: primaryTextStyle.copyWith(color: whiteColor),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      final success = await documentProvider.deleteDocument(
        documentId: documentId,
        categoryId: categoryId,
        onSuccess: () {
          Fluttertoast.showToast(msg: 'Dokumen berhasil dihapus');
        },
        onError: (error) {
          Fluttertoast.showToast(msg: error.toString());
        },
      );
      setState(() {
        _isLoading = false;
      });
      if (!success) {
        Fluttertoast.showToast(msg: 'Gagal menghapus dokumen');
      }
    }
  }

  Future<void> onDeleteCategory(int categoryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: primaryTextStyle.copyWith(fontWeight: semibold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua dokumen di kategori ini?',
          style: primaryTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: primaryTextStyle.copyWith(color: redLableColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor500,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: primaryTextStyle.copyWith(color: whiteColor),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      final success = await documentProvider.deleteDocumentsByCategory(
        categoryId: categoryId,
        onSuccess: () {
          Fluttertoast.showToast(
              msg: 'Semua dokumen pada kategori berhasil dihapus');
        },
        onError: (error) {
          Fluttertoast.showToast(msg: error.toString());
        },
      );
      setState(() {
        _isLoading = false;
      });
      if (!success) {
        Fluttertoast.showToast(msg: 'Gagal menghapus dokumen kategori');
      } else {
        // Navigasi kembali karena kategori sudah dihapus
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: whiteColor,
            ),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              '${widget.category.code} ${widget.category.name}',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: TextFormField(
                  style: primaryTextStyle.copyWith(),
                  cursorColor: primaryColor500,
                  onChanged: (value) {
                    setState(() {
                      searchKeyword = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(),
                    hintText: 'Cari Dokumentasi K3',
                    hintStyle: primaryTextStyle.copyWith(
                      color: hintTextColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide(
                        color: hintTextColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide(
                        color: blackColor,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxHeight: 22,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12.0, right: 8),
                      child: Icon(
                        Icons.search,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: futureGetCategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 3,
                        itemBuilder: (context, index) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 10),
                            color: Colors.grey,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          errorText,
                          style: primaryTextStyle.copyWith(
                            color: subtitleTextColor,
                          ),
                        ),
                      );
                    } else {
                      return Consumer<DocumentProvider>(
                        builder: (context, documentProvider, _) {
                          if (documentProvider.categoryWithDocs.isEmpty) {
                            return Center(
                              child: Text(
                                'Tidak ada kategori',
                                style: primaryTextStyle.copyWith(
                                  color: subtitleTextColor,
                                ),
                              ),
                            );
                          } else {
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  futureGetCategories = getCategories();
                                });
                              },
                              color: primaryColor500,
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                children: documentProvider.categoryWithDocs
                                    .map(
                                  (category) => CategoryWithDocsCard(
                                    onTapDoc: (docId) async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      DocumentModel selectedDoc =
                                          await documentProvider.showDocuments(
                                        documentId: docId,
                                        errorCallback: (p0) {
                                          Fluttertoast.showToast(
                                              msg: p0.toString());
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        },
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailDocumentPage(
                                            doc: selectedDoc,
                                            userId: 0,
                                            viewMode: DocumentViewMode.public,
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
                                    onDeleteDoc: onDeleteDoc,
                                    onDeleteCategory: onDeleteCategory,
                                    category: category,
                                  ),
                                )
                                    .where(
                                  (item) {
                                    final parentMatch = item.category.name
                                        .toLowerCase()
                                        .contains(searchKeyword.toLowerCase());
                                    final childrenMatch =
                                        item.category.items.any(
                                      (child) => child.title
                                          .toLowerCase()
                                          .contains(
                                              searchKeyword.toLowerCase()),
                                    );
                                    return parentMatch || childrenMatch;
                                  },
                                ).toList(),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          ColoredBox(
            color: blackColor.withOpacity(0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
