import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/document/list_category_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_patrol/pengajuan_safety_patrol_page.dart';
import 'package:safeships_flutter/presentation/widgets/gauge_progress_chart.dart';
import 'package:safeships_flutter/presentation/widgets/safety_patrol_bar_chart.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                0,
                20,
                20,
                0,
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
          ],
        ),
      ),
    );
  }
}
