import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/document_model.dart';
import 'package:safeships_flutter/presentation/widgets/approve_document_modal.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/presentation/widgets/reject_document_modal.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DetailDocumentApprovalPage extends StatefulWidget {
  final int userId;
  final DocumentModel doc;
  final bool isViewOnly;
  const DetailDocumentApprovalPage(
      {super.key,
      required this.doc,
      required this.userId,
      required this.isViewOnly});

  @override
  State<DetailDocumentApprovalPage> createState() =>
      _DetailDocumentApprovalPageState();
}

class _DetailDocumentApprovalPageState
    extends State<DetailDocumentApprovalPage> {
  bool _isLoading = false;
  handleApprove() async {
    await context
        .read<DocumentProvider>()
        .approveDocument(
          documentId: widget.doc.id,
        )
        .then(
      (value) {
        setState(() {});
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
      await OpenFile.open(filePath);
    } catch (e) {
      log(url);
      Fluttertoast.showToast(msg: 'Gagal mengunduh atau membuka file: $e');
      log(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DocumentModel selectedDoc =
        context.watch<DocumentProvider>().documentsManagerial.firstWhere(
              (element) => element.id == widget.doc.id,
            );

    String approval = selectedDoc.documentApprovals!
        .firstWhere(
          (approval) => approval.approverId == widget.userId,
        )
        .status;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: whiteColor,
            ),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              'Detail Pengajuan Dokumentasi',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
          ),
          bottomNavigationBar: !widget.isViewOnly
              ? null
              : Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 24,
                        offset: Offset(0, 11),
                      ),
                    ],
                  ),
                  child: approval == 'approved' ||
                          approval == 'rejected' ||
                          selectedDoc.status == 'rejected'
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              child: Center(
                                child: Text(
                                  'PENGAJUAN DOKUMENTASI TELAH ${selectedDoc == 'rejected' ? 'DITOLAK' : approval == 'approved' ? 'ANDA DISETUJUI' : 'DITOLAK'}',
                                  style: primaryTextStyle.copyWith(
                                    color: subtitleTextColor,
                                    // fontWeight: semibold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                borderColor: redLableColor,
                                color: redLableColor.withOpacity(0.1),
                                elevation: 0,
                                child: Text(
                                  'Reject',
                                  style: primaryTextStyle.copyWith(
                                    color: redLableColor,
                                    fontWeight: semibold,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return RejectDocumentModal(
                                        documentId: selectedDoc.id,
                                        onRejected: () {
                                          setState(() {});
                                          // Tambahkan logika lain jika perlu setelah dokumen berhasil ditolak
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: PrimaryButton(
                                borderColor: greenLableColor,
                                color: greenLableColor,
                                elevation: 0,
                                child: Text(
                                  'Approve',
                                  style: primaryTextStyle.copyWith(
                                    color: whiteColor,
                                    fontWeight: semibold,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ApproveDocumentDialog(
                                        documentId: widget.doc.id,
                                        documentTitle: widget.doc.title,
                                        onApproved: () {
                                          setState(() {});
                                          // Tambahkan logika lain jika perlu setelah dokumen berhasil disetujui
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDoc.title,
                        style: primaryTextStyle.copyWith(
                          color: blackColor,
                          fontWeight: semibold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Poin Kriteria',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100),
                              ),
                              color: primaryColor400,
                            ),
                            child: Text(
                              selectedDoc.category.code,
                              style: primaryTextStyle.copyWith(
                                fontSize: 10,
                                color: whiteColor,
                                fontWeight: semibold,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        selectedDoc.category.name,
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                          fontWeight: semibold,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Deskirpsi',
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        selectedDoc.description,
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                          fontWeight: semibold,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'File',
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          downloadAndOpenFile(
                              '${ApiEndpoint.baseUrl}/storage/${selectedDoc.filePath}');
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(color: disabledColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize
                                .max, // Set to max to fill the container
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min, // Important: set to min
                                  children: [
                                    // const SizedBox(width: 8),
                                    Icon(
                                      AppHelper.getFileIcon(
                                          selectedDoc.filePath),
                                      color: subtitleTextColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      // Using Flexible instead of Expanded
                                      child: Text(
                                        selectedDoc.filePath
                                            .replaceFirst('documents/', ''),
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
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Pengajuan',
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                          fontWeight: semibold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        selectedDoc.status.replaceAll('_', ' ').toUpperCase(),
                        style: primaryTextStyle.copyWith(
                          color: AppHelper.getColorBasedOnStatus(
                              selectedDoc.status),
                          fontSize: 12,
                          fontWeight: semibold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ...selectedDoc.documentApprovals!.map(
                        (e) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(0),
                              ),
                              border: Border(
                                left: BorderSide(
                                  width: 1,
                                  color: disabledColor,
                                ),
                              ),
                              // color: primaryColor400,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.approver.name,
                                  style: primaryTextStyle.copyWith(
                                    fontSize: 12,
                                    color: blackColor,
                                    fontWeight: semibold,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  e.approver.role
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  style: primaryTextStyle.copyWith(
                                    fontSize: 10,
                                    color: subtitleTextColor,
                                    fontWeight: semibold,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                    border: Border.all(
                                      width: 0.5,
                                      color: AppHelper.getColorBasedOnStatus(
                                          e.status),
                                    ),
                                    color: AppHelper.getColorBasedOnStatus(
                                      e.status,
                                    ).withOpacity(0.1),
                                  ),
                                  child: Text(
                                    e.status.toUpperCase(),
                                    style: primaryTextStyle.copyWith(
                                      fontSize: 10,
                                      color: AppHelper.getColorBasedOnStatus(
                                          e.status),
                                      fontWeight: semibold,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                if (e.status == 'rejected')
                                  const SizedBox(
                                    height: 5,
                                  ),
                                if (e.status == 'rejected')
                                  Text(
                                    'Catatan : ${e.comments ?? '-'}',
                                    style: primaryTextStyle.copyWith(
                                      fontSize: 10,
                                      color: subtitleTextColor,
                                      fontWeight: regular,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          ColoredBox(
            color: blackColor.withOpacity(0.4),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }
}
