// Modal untuk Konfirmasi Penghapusan
import 'package:flutter/material.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/theme.dart';

class UserDeleteModal extends StatelessWidget {
  final UserModel user;
  final VoidCallback onConfirm;

  const UserDeleteModal({
    super.key,
    required this.user,
    required this.onConfirm,
  });

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
            "Hapus Pengguna",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Apakah anda yakin menghapus pengguna '${user.name}'?",
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              color: subtitleTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // TextButton(
              //   onPressed:
              //       _isLoading ? null : () => Navigator.of(context).pop(),
              //   child: const Text("Batal"),
              // ),
              Expanded(
                child: PrimaryButton(
                  elevation: 0,
                  color: transparentColor,
                  onPressed: () {
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
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: PrimaryButton(
                  elevation: 0,
                  color: redLableColor,
                  onPressed: onConfirm,
                  child: Text(
                    'Hapus',
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
