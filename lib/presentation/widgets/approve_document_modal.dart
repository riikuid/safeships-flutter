import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/theme.dart';

class ApproveDocumentDialog extends StatefulWidget {
  final int documentId;
  final Function onApproved;
  final String documentTitle;

  const ApproveDocumentDialog({
    Key? key,
    required this.documentId,
    required this.onApproved,
    required this.documentTitle,
  }) : super(key: key);

  @override
  State<ApproveDocumentDialog> createState() => _ApproveDocumentDialogState();
}

class _ApproveDocumentDialogState extends State<ApproveDocumentDialog> {
  bool _isLoading = false;

  void _handleApprove() async {
    setState(() {
      _isLoading = true;
    });

    await context
        .read<DocumentProvider>()
        .approveDocument(
          documentId: widget.documentId,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        )
        .then(
      (value) {
        if (value) {
          Navigator.of(context).pop();
          widget.onApproved();
        }
        setState(() {
          _isLoading = false;
        });
      },
    );
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
      padding: const EdgeInsets.all(25),
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
          Icon(
            Icons.check_circle,
            color: greenLableColor,
            size: 60,
          ),
          const SizedBox(height: 15),
          Text(
            "Konfirmasi Persetujuan",
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semibold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Apakah Anda yakin ingin menyetujui dokumen '${widget.documentTitle}'?",
            textAlign: TextAlign.center,
            style: primaryTextStyle.copyWith(
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  color: greenLableColor,
                  onPressed: _isLoading ? () {} : _handleApprove,
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
                          'Setuju',
                          style: primaryTextStyle.copyWith(
                            color: whiteColor,
                            fontWeight: semibold,
                          ),
                        ),
                ),
              ),
              // ElevatedButton(
              //   onPressed: _isLoading ? null : _handleApprove,
              //   style: ElevatedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     elevation: 0,
              //     backgroundColor: greenLableColor,
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 24,
              //       vertical: 12,
              //     ),
              //   ),
              //   child: _isLoading
              //       ? const SizedBox(
              //           width: 20,
              //           height: 20,
              //           child: CircularProgressIndicator(
              //             color: Colors.white,
              //             strokeWidth: 2,
              //           ),
              //         )
              //       : Text(
              //           "Setujui",
              //           style: primaryTextStyle.copyWith(
              //             fontWeight: semibold,
              //             color: whiteColor,
              //             fontSize: 14,
              //           ),
              //         ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
