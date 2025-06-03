import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_detail_page.dart';
import 'package:safeships_flutter/presentation/widgets/documentation_submission_card.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class MySafetyInductionPage extends StatefulWidget {
  const MySafetyInductionPage({super.key});

  @override
  State<MySafetyInductionPage> createState() =>
      _MyDocumentationSubmissionsPageState();
}

class _MyDocumentationSubmissionsPageState
    extends State<MySafetyInductionPage> {
  late Future<void> futureGetSubmissions;
  late SafetyInductionProvider documentProvider;
  String errorText = "Gagal mendapatkan dokumen Anda";

  @override
  void initState() {
    super.initState();
    documentProvider =
        Provider.of<SafetyInductionProvider>(context, listen: false);
    futureGetSubmissions = getSubmissions();
  }

  Future<void> getSubmissions() async {
    await documentProvider.getMySubmissions(
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
          Expanded(
            child: FutureBuilder(
              future: futureGetSubmissions,
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
                  return Consumer<SafetyInductionProvider>(
                    builder: (context, documentProvider, _) {
                      if (documentProvider.mySubmissions.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ada safety induction yang diajukan',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                            ),
                          ),
                        );
                      } else {
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              futureGetSubmissions = getSubmissions();
                            });
                          },
                          color: primaryColor500,
                          child: ListView(
                            children: documentProvider.mySubmissions
                                .map(
                                  (induction) => ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SafetyInductionDetailPage(),
                                          ));
                                    },
                                    title: Text(
                                      induction.name,
                                    ),
                                    subtitle: Text(induction.status),
                                  ),
                                )
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
