// ignore_for_file: public_member_api_docs, sort_constructors_first
// Modal untuk Detail Pengguna
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/theme.dart';

class UserDetailModal extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResetPassword;
  const UserDetailModal({
    Key? key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      titlePadding: EdgeInsets.zero,
      title: Container(
        alignment: Alignment.center,
        height: 118,
        padding: const EdgeInsets.only(bottom: 30),
        decoration: const BoxDecoration(
          // color: CustomColor.primaryColor500,
          image: DecorationImage(
            image: AssetImage(
              'assets/header_modal.png',
            ),
            fit: BoxFit.fitWidth,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
        child: Text(
          'DETAIL USER',
          style: primaryTextStyle.copyWith(
            fontFamily: 'poppins_bold',
            fontSize: 18,
            fontWeight: semibold,
            color: whiteColor,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: subtitleTextColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Nama',
                  style: primaryTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: regular,
                    color: subtitleTextColor,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              user.name,
              style: primaryTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semibold,
                color: primaryColor900,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Icon(
                  Icons.mail,
                  color: subtitleTextColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Email',
                  style: primaryTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: regular,
                    color: subtitleTextColor,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              user.email,
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: semibold,
                color: primaryColor900,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: subtitleTextColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Role',
                  style: primaryTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                    color: subtitleTextColor,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              user.role.replaceAll('_', ' ').toUpperCase(),
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: semibold,
                color: primaryColor900,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: user.role == 'super_admin'
          ? null
          : [
              PrimaryButton(
                elevation: 0,
                height: 40,
                color: primaryColor500,
                radius: 100,
                child: Text(
                  'Reset Password',
                  style: primaryTextStyle.copyWith(
                    fontSize: 12,
                    color: whiteColor,
                    fontWeight: semibold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onResetPassword();
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      elevation: 0,
                      height: 40,
                      color: transparentColor,
                      radius: 100,
                      borderColor: redLableColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            color: redLableColor,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Hapus',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              color: redLableColor,
                              fontWeight: semibold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: PrimaryButton(
                      elevation: 0,
                      height: 40,
                      color: whiteColor,
                      borderColor: primaryColor500,
                      radius: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: primaryColor500,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Edit',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              color: primaryColor500,
                              fontWeight: semibold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit();
                      },
                    ),
                  ),
                ],
              ),

              // Align(
              //   alignment: Alignment.center,
              //   child: InkWell(
              //     onTap: () => Navigator.of(context).pop(),
              //     child: Text(
              //       'Close',
              //       style: primaryTextStyle.copyWith(
              //         color: CustomColor.subtitleTextColor,
              //       ),
              //     ),
              //   ),
              // ),
              // ElevatedButton(
              //   onPressed: () {

              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: CustomColor.primaryColor900,
              //     foregroundColor: CustomColor.whiteColor,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   child: const Text('Edit Activity'),
              // ),
            ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: primaryTextStyle.copyWith(
              fontSize: 12,
              color: subtitleTextColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              fontWeight: medium,
              color: blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
