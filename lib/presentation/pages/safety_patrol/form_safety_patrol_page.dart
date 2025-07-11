import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';
import 'package:safeships_flutter/presentation/widgets/custom_text_field.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/theme.dart';

enum FormMode {
  pengajuan,
  feedback,
}

class FormSafetyPatrolPage extends StatefulWidget {
  final FormMode mode;
  final int? patrolId; // Required for feedback mode

  const FormSafetyPatrolPage({
    super.key,
    required this.mode,
    this.patrolId,
  });

  @override
  State<FormSafetyPatrolPage> createState() => _FormSafetyPatrolPageState();
}

class _FormSafetyPatrolPageState extends State<FormSafetyPatrolPage> {
  PlatformFile? selectedFile;
  final GlobalKey<DropdownSearchState<ManagerModel>> _managerDropdownKey =
      GlobalKey();
  final GlobalKey<DropdownSearchState<String>> _typeDropdownKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  int? _selectedManagerId;
  String? _selectedType;

  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  bool _isLoading = false;

  Future<void> handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).requestFocus(FocusNode());

    // Validation
    if (selectedFile == null) {
      Fluttertoast.showToast(msg: 'Gambar tidak boleh kosong!');
    } else if (_dateController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: widget.mode == FormMode.pengajuan
              ? 'Tanggal laporan tidak boleh kosong!'
              : 'Tanggal feedback tidak boleh kosong!');
    } else if (widget.mode == FormMode.pengajuan && _selectedType == null) {
      Fluttertoast.showToast(msg: 'Tipe laporan tidak boleh kosong!');
    } else if (widget.mode == FormMode.pengajuan &&
        _locationController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Lokasi tidak boleh kosong!');
    } else if (_descriptionController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Deskripsi tidak boleh kosong!');
    } else if (widget.mode == FormMode.pengajuan &&
        _selectedManagerId == null) {
      Fluttertoast.showToast(msg: 'Manajemen tidak boleh kosong!');
    } else if (widget.mode == FormMode.feedback && widget.patrolId == null) {
      Fluttertoast.showToast(msg: 'Patrol ID tidak valid!');
    } else {
      try {
        SafetyPatrolModel? result;
        if (widget.mode == FormMode.pengajuan) {
          result =
              await context.read<SafetyPatrolProvider>().submitSafetyPatrol(
                    managerId: _selectedManagerId.toString(),
                    reportDate: _dateController.text,
                    pathFile: selectedFile!.path!,
                    type: _selectedType!,
                    description: _descriptionController.text,
                    location: _locationController.text,
                    errorCallback: (p0) {
                      Fluttertoast.showToast(msg: p0.toString());
                    },
                  );
          if (result != null) {
            Fluttertoast.showToast(
              msg: 'Berhasil Mengajukan Laporan Baru, Menunggu Persetujuan',
            );
            // Navigate back with result
            Navigator.pop(context, result);
          }
        } else {
          result = await context.read<SafetyPatrolProvider>().submitFeedback(
                patrolId: widget.patrolId!,
                feedbackDate: _dateController.text,
                pathFile: selectedFile!.path!,
                description: _descriptionController.text,
                errorCallback: (p0) {
                  Fluttertoast.showToast(msg: p0.toString());
                },
              );
          if (result != null) {
            Fluttertoast.showToast(
              msg: 'Berhasil Mengirim Feedback',
            );
            // Navigate back with result
            Navigator.pop(context, result);
          }
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        selectedFile = file;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  void _deleteFile() {
    setState(() {
      selectedFile = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
    if (widget.mode == FormMode.pengajuan) {
      context.read<SafetyPatrolProvider>().resetManagers();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.mode == FormMode.pengajuan) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.read<SafetyPatrolProvider>().managers.isEmpty) {
          await context.read<SafetyPatrolProvider>().getManagers();
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget pickFileField() {
      if (selectedFile == null) {
        return PrimaryButton(
          elevation: 1,
          width: double.infinity,
          height: 50,
          color: whiteColor,
          borderColor: disabledColor,
          onPressed: _pickFile,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: subtitleTextColor,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                "Choose Image",
                style: primaryTextStyle.copyWith(
                  color: subtitleTextColor,
                  fontWeight: semibold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: whiteColor,
            border: Border.all(color: disabledColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Icon(
                      Icons.image_outlined,
                      color: subtitleTextColor,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        selectedFile!.name,
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
              IconButton(
                icon: Icon(Icons.close, color: subtitleTextColor, size: 18),
                onPressed: _deleteFile,
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: greyBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: whiteColor,
        ),
        surfaceTintColor: transparentColor,
        backgroundColor: primaryColor500,
        title: Text(
          widget.mode == FormMode.pengajuan
              ? 'Pengajuan Laporan Safety Patrol'
              : 'Submit Feedback Safety Patrol',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semibold,
            color: whiteColor,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                            'Gambar',
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          pickFileField(),
                          const SizedBox(height: 15),
                          Text(
                            widget.mode == FormMode.pengajuan
                                ? 'Tanggal Laporan'
                                : 'Tanggal Feedback',
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: _pickDate,
                            child: AbsorbPointer(
                              child: CustomTextField(
                                labelText: '',
                                hintText: 'Pilih tanggal',
                                keyboardType: TextInputType.datetime,
                                controller: _dateController,
                                textFieldType: CustomTextFieldType.outline,
                                fillColor: whiteColor,
                              ),
                            ),
                          ),
                          if (widget.mode == FormMode.pengajuan) ...[
                            const SizedBox(height: 15),
                            Text(
                              'Tipe Laporan',
                              style: primaryTextStyle.copyWith(
                                color: blackColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: whiteColor,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: disabledColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: primaryColor500, width: 2),
                                ),
                              ),
                              value: _selectedType,
                              items: ['unsafe_condition', 'unsafe_action']
                                  .map((role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(
                                          role
                                              .replaceAll('_', ' ')
                                              .toUpperCase(),
                                          style: primaryTextStyle.copyWith(
                                              fontSize: 14),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              labelText: 'Lokasi',
                              hintText: '',
                              keyboardType: TextInputType.text,
                              controller: _locationController,
                              textFieldType: CustomTextFieldType.outline,
                              fillColor: whiteColor,
                            ),
                          ],
                          const SizedBox(height: 15),
                          CustomTextField(
                            labelText: 'Deskripsi',
                            hintText: '',
                            keyboardType: TextInputType.text,
                            controller: _descriptionController,
                            textFieldType: CustomTextFieldType.outline,
                            fillColor: whiteColor,
                            isTextArea: true,
                          ),
                        ],
                      ),
                    ),
                    if (widget.mode == FormMode.pengajuan) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
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
                              'Manajemen',
                              style: primaryTextStyle.copyWith(
                                color: blackColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            DropdownSearch<ManagerModel>(
                              key: _managerDropdownKey,
                              items:
                                  (String filter, LoadProps? loadProps) async {
                                List<ManagerModel> managers = context
                                    .read<SafetyPatrolProvider>()
                                    .managers;
                                if (managers.isEmpty) {
                                  await context
                                      .read<SafetyPatrolProvider>()
                                      .getManagers();
                                }
                                return managers
                                    .where((user) => user.name
                                        .toLowerCase()
                                        .contains(filter.toLowerCase()))
                                    .toList();
                              },
                              compareFn: (ManagerModel? a, ManagerModel? b) =>
                                  a?.id == b?.id,
                              itemAsString: (ManagerModel? user) =>
                                  user?.name ?? '',
                              onChanged: (ManagerModel? selectedUser) {
                                if (selectedUser != null) {
                                  setState(() {
                                    _selectedManagerId = selectedUser.id;
                                  });
                                }
                              },
                              popupProps: PopupProps.menu(
                                showSelectedItems: true,
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: whiteColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                    hintText: 'Cari nama manajemen',
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
                                itemBuilder: (context, ManagerModel item,
                                    bool _, bool isSelected) {
                                  return ListTile(
                                    leading: Icon(
                                      Icons.person_2,
                                      size: 20,
                                      color: isSelected
                                          ? primaryColor800
                                          : subtitleTextColor,
                                    ),
                                    title: Text(
                                      item.name,
                                      style: primaryTextStyle.copyWith(
                                        fontSize: 12,
                                        fontWeight:
                                            isSelected ? semibold : regular,
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
                                  hintText: 'Pilih Manajemen',
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
                              validator: (ManagerModel? value) {
                                if (value == null) {
                                  return 'Pilih salah satu manajer';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
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
        child: PrimaryButton(
          isLoading: _isLoading,
          child: Text(
            'Submit',
            style: primaryTextStyle.copyWith(
              color: whiteColor,
              fontWeight: semibold,
            ),
          ),
          onPressed: handleSubmit,
        ),
      ),
    );
  }
}
