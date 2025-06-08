import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_certificate_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_result_page.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';

class MySafetyInductionPage extends StatefulWidget {
  const MySafetyInductionPage({super.key});

  @override
  State<MySafetyInductionPage> createState() => _MySafetyInductionPageState();
}

class _MySafetyInductionPageState extends State<MySafetyInductionPage> {
  bool _isLoading = false;
  bool _isLoadingFetch = false;

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    setState(() {
      _isLoadingFetch = true;
    });
    final provider = context.read<SafetyInductionProvider>();
    await provider.getMySubmissions(
      errorCallback: (error) {
        Fluttertoast.showToast(msg: error.toString());
      },
    ).whenComplete(
      () {
        setState(() {
          _isLoadingFetch = false;
        });
      },
    );
    setState(() {
      _isLoadingFetch = false;
    });
  }

  Future<void> _fetchResult(int inductionId) async {
    setState(() {
      _isLoading = true;
    });
    log('fetch di list');
    final provider = context.read<SafetyInductionProvider>();
    await provider
        .getResult(
      inductionId: inductionId,
      errorCallback: (error) {
        // Fluttertoast.showToast(msg: error.toString());
        Navigator.pop(context);
      },
    )
        .catchError((error) {
      Fluttertoast.showToast(msg: error.toString());
    }).whenComplete(
      () {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SafetyInductionProvider>(
      builder: (context, provider, child) {
        if (_isLoadingFetch) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (provider.mySubmissions.isEmpty) {
          return Scaffold(
            body: Center(
                child: Text(
              'Tidak Ada Safety Induction yg Anda Ajukan',
              style: primaryTextStyle.copyWith(
                color: subtitleTextColor,
                fontWeight: semibold,
              ),
            )),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: greyBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: provider.mySubmissions.map((submission) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              submission.name,
                              style: primaryTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tipe: ${submission.type}',
                              style: primaryTextStyle.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Status: ${submission.status.toUpperCase()}',
                              style: primaryTextStyle.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Tanggal: ${DateFormat('dd MMM yyyy').format(submission.createdAt)}',
                              style: primaryTextStyle.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 15),
                            PrimaryButton(
                              color: primaryColor500,
                              borderColor: primaryColor500,
                              elevation: 0,
                              child: Text(
                                'Lihat Detail',
                                style: primaryTextStyle.copyWith(
                                  color: whiteColor,
                                  fontWeight: semibold,
                                ),
                              ),
                              onPressed: () async {
                                await _fetchResult(submission.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SafetyInductionResultPage(
                                      inductionId: submission.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              ColoredBox(
                color: blackColor.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
