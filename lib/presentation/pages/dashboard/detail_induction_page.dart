import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/safety_induction/safety_induction_model.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailInductionPage extends StatefulWidget {
  final SafetyInductionModel induction;

  const DetailInductionPage({
    super.key,
    required this.induction,
  });

  @override
  State<DetailInductionPage> createState() => _DetailInductionPageState();
}

class _DetailInductionPageState extends State<DetailInductionPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: greyBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: whiteColor),
              onPressed: () => Navigator.pop(context),
            ),
            iconTheme: IconThemeData(color: whiteColor),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              'Detail Safety Induction',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
          ),
          body: SingleChildScrollView(
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
                          widget.induction.type.toUpperCase(),
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
                        widget.induction.name,
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
                        widget.induction.address ?? '-',
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
                        widget.induction.phoneNumber ?? '-',
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
                        widget.induction.email ?? '-',
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
                        widget.induction.status
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                        style: primaryTextStyle.copyWith(
                          color: widget.induction.status == 'completed'
                              ? Colors.green
                              : widget.induction.status == 'failed'
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
                            .format(widget.induction.createdAt),
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                          fontWeight: semibold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (widget.induction.certificate != null)
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
                                    '${ApiEndpoint.baseUrl}${widget.induction.certificate!.url}');
                              },
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  border: Border.all(color: disabledColor),
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
                                              widget.induction.certificate!.url
                                                  .split('/')
                                                  .last,
                                              style: primaryTextStyle.copyWith(
                                                color: subtitleTextColor,
                                                fontWeight: semibold,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                if (widget.induction.attempts != null &&
                    widget.induction.attempts!.isNotEmpty)
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
                          itemCount: widget.induction.attempts?.length ?? 0,
                          itemBuilder: (context, index) {
                            final attempt = widget.induction.attempts![index];
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 5),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
        if (_isLoading)
          ColoredBox(
            color: blackColor.withOpacity(0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
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
