import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class ApprovalDocumentPage extends StatefulWidget {
  const ApprovalDocumentPage({super.key});

  @override
  State<ApprovalDocumentPage> createState() => _ApprovalDocumentPageState();
}

class _ApprovalDocumentPageState extends State<ApprovalDocumentPage> {
  late Future<void> futureGetDocuments;
  late DocumentProvider documentProvider;
  String errorText = "Gagal mendapatkan kategori dokumentasi";

  @override
  void initState() {
    super.initState();

    // Initialize documentProvider in initState to ensure context is available
    documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    futureGetDocuments = getDocuments();
  }

  Future<void> getDocuments() async {
    await documentProvider.getDocumentManagerial(
      errorCallback: (p0) => setState(() {
        errorText = p0;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Approvals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: futureGetDocuments,
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
                      if (documentProvider.documentsManagerial.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ada dokumen yg perlu disetujui',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                            ),
                          ),
                        );
                      } else {
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              futureGetDocuments = getDocuments();
                            });
                          },
                          color: primaryColor500,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: documentProvider.documentsManagerial
                                .map(
                                  (doc) => ListTile(
                                    title: Text(doc.title),
                                    subtitle: Text(doc.status),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      onPressed: () {
                                        // Implement approval logic
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Approved Document ')),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                // .where(
                                //   (item) =>
                                //       item.category.name.toLowerCase().contains(
                                //             searchKeyword.toLowerCase(),
                                //           ),
                                // )
                                .toList(),
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
