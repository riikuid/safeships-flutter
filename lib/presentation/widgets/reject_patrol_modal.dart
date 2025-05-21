import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';
import 'package:safeships_flutter/presentation/widgets/custom_text_field.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/theme.dart';

class RejectPatrolModal extends StatefulWidget {
  final int patrolId;
  final int userId;
  final bool isFeedbackApproval;
  final Function(SafetyPatrolModel) onRejected;

  const RejectPatrolModal({
    super.key,
    required this.patrolId,
    required this.isFeedbackApproval,
    required this.onRejected,
    required this.userId,
  });

  @override
  State<RejectPatrolModal> createState() => _RejectPatrolModalState();
}

class _RejectPatrolModalState extends State<RejectPatrolModal> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleReject() async {
    if (_commentController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Alasan penolakan tidak boleh kosong");
      return;
    }

    setState(() {
      _isLoading = true;
    });
    log('Reject comments: ${_commentController.text}');

    try {
      final provider = context.read<SafetyPatrolProvider>();
      SafetyPatrolModel updatedPatrol;
      if (widget.isFeedbackApproval) {
        updatedPatrol = await provider.rejectFeedback(
          userId: widget.userId,
          feedbackId: widget.patrolId,
          patrolId: widget.patrolId, // This should be the actual patrol ID
          comments: _commentController.text,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      } else {
        updatedPatrol = await provider.rejectSafetyPatrol(
          userId: widget.userId,
          patrolId: widget.patrolId,
          comments: _commentController.text,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      }

      Navigator.of(context).pop(updatedPatrol);
      widget.onRejected(updatedPatrol);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Tolak Safety Patrol",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Silakan berikan alasan penolakan pengajuan safety patrol ini:",
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              color: subtitleTextColor,
            ),
          ),
          const SizedBox(height: 15),
          CustomTextField(
            labelText: '',
            hintText: 'Masukkan alasan penolakan',
            fillColor: whiteColor,
            keyboardType: TextInputType.text,
            controller: _commentController,
            textFieldType: CustomTextFieldType.outline,
            isTextArea: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: PrimaryButton(
                  elevation: 0,
                  color: transparentColor,
                  onPressed: _isLoading
                      ? () {}
                      : () {
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Batal',
                    style: primaryTextStyle.copyWith(
                      color: subtitleTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  elevation: 0,
                  color: redLableColor,
                  onPressed: _isLoading ? () {} : _handleReject,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Tolak',
                          style: primaryTextStyle.copyWith(
                            color: whiteColor,
                            fontWeight: semibold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
