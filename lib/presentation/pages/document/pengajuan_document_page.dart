import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/category_with_doc_model.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/providers/user_provider.dart';
import 'package:safeships_flutter/theme.dart';

class PengajuanDocumentPage extends StatefulWidget {
  final CategoryWithDocModel parentModel;
  const PengajuanDocumentPage({super.key, required this.parentModel});

  @override
  State<PengajuanDocumentPage> createState() => _PengajuanDocumentPageState();
}

class _PengajuanDocumentPageState extends State<PengajuanDocumentPage> {
  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.all(
                  const Radius.circular(12.0),
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
                      // fontWeight: semibold,
                      color: subtitleTextColor,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: DropdownSearch<UserModel>(
                items: (String filter, s) async {
                  List<UserModel> managers =
                      context.read<UserProvider>().managers;
                  // Jika managers kosong, panggil getManagers
                  if (managers.isEmpty) {
                    await context.read<UserProvider>().getManagers();
                  }
                  // Filter berdasarkan nama jika diperlukan
                  return managers
                      .where((user) => user.name
                          .toLowerCase()
                          .contains(filter.toLowerCase()))
                      .toList();
                },
                itemAsString: (UserModel? user) =>
                    user?.name ?? '', // Menampilkan nama
                onChanged: (UserModel? selectedUser) {
                  if (selectedUser != null) {
                    // Gunakan selectedUser.id untuk keperluan Anda
                    print('Selected ID: ${selectedUser.id}');
                  }
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: 'Cari Manager',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  itemBuilder: (context, UserModel item, bool isSelected, _) {
                    return ListTile(
                      title: Text(item.name),
                      selected: isSelected,
                    );
                  },
                ),
                // dropdownDecoratorProps: DropDownDecoratorProps(
                //   dropdownSearchDecoration: InputDecoration(
                //     labelText: 'Pilih Manager',
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                validator: (UserModel? value) {
                  if (value == null) {
                    return 'Pilih salah satu manager';
                  }
                  return null;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
