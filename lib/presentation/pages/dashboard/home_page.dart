import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/auth_model.dart';
import 'package:safeships_flutter/presentation/pages/document/list_category_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_patrol/pengajuan_safety_patrol_page.dart';
import 'package:safeships_flutter/presentation/widgets/gauge_progress_chart.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    // Ambil data progres saat halaman dimuat
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authModel = context.read<AuthProvider>().user;
    if (authModel == null) {
      setState(() {
        _isLoading = false;
        _error = 'User tidak terautentikasi';
      });
      return;
    }

    await context.read<DocumentProvider>().fetchProgress(
      errorCallback: (error) {
        setState(() {
          _isLoading = false;
          _error = error;
        });
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();

    return Scaffold(
      backgroundColor: Color(0xffF8F8F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                10,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 15,
              ),
            ),
            Container(
              // width: double.infinity,
              margin: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ListCategoryPage()));
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 26,
                              color: Color(0xffD5ABA8),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Dokumentasi K3',
                            style: primaryTextStyle.copyWith(
                              fontSize: 10,
                              fontWeight: semibold,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PengajuanSafetyPatrolPage(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.forward_to_inbox,
                              size: 26,
                              color: Color(0xffD6BB7F),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Formulir Safety Patrol',
                            style: primaryTextStyle.copyWith(
                              fontSize: 10,
                              fontWeight: semibold,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        log('dsds');
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              size: 26,
                              color: Color(0xffA4C0B6),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Formulir Safety Induction',
                            style: primaryTextStyle.copyWith(
                              fontSize: 10,
                              fontWeight: semibold,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Error: $_error',
                  style: primaryTextStyle.copyWith(color: Colors.red),
                ),
              )
            else if (documentProvider.progressData.isNotEmpty)
              GaugeProgressChart(
                progressData: documentProvider.progressData,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tidak ada data progres penilaian',
                  style: primaryTextStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
