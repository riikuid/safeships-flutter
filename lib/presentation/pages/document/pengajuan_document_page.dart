import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/category_with_doc_model.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/dashboard.dart';
import 'package:safeships_flutter/presentation/widgets/custom_text_field.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/user_provider.dart';
import 'package:safeships_flutter/theme.dart';

class PengajuanDocumentPage extends StatefulWidget {
  final CategoryWithDocModel parentModel;
  const PengajuanDocumentPage({super.key, required this.parentModel});

  @override
  State<PengajuanDocumentPage> createState() => _PengajuanDocumentPageState();
}

class _PengajuanDocumentPageState extends State<PengajuanDocumentPage> {
  PlatformFile? selectedFile;
  final GlobalKey<DropdownSearchState<ManagerModel>> _dropdownKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  int? _selectedManagerId;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionControler = TextEditingController();

  bool _isLoading = false;

  Future<void> handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).requestFocus(FocusNode());

    if (selectedFile == null) {
      Fluttertoast.showToast(msg: 'File tidak boleh kosong!');
    } else if (_titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Judul tidak boleh kosong!');
    } else if (_descriptionControler.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Deskripsi tidak boleh kosong!');
    } else if (_selectedManagerId == null) {
      Fluttertoast.showToast(msg: 'Manajer tidak boleh kosong!');
    } else {
      log("DOC PATH ${selectedFile!.path}");
      await context
          .read<DocumentProvider>()
          .ajukanDokumentasiBaru(
            categoryId: widget.parentModel.id.toString(),
            managerId: _selectedManagerId.toString(),
            title: _titleController.text,
            description: _descriptionControler.text,
            pathFile: selectedFile!.path!,
            errorCallback: (p0) {
              Fluttertoast.showToast(msg: p0.toString());
            },
          )
          .then(
        (value) {
          if (value) {
            Fluttertoast.showToast(
              msg: 'Berhasil Mengajukan Dokuemntasi Baru, Menunggu Persetujuan',
            );
            // ignore: use_build_context_synchronously
            context
                .read<DashboardProvider>()
                .setIndexByPageName('My Documentations');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const Dashboard(),
              ),
              (route) => false,
            );
          } else {
            // ThrowSnackbar().showError(context, errorText);
          }
        },
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'pdf', 'doc'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        selectedFile = file;
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
    _scrollController.dispose(); // Properly dispose of the ScrollController
    super.dispose();
    // context.read<UserProvider>().resetManager();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.read<DocumentProvider>().managers.isEmpty) {
        await context.read<DocumentProvider>().getManagers();
        setState(() {}); // Trigger rebuild untuk DropdownSearch
      }
    });
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
                Icons.description_outlined,
                color: subtitleTextColor,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                "Choose File",
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
            mainAxisSize: MainAxisSize.max, // Set to max to fill the container
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Important: set to min
                  children: [
                    const SizedBox(width: 8),
                    Icon(
                      Icons.description_outlined,
                      color: subtitleTextColor,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      // Using Flexible instead of Expanded
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
          'Pengajuan Dokumentasi Baru',
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
                      margin: const EdgeInsets.all(20),
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
                          Row(
                            children: [
                              Text(
                                'POIN KRITERIA ',
                                style: primaryTextStyle.copyWith(
                                  color: subtitleTextColor,
                                  fontWeight: semibold,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                  color: primaryColor400,
                                ),
                                child: Text(
                                  widget.parentModel.code,
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
                            height: 8,
                          ),
                          Text(
                            widget.parentModel.name,
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                            ),
                            textAlign: TextAlign.justify,
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
                            'File',
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          pickFileField(),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            labelText: 'Judul',
                            hintText: '',
                            keyboardType: TextInputType.name,
                            controller: _titleController,
                            textFieldType: CustomTextFieldType.outline,
                            fillColor: whiteColor,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            labelText: 'Deskripsi',
                            hintText: '',
                            keyboardType: TextInputType.name,
                            controller: _descriptionControler,
                            textFieldType: CustomTextFieldType.outline,
                            fillColor: whiteColor,
                            isTextArea: true,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
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
                            'Manajer',
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownSearch<ManagerModel>(
                            items: (String filter, LoadProps? loadProps) async {
                              List<ManagerModel> managers =
                                  context.read<DocumentProvider>().managers;
                              if (managers.isEmpty) {
                                await context
                                    .read<DocumentProvider>()
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
                            popupProps: PopupProps.modalBottomSheet(
                              showSelectedItems: true,
                              modalBottomSheetProps: ModalBottomSheetProps(
                                padding: const EdgeInsets.all(50),
                                backgroundColor: whiteColor,
                                elevation: 2,
                                showDragHandle: true,
                              ),
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: whiteColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                  hintText: 'Cari nama manajer',
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
                              itemBuilder: (context, ManagerModel item, bool _,
                                  bool isSelected) {
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
                                hintText: 'Pilih Manajer',
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
                                return 'Pilih salah satu manager';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ), // Add extra padding at bottom to avoid content being hidden by bottom navigation bar
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
