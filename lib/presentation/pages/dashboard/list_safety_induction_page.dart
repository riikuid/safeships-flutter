import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/detail_induction_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_result_page.dart';
import 'package:safeships_flutter/presentation/widgets/safety_induction_card.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class ListSafetyInductionPage extends StatefulWidget {
  const ListSafetyInductionPage({super.key});

  @override
  State<ListSafetyInductionPage> createState() =>
      _ListSafetyInductionPageState();
}

class _ListSafetyInductionPageState extends State<ListSafetyInductionPage> {
  late Future<void> futureGetPatrols;
  late SafetyInductionProvider safetyInductionProvider;
  String errorText = "Gagal mendapatkan laporan safety induction";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    safetyInductionProvider =
        Provider.of<SafetyInductionProvider>(context, listen: false);
    futureGetPatrols = getPatrols();
  }

  Future<void> getPatrols() async {
    await safetyInductionProvider.getAll(
      errorCallback: (p0) => setState(() {
        errorText = p0;
      }),
    );
  }

  Future<void> _navigateToDetail(int inductionId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final induction = await safetyInductionProvider.showInduction(
        inductionId: inductionId,
        errorCallback: (p0) {
          Fluttertoast.showToast(msg: p0.toString());
        },
      );

      // Tentukan view mode

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailInductionPage(
            induction: induction,
          ),
        ),
      );
    } catch (e) {
      // Error ditangani oleh errorCallback
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: greyBackgroundColor,
          appBar: AppBar(
            iconTheme: IconThemeData(color: whiteColor),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              'List Safety Induction',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder(
                  future: futureGetPatrols,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
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
                        builder: (context, safetyInductionProvider, _) {
                          if (safetyInductionProvider.inductions.isEmpty) {
                            return Center(
                              child: Text(
                                'Tidak ada laporan yang perlu disetujui',
                                style: primaryTextStyle.copyWith(
                                  color: subtitleTextColor,
                                ),
                              ),
                            );
                          } else {
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  futureGetPatrols = getPatrols();
                                });
                              },
                              color: primaryColor500,
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                children: safetyInductionProvider.inductions
                                    .map((induction) => SafetyInductionCard(
                                          induction: induction,
                                          onTap: () {
                                            _navigateToDetail(induction.id);
                                          },
                                        ))
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
