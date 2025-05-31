import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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

// Enum untuk membedakan mode tampilan
enum DocumentViewMode {
  public, // Dokumen publik (sudah di-approve)
  managerial, // Untuk approval via daftar managerial
  mySubmissions, // Pengajuan pengguna sendiri
  approver, // Untuk approver via notifikasi
}

class DetailDocumentPage extends StatefulWidget {
  final int userId;
  final DocumentModel doc;
  final DocumentViewMode viewMode;

  const DetailDocumentPage({
    super.key,
    required this.doc,
    required this.userId,
    this.viewMode = DocumentViewMode.public,
  });

  @override
  State<DetailDocumentPage> createState() => _DetailDocumentPageState();
}

class _DetailDocumentPageState extends State<DetailDocumentPage> {
  bool _isLoading = false;

  Future<void> downloadAndOpenFile(String url) async {
    if (widget.doc.status == 'DELETED') {
      Fluttertoast.showToast(msg: 'File dokumentasi telah dihapus');
      return;
    }
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
    // Pilih dokumen berdasarkan viewMode
    DocumentModel selectedDoc;
    final docProvider = context.watch<DocumentProvider>();
    if (widget.viewMode == DocumentViewMode.mySubmissions) {
      // Gunakan widget.doc untuk memastikan data terbaru dari showDocument
      selectedDoc = widget.doc;
      if (kDebugMode) {
        log('DetailDocumentPage: Using widget.doc, ID=${selectedDoc.id}, Status=${selectedDoc.status}');
      }
    } else if (widget.viewMode == DocumentViewMode.managerial ||
        widget.viewMode == DocumentViewMode.approver) {
      try {
        selectedDoc = docProvider.documentsManagerial.firstWhere(
          (element) => element.id == widget.doc.id,
        );
      } catch (e) {
        selectedDoc = widget.doc;
        log('Dokumen tidak ditemukan di documentsManagerial: $e');
      }
    } else {
      selectedDoc = widget.doc;
    }

    // Tentukan apakah pengguna memiliki hak untuk menyetujui/menolak
    bool canApproveOrReject = (widget.viewMode == DocumentViewMode.managerial ||
            widget.viewMode == DocumentViewMode.approver) &&
        selectedDoc.documentApprovals!.any(
          (approval) =>
              approval.approverId == widget.userId &&
              approval.status == 'pending',
        ) &&
        selectedDoc.status != 'rejected' &&
        selectedDoc.status != 'approved';

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          appBar: AppBar(
            iconTheme: IconThemeData(color: whiteColor),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              widget.viewMode == DocumentViewMode.public
                  ? 'Detail Dokumen'
                  : 'Detail Pengajuan Dokumentasi',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
          ),
          bottomNavigationBar: canApproveOrReject
              ? Container(
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
                  child: Row(
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
                                    setState(() {}); // Refresh UI
                                    Fluttertoast.showToast(
                                        msg: 'Document rejected');
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
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
                                  documentId: selectedDoc.id,
                                  documentTitle: selectedDoc.title,
                                  onApproved: () {
                                    setState(() {}); // Refresh UI
                                    Fluttertoast.showToast(
                                        msg: 'Document approved');
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Bagian Detail Dokumen
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Poin Kriteria',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
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
                      const SizedBox(height: 5),
                      Text(
                        selectedDoc.category.name,
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                          fontWeight: semibold,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Deskripsi',
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        selectedDoc.description ?? '-',
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                          fontWeight: semibold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'File',
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          downloadAndOpenFile(
                              '${ApiEndpoint.baseUrl}/storage/${selectedDoc.filePath}');
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(color: disabledColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      AppHelper.getFileIcon(
                                          selectedDoc.filePath),
                                      color: subtitleTextColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
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
                      if (widget.viewMode == DocumentViewMode.public) ...[
                        const SizedBox(height: 15),
                        Text(
                          'Dipublikasikan pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(selectedDoc.updatedAt)}',
                          style: primaryTextStyle.copyWith(
                            color: subtitleTextColor,
                            fontSize: 12,
                            fontWeight: regular,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Bagian Status Pengajuan (tidak ditampilkan untuk mode public)
                if (widget.viewMode != DocumentViewMode.public)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
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
                        const SizedBox(height: 5),
                        Text(
                          selectedDoc.status.replaceAll('_', ' ').toUpperCase(),
                          style: primaryTextStyle.copyWith(
                            color: AppHelper.getColorBasedOnStatus(
                                selectedDoc.status),
                            fontSize: 12,
                            fontWeight: semibold,
                          ),
                        ),
                        if (selectedDoc.status == 'DELETED') ...[
                          const SizedBox(height: 5),
                          Text(
                            'Dihapus pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(selectedDoc.updatedAt)}',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                              fontSize: 12,
                              fontWeight: regular,
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
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
                                    e.approver.name,
                                    style: primaryTextStyle.copyWith(
                                      fontSize: 12,
                                      color: blackColor,
                                      fontWeight: semibold,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                  const SizedBox(height: 3),
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
                                              e.status)
                                          .withOpacity(0.1),
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
                                  if (e.status == 'rejected') ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      'Catatan: ${e.comments ?? '-'}',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: 10,
                                        color: subtitleTextColor,
                                        fontWeight: regular,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
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
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
