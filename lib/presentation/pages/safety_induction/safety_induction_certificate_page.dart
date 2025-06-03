import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/dashboard.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';
// import 'package:url_launcher/url_launcher.dart';

class SafetyInductionCertificatePage extends StatefulWidget {
  final int inductionId;

  const SafetyInductionCertificatePage({super.key, required this.inductionId});

  @override
  State<SafetyInductionCertificatePage> createState() =>
      _SafetyInductionCertificatePageState();
}

class _SafetyInductionCertificatePageState
    extends State<SafetyInductionCertificatePage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCertificate();
  }

  Future<void> _fetchCertificate() async {
    final provider = context.read<SafetyInductionProvider>();
    await provider.getCertificate(
      inductionId: widget.inductionId,
      errorCallback: (error) {
        Fluttertoast.showToast(msg: error.toString());
        Navigator.pop(context);
      },
    );
  }

  Future<void> downloadAndOpenFile(String url) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${url.split('/').last}';
      await dio.download(url, filePath);
      await OpenFile.open(filePath).then(
        (value) {
          log(value.message);
        },
      );
    } catch (e) {
      log('Error downloading/opening file: $url, $e');
      Fluttertoast.showToast(msg: 'Gagal mengunduh atau membuka file: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SafetyInductionProvider>(
      builder: (context, provider, child) {
        if (provider.certificate == null) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final certificate = provider.certificate;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: greyBackgroundColor,
              appBar: AppBar(
                iconTheme: IconThemeData(color: whiteColor),
                surfaceTintColor: transparentColor,
                backgroundColor: primaryColor500,
                title: Text(
                  'Sertifikat Safety Induction',
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
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sertifikat',
                          style: primaryTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: semibold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Nomor: ${certificate?.id ?? '-'}',
                          style: primaryTextStyle.copyWith(fontSize: 14),
                        ),
                        Text(
                          'Tanggal Terbit: ${certificate != null ? DateFormat('dd MMM yyyy').format(certificate.issuedDate) : '-'}',
                          style: primaryTextStyle.copyWith(fontSize: 14),
                        ),
                        Text(
                          'Tanggal Kadaluarsa: ${certificate != null ? DateFormat('dd MMM yyyy').format(certificate.expiredDate) : '-'}',
                          style: primaryTextStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          isLoading: _isLoading,
                          color: primaryColor500,
                          borderColor: primaryColor500,
                          elevation: 0,
                          child: Text(
                            'Lihat Sertifikat',
                            style: primaryTextStyle.copyWith(
                              color: whiteColor,
                              fontWeight: semibold,
                            ),
                          ),
                          onPressed: () => downloadAndOpenFile(
                              '${ApiEndpoint.baseUrl}/${certificate!.url}'),
                        ),
                        const SizedBox(height: 15),
                        PrimaryButton(
                          isLoading: _isLoading,
                          color: greyBackgroundColor,
                          borderColor: disabledColor,
                          elevation: 0,
                          child: Text(
                            'Kembali ke Beranda',
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontWeight: semibold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Dashboard(),
                              ),
                            );
                            provider.resetCurrentInduction();
                          },
                        ),
                      ],
                    ),
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
