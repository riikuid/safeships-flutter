import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/auth_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';
import 'package:safeships_flutter/presentation/widgets/approve_patrol_modal.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/presentation/widgets/reject_patrol_modal.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/services/user_service.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:open_file/open_file.dart';
import 'form_safety_patrol_page.dart'; // Import the new form page

enum SafetyPatrolViewMode {
  approver,
  submitter,
  actor,
}

class DetailSafetyPatrolPage extends StatefulWidget {
  final int userId;
  final SafetyPatrolModel initialPatrol;
  final SafetyPatrolViewMode viewMode;

  const DetailSafetyPatrolPage({
    super.key,
    required this.initialPatrol,
    required this.userId,
    this.viewMode = SafetyPatrolViewMode.approver,
  });

  @override
  State<DetailSafetyPatrolPage> createState() => _DetailSafetyPatrolPageState();
}

class _DetailSafetyPatrolPageState extends State<DetailSafetyPatrolPage> {
  bool _isLoading = false;
  final UserService _userService = UserService();
  late AuthModel user = Provider.of<AuthProvider>(context).user;
  late SafetyPatrolModel patrol;

  @override
  void initState() {
    super.initState();
    patrol = widget.initialPatrol;
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
      log('Error downloading/opening file: $url, $e');
      Fluttertoast.showToast(msg: 'Gagal mengunduh atau membuka file: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPatrol() async {
    try {
      final updatedPatrol =
          await context.read<SafetyPatrolProvider>().showSafetyPatrol(
                patrolId: patrol.id,
                errorCallback: (error) {
                  Fluttertoast.showToast(msg: error.toString());
                },
              );
      setState(() {
        patrol = updatedPatrol;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _handleApprove() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (patrol.status == 'pending_feedback_approval') {
        final updatedPatrol = await showDialog<SafetyPatrolModel>(
          context: context,
          builder: (BuildContext context) {
            return ApprovePatrolModal(
              userId: user.id,
              patrolId: patrol.feedbacks?.last.id ?? patrol.id,
              isFeedbackApproval: true,
              users: [],
              onApproved: (updatedPatrol) {
                return updatedPatrol;
              },
            );
          },
        );
        if (updatedPatrol != null) {
          setState(() {
            patrol = updatedPatrol;
          });
        }
      } else if (patrol.status == 'pending_manager') {
        final token = await context
            .read<SafetyPatrolProvider>()
            .tokenRepository
            .getToken();
        if (token == null) throw 'No token found';
        final users = await _userService.getUsers(
          token: token,
          role: 'user',
        );
        final updatedPatrol = await showDialog<SafetyPatrolModel>(
          context: context,
          builder: (BuildContext context) {
            return ApprovePatrolModal(
              userId: user.id,
              patrolId: patrol.id,
              isFeedbackApproval: false,
              users: users,
              onApproved: (updatedPatrol) {
                return updatedPatrol;
              },
            );
          },
        );
        if (updatedPatrol != null) {
          setState(() {
            patrol = updatedPatrol;
          });
        }
      } else {
        final updatedPatrol = await showDialog<SafetyPatrolModel>(
          context: context,
          builder: (BuildContext context) {
            return ApprovePatrolModal(
              userId: user.id,
              patrolId: patrol.id,
              isFeedbackApproval: false,
              users: [],
              onApproved: (updatedPatrol) {
                return updatedPatrol;
              },
            );
          },
        );
        if (updatedPatrol != null) {
          setState(() {
            patrol = updatedPatrol;
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleReject() async {
    final updatedPatrol = await showDialog<SafetyPatrolModel>(
      context: context,
      builder: (BuildContext context) {
        return RejectPatrolModal(
          userId: user.id,
          patrolId: patrol.status == 'pending_feedback_approval'
              ? patrol.feedbacks?.last.id ?? patrol.id
              : patrol.id,
          isFeedbackApproval: patrol.status == 'pending_feedback_approval',
          onRejected: (updatedPatrol) {
            return updatedPatrol;
          },
        );
      },
    );
    if (updatedPatrol != null) {
      setState(() {
        patrol = updatedPatrol;
      });
    }
  }

  Future<void> _handleSubmitFeedback() async {
    final updatedPatrol = await Navigator.push<SafetyPatrolModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FormSafetyPatrolPage(
          mode: FormMode.feedback,
          patrolId: patrol.id,
        ),
      ),
    );
    if (updatedPatrol != null) {
      setState(() {
        patrol = updatedPatrol;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canApproveOrReject =
        widget.viewMode == SafetyPatrolViewMode.approver &&
            (patrol.status == 'pending_super_admin' ||
                patrol.status == 'pending_manager' ||
                patrol.status == 'pending_feedback_approval') &&
            ((patrol.status != 'pending_feedback_approval' &&
                    patrol.approvals?.any((approval) =>
                            approval.approverId == widget.userId &&
                            approval.status == 'pending') ==
                        true) ||
                (patrol.status == 'pending_feedback_approval' &&
                    patrol.feedbacks?.last.approvals?.any((approval) =>
                            approval.approverId == widget.userId &&
                            approval.status == 'pending') ==
                        true));

    bool canSubmitFeedback = widget.viewMode == SafetyPatrolViewMode.actor &&
        patrol.status == 'pending_action' &&
        patrol.action?.actorId == widget.userId;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          appBar: AppBar(
            iconTheme: IconThemeData(color: whiteColor),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              widget.viewMode == SafetyPatrolViewMode.submitter
                  ? 'Detail Pengajuan Patrol'
                  : 'Detail Safety Patrol',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: whiteColor),
                onPressed: _refreshPatrol,
              ),
            ],
          ),
          bottomNavigationBar: canApproveOrReject || canSubmitFeedback
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
                      if (canApproveOrReject) ...[
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
                            onPressed: _handleReject,
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
                            onPressed: _handleApprove,
                          ),
                        ),
                      ],
                      if (canSubmitFeedback)
                        Expanded(
                          child: PrimaryButton(
                            borderColor: primaryColor500,
                            color: primaryColor500,
                            elevation: 0,
                            child: Text(
                              'Submit Feedback',
                              style: primaryTextStyle.copyWith(
                                color: whiteColor,
                                fontWeight: semibold,
                              ),
                            ),
                            onPressed: _handleSubmitFeedback,
                          ),
                        ),
                    ],
                  ),
                )
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                ExpansionTile(
                  shape: Border(
                    top: BorderSide(color: disabledColor, width: 0.5),
                  ),
                  title: Text(
                    'Detail Laporan',
                    style: primaryTextStyle.copyWith(
                      color: subtitleTextColor,
                      fontWeight: semibold,
                      fontSize: 14,
                    ),
                  ),
                  initiallyExpanded:
                      patrol.status == 'pending_feedback_approval'
                          ? false
                          : true,
                  children: [
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
                            patrol.location,
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontWeight: semibold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                              patrol.type
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: primaryTextStyle.copyWith(
                                fontSize: 10,
                                color: whiteColor,
                                fontWeight: semibold,
                              ),
                              textAlign: TextAlign.justify,
                            ),
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
                            patrol.description ?? '-',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                              fontSize: 12,
                              fontWeight: semibold,
                            ),
                          ),
                          if (patrol.imagePath != null) ...[
                            const SizedBox(height: 15),
                            Text(
                              'Gambar',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                downloadAndOpenFile(
                                    '${ApiEndpoint.baseUrl}/storage/${patrol.imagePath}');
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
                                            AppHelper.getFileIcon(
                                                patrol.imagePath!),
                                            color: subtitleTextColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              patrol.imagePath!
                                                  .replaceFirst('patrols/', ''),
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
                          const SizedBox(height: 15),
                          Text(
                            'Disubmit pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(patrol.createdAt)}',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                              fontSize: 12,
                              fontWeight: regular,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Status Pengajuan',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                              fontSize: 12,
                              fontWeight: regular,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            patrol.status.replaceAll('_', ' ').toUpperCase(),
                            style: primaryTextStyle.copyWith(
                              color: AppHelper.getColorBasedOnStatus(
                                  patrol.status),
                              fontSize: 12,
                              fontWeight: semibold,
                            ),
                          ),
                          if (patrol.status == 'rejected') ...[
                            const SizedBox(height: 15),
                            Text(
                              'Ditolak pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(patrol.updatedAt)}',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                                fontWeight: regular,
                              ),
                            ),
                          ],
                          if (patrol.status == 'pending_action' &&
                              patrol.action?.actor != null) ...[
                            const SizedBox(height: 15),
                            Text(
                              'Penanggung Jawab Tindakan Lanjutan: ',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontWeight: regular,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              patrol.action!.actor!.name,
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                          ],
                          if (widget.viewMode == SafetyPatrolViewMode.actor &&
                              patrol.action?.deadline != null) ...[
                            const SizedBox(height: 15),
                            Text(
                              'Tenggat Waktu: ${DateFormat('dd MMMM yyyy').format(patrol.action!.deadline!)}',
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
                  ],
                ),
                ExpansionTile(
                  shape: Border(
                    top: BorderSide(color: disabledColor, width: 0.5),
                  ),
                  title: Text(
                    'Status Pengajuan',
                    style: primaryTextStyle.copyWith(
                      color: subtitleTextColor,
                      fontWeight: semibold,
                      fontSize: 14,
                    ),
                  ),
                  initiallyExpanded: true,
                  children: [
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
                          ...(patrol.approvals ?? []).map(
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
                                      e.approver?.name ?? 'Unknown',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: 12,
                                        color: blackColor,
                                        fontWeight: semibold,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      (e.approver?.role ?? 'unknown')
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
                                          color:
                                              AppHelper.getColorBasedOnStatus(
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
                                          color:
                                              AppHelper.getColorBasedOnStatus(
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
                ExpansionTile(
                  shape: Border(
                    top: BorderSide(color: disabledColor, width: 0.5),
                  ),
                  title: Text(
                    'Detail Feedback',
                    style: primaryTextStyle.copyWith(
                      color: subtitleTextColor,
                      fontWeight: semibold,
                      fontSize: 14,
                    ),
                  ),
                  initiallyExpanded: patrol.feedbacks?.isNotEmpty ?? false,
                  children: [
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
                          if (patrol.feedbacks?.isEmpty ?? true)
                            Text(
                              'Belum ada feedback',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ...(patrol.feedbacks ?? []).map(
                            (feedback) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Feedback oleh: ${patrol.action?.actor?.name ?? 'Unknown'}',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: 12,
                                        color: blackColor,
                                        fontWeight: semibold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Deskripsi: ${feedback.description ?? '-'}',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: 12,
                                        color: subtitleTextColor,
                                      ),
                                    ),
                                    if (feedback.imagePath != null) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        'Gambar',
                                        style: primaryTextStyle.copyWith(
                                          color: subtitleTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () {
                                          downloadAndOpenFile(
                                              '${ApiEndpoint.baseUrl}/storage/${feedback.imagePath}');
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: whiteColor,
                                            border: Border.all(
                                                color: disabledColor),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      AppHelper.getFileIcon(
                                                          feedback.imagePath!),
                                                      color: subtitleTextColor,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Flexible(
                                                      child: Text(
                                                        feedback.imagePath!
                                                            .replaceFirst(
                                                                'feedbacks/',
                                                                ''),
                                                        style: primaryTextStyle
                                                            .copyWith(
                                                          color:
                                                              subtitleTextColor,
                                                          fontWeight: semibold,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                    const SizedBox(height: 5),
                                    Text(
                                      'Disubmit pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(feedback.createdAt)}',
                                      style: primaryTextStyle.copyWith(
                                        color: subtitleTextColor,
                                        fontSize: 12,
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
                  ],
                ),
                ExpansionTile(
                  shape: Border(
                    top: BorderSide(color: disabledColor, width: 0.5),
                  ),
                  title: Text(
                    'Status Pengajuan Feedback',
                    style: primaryTextStyle.copyWith(
                      color: subtitleTextColor,
                      fontWeight: semibold,
                      fontSize: 14,
                    ),
                  ),
                  initiallyExpanded: patrol.feedbacks?.isNotEmpty ?? false,
                  children: [
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
                          if (patrol.feedbacks?.isEmpty ?? true)
                            Text(
                              'Belum ada feedback',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ...(patrol.feedbacks ?? []).map(
                            (feedback) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Feedback oleh: ${feedback.actor?.name ?? 'Unknown'}',
                                    style: primaryTextStyle.copyWith(
                                      fontSize: 12,
                                      color: blackColor,
                                      fontWeight: semibold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ...(feedback.approvals ?? []).map(
                                    (e) {
                                      return Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
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
                                              e.approver?.name ?? 'Unknown',
                                              style: primaryTextStyle.copyWith(
                                                fontSize: 12,
                                                color: blackColor,
                                                fontWeight: semibold,
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              (e.approver?.role ?? 'unknown')
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
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 2,
                                                horizontal: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(100),
                                                ),
                                                border: Border.all(
                                                  width: 0.5,
                                                  color: AppHelper
                                                      .getColorBasedOnStatus(
                                                          e.status),
                                                ),
                                                color: AppHelper
                                                        .getColorBasedOnStatus(
                                                            e.status)
                                                    .withOpacity(0.1),
                                              ),
                                              child: Text(
                                                e.status.toUpperCase(),
                                                style:
                                                    primaryTextStyle.copyWith(
                                                  fontSize: 10,
                                                  color: AppHelper
                                                      .getColorBasedOnStatus(
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
                                                style:
                                                    primaryTextStyle.copyWith(
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
                                  const SizedBox(height: 10),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
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
