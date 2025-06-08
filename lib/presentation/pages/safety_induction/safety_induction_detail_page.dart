import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_certificate_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_result_page.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyInductionDetailPage extends StatefulWidget {
  const SafetyInductionDetailPage({super.key});

  @override
  State<SafetyInductionDetailPage> createState() =>
      _SafetyInductionDetailPageState();
}

class _SafetyInductionDetailPageState extends State<SafetyInductionDetailPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    final provider = context.read<SafetyInductionProvider>();
    await provider.getMySubmissions(
      errorCallback: (error) {
        Fluttertoast.showToast(msg: error.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SafetyInductionProvider>(
      builder: (context, provider, child) {
        if (provider.mySubmissions.isEmpty) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: greyBackgroundColor,
          appBar: AppBar(
            iconTheme: IconThemeData(color: whiteColor),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              'Riwayat Pengajuan',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
          ),
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
                        Text(
                          'Status: ${submission.status}',
                          style: primaryTextStyle.copyWith(fontSize: 14),
                        ),
                        Text(
                          'Tanggal: ${DateFormat('dd MMM yyyy').format(submission.createdAt)}',
                          style: primaryTextStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 15),
                        PrimaryButton(
                          isLoading: _isLoading,
                          color: primaryColor500,
                          borderColor: primaryColor500,
                          elevation: 0,
                          child: Text(
                            submission.certificate != null
                                ? 'Lihat Sertifikat'
                                : 'Lihat Hasil',
                            style: primaryTextStyle.copyWith(
                              color: whiteColor,
                              fontWeight: semibold,
                            ),
                          ),
                          onPressed: () {
                            if (submission.certificate != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SafetyInductionCertificatePage(
                                    inductionId: submission.id,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SafetyInductionResultPage(
                                          inductionId: submission.id),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
