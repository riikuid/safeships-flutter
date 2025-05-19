import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/widgets/safety_patrol_submission_card.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class MySafetyPatrolSubmissionsPage extends StatefulWidget {
  const MySafetyPatrolSubmissionsPage({super.key});

  @override
  State<MySafetyPatrolSubmissionsPage> createState() =>
      _MySafetyPatrolSubmissionsPageState();
}

class _MySafetyPatrolSubmissionsPageState
    extends State<MySafetyPatrolSubmissionsPage> {
  late Future<void> futureGetSubmissions;
  late SafetyPatrolProvider safetyPatrolProvider;
  String errorText = "Gagal mendapatkan laporan Anda";

  @override
  void initState() {
    super.initState();
    safetyPatrolProvider =
        Provider.of<SafetyPatrolProvider>(context, listen: false);
    futureGetSubmissions = getSubmissions();
  }

  Future<void> getSubmissions() async {
    await safetyPatrolProvider.getMySubmissions(
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
                  return Consumer<SafetyPatrolProvider>(
                    builder: (context, safetyPatrolProvider, _) {
                      if (safetyPatrolProvider.mySubmissions.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ada laporan yang diajukan',
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
                            children: safetyPatrolProvider.mySubmissions
                                .map((patrol) =>
                                    SafetyPatrolSubmissionCard(patrol: patrol))
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
