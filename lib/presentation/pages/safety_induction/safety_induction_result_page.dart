import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/dashboard.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_certificate_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_test_page.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyInductionResultPage extends StatefulWidget {
  final int inductionId;
  final bool isAfterTest;

  const SafetyInductionResultPage({
    super.key,
    required this.inductionId,
    this.isAfterTest = false,
  });

  @override
  State<SafetyInductionResultPage> createState() =>
      _SafetyInductionResultPageState();
}

class _SafetyInductionResultPageState extends State<SafetyInductionResultPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.isAfterTest ? _fetchResult() : null;
  }

  Future<void> _fetchResult() async {
    final provider = context.read<SafetyInductionProvider>();
    await provider.getResult(
      inductionId: widget.inductionId,
      errorCallback: (error) {
        Fluttertoast.showToast(msg: error.toString());
        Navigator.pop(context);
      },
    );
  }

  Future<void> openPdf({required String url}) async {
    setState(() {
      _isLoading = true;
    });
    final Uri pdfUrl = Uri.parse(url);

    if (await canLaunchUrl(pdfUrl)) {
      // Buka aplikasi WhatsApp jika terinstal
      await launchUrl(
        pdfUrl,
        mode: LaunchMode.externalApplication,
      ).whenComplete(
        () {
          _isLoading = false;
          setState(() {});
        },
      );
    } else {
      Fluttertoast.showToast(msg: 'Terjadi kesalahan, coba lagi beberapa saat');
      _isLoading = false;
      setState(() {});
    }
  }

  Future<void> _handleExit() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Keluar'),
        content: Text(
            'Jika Anda keluar, pengajuan akan ditandai sebagai gagal. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              context
                  .read<SafetyInductionProvider>()
                  .markAsFailed(
                    inductionId: widget.inductionId,
                    errorCallback: (error) {
                      Fluttertoast.showToast(msg: error.toString());
                    },
                  )
                  .then((_) {
                Navigator.pop(context); // Tutup dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
                context.read<SafetyInductionProvider>().resetCurrentInduction();
              }).catchError((error) {
                Fluttertoast.showToast(msg: error.toString());
              }).whenComplete(() {
                setState(() {
                  _isLoading = false;
                });
              });
            },
            child: Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SafetyInductionProvider>(
      builder: (context, provider, child) {
        final induction = provider.currentInduction;
        if (induction == null) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final attempt = provider.latestAttempt;
        final passed = attempt?.passed ?? false;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: greyBackgroundColor,
              appBar: AppBar(
                automaticallyImplyLeading: widget.isAfterTest ? false : true,
                leading: widget.isAfterTest
                    ? null
                    : IconButton(
                        icon: Icon(Icons.arrow_back, color: whiteColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                iconTheme: IconThemeData(color: whiteColor),
                surfaceTintColor: transparentColor,
                backgroundColor: primaryColor500,
                title: Text(
                  widget.isAfterTest
                      ? 'Hasil Tes Safety Induction'
                      : 'Detail Safety Induction',
                  style: primaryTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semibold,
                    color: whiteColor,
                  ),
                ),
              ),
              bottomNavigationBar: widget.isAfterTest
                  ? Container(
                      decoration: BoxDecoration(
                        color: whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 24,
                            offset: Offset(0, 11),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          if (!passed)
                            Expanded(
                              flex: 1,
                              child: PrimaryButton(
                                color: redLableColor,
                                borderColor: redLableColor,
                                elevation: 0,
                                child: Text(
                                  'Keluar',
                                  style: primaryTextStyle.copyWith(
                                    color: whiteColor,
                                    fontWeight: semibold,
                                  ),
                                ),
                                onPressed: _handleExit,
                              ),
                            ),
                          if (!passed) const SizedBox(width: 10),
                          if (!passed)
                            Expanded(
                              flex: 2,
                              child: PrimaryButton(
                                color: primaryColor500,
                                borderColor: primaryColor500,
                                elevation: 0,
                                child: Text(
                                  'Kerjakan Ulang',
                                  style: primaryTextStyle.copyWith(
                                    color: whiteColor,
                                    fontWeight: semibold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SafetyInductionTestPage(
                                        inductionId: widget.inductionId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (passed)
                            Expanded(
                              child: PrimaryButton(
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
                            ),
                        ],
                      ),
                    )
                  : null,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: primaryColor400,
                              ),
                              child: Text(
                                induction.type.toUpperCase(),
                                style: primaryTextStyle.copyWith(
                                  fontSize: 10,
                                  color: whiteColor,
                                  fontWeight: semibold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Nama',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              induction.name,
                              style: primaryTextStyle.copyWith(
                                color: blackColor,
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Alamat',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              induction.address ?? '-',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Nomor Telepon',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              induction.phoneNumber ?? '-',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Email',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              induction.email ?? '-',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Status',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              induction.status
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: primaryTextStyle.copyWith(
                                color: induction.status == 'completed'
                                    ? Colors.green
                                    : induction.status == 'failed'
                                        ? redLableColor
                                        : subtitleTextColor,
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Tanggal Pengajuan',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              DateFormat('dd MMMM yyyy, HH:mm')
                                  .format(induction.createdAt),
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (induction.certificate != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sertifikat',
                                    style: primaryTextStyle.copyWith(
                                      color: subtitleTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      downloadAndOpenFile(
                                          '${ApiEndpoint.baseUrl}${induction.certificate!.url}');
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        border:
                                            Border.all(color: disabledColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.description,
                                                  color: subtitleTextColor,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 5),
                                                Flexible(
                                                  child: Text(
                                                    induction.certificate!.url
                                                        .split('/')
                                                        .last,
                                                    style: primaryTextStyle
                                                        .copyWith(
                                                      color: subtitleTextColor,
                                                      fontWeight: semibold,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (induction.attempts != null &&
                          induction.attempts!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riwayat Percobaan',
                                style: primaryTextStyle.copyWith(
                                  color: subtitleTextColor,
                                  fontSize: 12,
                                  fontWeight: semibold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: induction.attempts?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final attempt = induction.attempts![index];
                                  return Container(
                                    width: double.infinity,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          width: 1,
                                          color: disabledColor,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Percobaan #${index + 1}',
                                          style: primaryTextStyle.copyWith(
                                            fontSize: 12,
                                            color: blackColor,
                                            fontWeight: semibold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Skor: ${attempt.score}',
                                          style: primaryTextStyle.copyWith(
                                            fontSize: 10,
                                            color: subtitleTextColor,
                                            fontWeight: semibold,
                                          ),
                                        ),
                                        Text(
                                          'Status: ${attempt.passed ? 'Lulus' : 'Gagal'}',
                                          style: primaryTextStyle.copyWith(
                                            fontSize: 10,
                                            color: attempt.passed
                                                ? Colors.green
                                                : redLableColor,
                                            fontWeight: semibold,
                                          ),
                                        ),
                                        Text(
                                          'Tanggal: ${DateFormat('dd MMMM yyyy').format(attempt.attemptDate)}',
                                          style: primaryTextStyle.copyWith(
                                            fontSize: 10,
                                            color: subtitleTextColor,
                                            fontWeight: regular,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
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

  Future<void> downloadAndOpenFile(String url) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${url.split('/').last}';
      final dio = Dio();
      await dio.download(url, filePath);
      await OpenFile.open(filePath);
    } catch (e) {
      log('Error downloading/opening file: $url, $e');
      Fluttertoast.showToast(msg: 'Gagal mengunduh atau membuka file: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
