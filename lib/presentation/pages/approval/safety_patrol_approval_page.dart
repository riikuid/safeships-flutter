import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/widgets/safety_patrol_approval_card.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/presentation/pages/safety_patrol/detail_safety_patrol_page.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class SafetyPatrolApprovalPage extends StatefulWidget {
  const SafetyPatrolApprovalPage({super.key});

  @override
  State<SafetyPatrolApprovalPage> createState() =>
      _SafetyPatrolApprovalPageState();
}

class _SafetyPatrolApprovalPageState extends State<SafetyPatrolApprovalPage> {
  late Future<void> futureGetPatrols;
  late SafetyPatrolProvider safetyPatrolProvider;
  String errorText = "Gagal mendapatkan laporan safety patrol";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    safetyPatrolProvider =
        Provider.of<SafetyPatrolProvider>(context, listen: false);
    futureGetPatrols = getPatrols();
  }

  Future<void> getPatrols() async {
    await safetyPatrolProvider.getManagerial(
      errorCallback: (p0) => setState(() {
        errorText = p0;
      }),
    );
  }

  Future<void> _navigateToDetail(int patrolId, int userId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final patrol = await safetyPatrolProvider.showSafetyPatrol(
        patrolId: patrolId,
        errorCallback: (p0) {
          Fluttertoast.showToast(msg: p0.toString());
        },
      );

      // Tentukan view mode

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailSafetyPatrolPage(
            initialPatrol: patrol,
            userId: authProvider.user.id,
            viewMode: SafetyPatrolViewMode.approver,
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Safety Patrol Approvals',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder(
                  future: futureGetPatrols,
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
                          if (safetyPatrolProvider.managerialPatrols.isEmpty) {
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
                                children: safetyPatrolProvider.managerialPatrols
                                    .map(
                                      (patrol) => SafetyPatrolApprovalCard(
                                        patrol: patrol,
                                        userId: context
                                            .read<AuthProvider>()
                                            .user
                                            .id,
                                        onTap: () => _navigateToDetail(
                                            patrol.id,
                                            context
                                                .read<AuthProvider>()
                                                .user
                                                .id),
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
