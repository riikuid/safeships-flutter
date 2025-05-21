import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/theme.dart';

class ApprovePatrolModal extends StatefulWidget {
  final int patrolId;
  final int userId;
  final bool isFeedbackApproval;
  final List<UserModel> users;
  final Function(SafetyPatrolModel) onApproved;

  const ApprovePatrolModal({
    super.key,
    required this.patrolId,
    required this.isFeedbackApproval,
    required this.users,
    required this.onApproved,
    required this.userId,
  });

  @override
  State<ApprovePatrolModal> createState() => _ApprovePatrolModalState();
}

class _ApprovePatrolModalState extends State<ApprovePatrolModal> {
  UserModel? _selectedUser;
  DateTime? _selectedDeadline;
  bool _isLoading = false;

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
            "Setujui Safety Patrol",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            (!widget.isFeedbackApproval && widget.users.isNotEmpty)
                ? "Pilih penindak dan tentukan tenggat waktu untuk pengajuan ini:"
                : widget.isFeedbackApproval
                    ? "Apakah Anda yakin ingin menyetujui feedback ini?"
                    : "Apakah Anda yakin ingin menyetujui pengajuan safety patrol ini?",
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              color: subtitleTextColor,
            ),
          ),
          const SizedBox(height: 15),
          if (!widget.isFeedbackApproval && widget.users.isNotEmpty) ...[
            DropdownSearch<UserModel>(
              items: (String filter, LoadProps? _) {
                List<UserModel> users = widget.users;
                return users
                    .where((user) =>
                        user.name.toLowerCase().contains(filter.toLowerCase()))
                    .toList();
              },
              compareFn: (UserModel? a, UserModel? b) => a?.id == b?.id,
              itemAsString: (UserModel? user) => user?.name ?? '',
              onChanged: (UserModel? selectedUser) {
                setState(() {
                  _selectedUser = selectedUser;
                });
              },
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: whiteColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    hintText: 'Cari nama pengguna',
                    hintStyle: primaryTextStyle.copyWith(
                      color: blackColor.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: medium,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                      borderSide: BorderSide(
                        color: disabledColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      borderSide: BorderSide(
                        color: primaryColor500,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context, UserModel item, bool isSelected, _) {
                  return ListTile(
                    leading: Icon(
                      Icons.person_2,
                      size: 20,
                      color: isSelected ? primaryColor800 : subtitleTextColor,
                    ),
                    title: Text(
                      item.name,
                      style: primaryTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: isSelected ? semibold : regular,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: primaryColor50,
                  );
                },
              ),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: whiteColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  hintText: 'Pilih Penindak',
                  hintStyle: primaryTextStyle.copyWith(
                    color: blackColor.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    borderSide: BorderSide(
                      color: disabledColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    borderSide: BorderSide(
                      color: primaryColor500,
                      width: 2,
                    ),
                  ),
                ),
              ),
              validator: (UserModel? value) {
                if (value == null && !widget.isFeedbackApproval) {
                  return 'Pilih salah satu penindak';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDeadline = pickedDate;
                        });
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: disabledColor),
                  borderRadius: BorderRadius.circular(8),
                  color: whiteColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDeadline == null
                          ? 'Pilih Tenggat Waktu'
                          : DateFormat('dd MMMM yyyy')
                              .format(_selectedDeadline!),
                      style: primaryTextStyle.copyWith(
                        fontSize: 12,
                        color: _selectedDeadline == null
                            ? blackColor.withOpacity(0.5)
                            : blackColor,
                        fontWeight: medium,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: subtitleTextColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
                          'Setujui',
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

  void _handleApprove() async {
    if (!widget.isFeedbackApproval && widget.users.isNotEmpty) {
      if (_selectedUser == null) {
        Fluttertoast.showToast(msg: "Pilih penindak terlebih dahulu");
        return;
      }
      if (_selectedDeadline == null) {
        Fluttertoast.showToast(msg: "Pilih tenggat waktu terlebih dahulu");
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<SafetyPatrolProvider>();
      SafetyPatrolModel updatedPatrol;
      if (!widget.isFeedbackApproval && widget.users.isNotEmpty) {
        updatedPatrol = await provider.approveSafetyPatrol(
          userId: widget.userId,
          patrolId: widget.patrolId,
          actorId: _selectedUser!.id.toString(),
          deadline: DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      } else if (widget.isFeedbackApproval) {
        updatedPatrol = await provider.approveFeedback(
          userId: widget.userId,
          feedbackId: widget.patrolId,
          patrolId: widget.patrolId, // This should be the actual patrol ID
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      } else {
        updatedPatrol = await provider.approveSafetyPatrol(
          userId: widget.userId,
          patrolId: widget.patrolId,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      }

      Navigator.of(context).pop(updatedPatrol);
      widget.onApproved(updatedPatrol);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
