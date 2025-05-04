import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/widgets/category_card.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class ListCategoryPage extends StatefulWidget {
  const ListCategoryPage({super.key});

  @override
  State<ListCategoryPage> createState() => _ListCategoryPageState();
}

class _ListCategoryPageState extends State<ListCategoryPage> {
  late Future<void> futureGetCategories;
  late DocumentProvider documentProvider;
  String errorText = "Gagal mendapatkan kategori dokumentasi";

  @override
  void initState() {
    super.initState();

    // Initialize documentProvider in initState to ensure context is available
    documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    futureGetCategories = getCategories();
  }

  Future<void> getCategories() async {
    await documentProvider.getCategories(
      errorCallback: (p0) => setState(() {
        errorText = p0;
      }),
    );
  }

  String searchKeyword = '';
  TextEditingController searchController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: whiteColor,
        ),
        surfaceTintColor: transparentColor,
        backgroundColor: primaryColor500,
        title: Text(
          'Dokumentasi K3',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semibold,
            color: whiteColor,
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   elevation: 2,
      //   backgroundColor: primaryColor800,
      //   onPressed: () {},
      //   icon: Icon(
      //     Icons.assignment_add,
      //     size: 20.0,
      //     color: whiteColor,
      //   ),
      //   label: Text(
      //     'FORM DOKUMENTASI',
      //     style: primaryTextStyle.copyWith(
      //       fontSize: 12,
      //       color: whiteColor,
      //       fontWeight: semibold,
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextFormField(
              // controller: searchController,
              // selectionHeightStyle: BoxHeightStyle.tight,
              style: primaryTextStyle.copyWith(),
              cursorColor: primaryColor500,
              onChanged: (value) {
                setState(() {
                  searchKeyword = value;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(),
                hintText: 'Cari Kategori Dokumentasi',
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
                    )),
              ),
            ), // Replace with actual SearchBar widget if needed
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
                      if (documentProvider.categories.isEmpty) {
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: documentProvider.categories
                                .map(
                              (category) => CategoryCard(
                                category: category,
                              ),
                            )
                                .where(
                              (item) {
                                final parentMatch = item.category.name
                                    .toLowerCase()
                                    .contains(searchKeyword.toLowerCase());
                                final childrenMatch =
                                    item.category.children?.any(
                                          (child) => child.name
                                              .toLowerCase()
                                              .contains(
                                                  searchKeyword.toLowerCase()),
                                        ) ??
                                        false;
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
    );
  }
}
