import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_test_page.dart';
import 'package:safeships_flutter/presentation/widgets/custom_text_field.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/services/safety_induction_service.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyInductionFormPage extends StatefulWidget {
  const SafetyInductionFormPage({super.key});

  @override
  State<SafetyInductionFormPage> createState() =>
      _SafetyInductionFormPageState();
}

class _SafetyInductionFormPageState extends State<SafetyInductionFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Nama tidak boleh kosong!');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (_selectedType == null) {
      Fluttertoast.showToast(msg: 'Tipe tidak boleh kosong!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final provider = context.read<SafetyInductionProvider>();
      final induction = await provider.createSafetyInduction(
        name: _nameController.text,
        type: _selectedType!,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        phoneNumber:
            _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        errorCallback: (error) {
          if (error is PendingSubmissionException && mounted) {
            _showPendingSubmissionDialog(provider);
          } else {
            Fluttertoast.showToast(msg: error.toString());
          }
        },
      );
      if (induction != null && mounted) {
        Fluttertoast.showToast(msg: 'Formulir berhasil disubmit!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SafetyInductionTestPage(inductionId: induction.id),
          ),
        );
      }
    } catch (e) {
      // Error sudah ditangani di errorCallback
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPendingSubmissionDialog(SafetyInductionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pengajuan Belum Selesai'),
        content: Text(
          'Anda memiliki pengajuan aktif:\n'
          'Nama: ${provider.pendingSubmission?.name}\n'
          'Tipe: ${provider.pendingSubmission?.type}\n'
          'Status: ${provider.pendingSubmission?.status}',
        ),
        actions: provider.pendingOptions
            .map((option) => TextButton(
                  onPressed: () {
                    if (option == 'Buat Pengajuan Baru') {
                      provider
                          .createSafetyInduction(
                        name: _nameController.text,
                        type: _selectedType!,
                        address: _addressController.text.isNotEmpty
                            ? _addressController.text
                            : null,
                        phoneNumber: _phoneController.text.isNotEmpty
                            ? _phoneController.text
                            : null,
                        email: _emailController.text.isNotEmpty
                            ? _emailController.text
                            : null,
                        forceCreate: true,
                        errorCallback: (error) {
                          Fluttertoast.showToast(msg: error.toString());
                        },
                      )
                          .then((induction) {
                        Navigator.pop(context); // Tutup dialog
                        Fluttertoast.showToast(
                            msg: 'Formulir berhasil disubmit!');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SafetyInductionTestPage(
                                inductionId: induction.id),
                          ),
                        );
                      });
                    } else if (option == 'Lanjutkan Pengajuan Sebelumnya') {
                      provider.continuePendingSubmission().then((_) {
                        Navigator.pop(context); // Tutup dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SafetyInductionTestPage(
                                inductionId: provider.currentInduction!.id),
                          ),
                        );
                      });
                    }
                  },
                  child: Text(option),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: greyBackgroundColor,
          appBar: AppBar(
            iconTheme: IconThemeData(color: whiteColor),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              'Formulir Safety Induction',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
          ),
          bottomNavigationBar: Container(
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
            child: PrimaryButton(
              isLoading: _isLoading,
              color: primaryColor500,
              borderColor: primaryColor500,
              elevation: 0,
              child: Text(
                'Submit',
                style: primaryTextStyle.copyWith(
                  color: whiteColor,
                  fontWeight: semibold,
                ),
              ),
              onPressed: _handleSubmit,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      keyboardType: TextInputType.name,
                      labelText: 'Nama',
                      hintText: 'Masukkan nama',
                      controller: _nameController,
                      textFieldType: CustomTextFieldType.outline,
                      fillColor: whiteColor,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Tipe',
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: disabledColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: primaryColor500, width: 2),
                        ),
                      ),
                      value: _selectedType,
                      items: ['Karyawan', 'Mahasiswa', 'Tamu', 'Kontraktor']
                          .map((type) => DropdownMenuItem(
                                value: type.toLowerCase(),
                                child: Text(
                                  type,
                                  style:
                                      primaryTextStyle.copyWith(fontSize: 14),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      hint: Text(
                        'Pilih tipe',
                        style: primaryTextStyle.copyWith(
                          color: subtitleTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      keyboardType: TextInputType.streetAddress,
                      labelText: 'Alamat (Opsional)',
                      hintText: 'Masukkan alamat',
                      controller: _addressController,
                      textFieldType: CustomTextFieldType.outline,
                      fillColor: whiteColor,
                      isTextArea: true,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: 'Nomor HP (Opsional)',
                      hintText: 'Masukkan nomor HP',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textFieldType: CustomTextFieldType.outline,
                      fillColor: whiteColor,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: 'Email (Opsional)',
                      hintText: 'Masukkan email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textFieldType: CustomTextFieldType.outline,
                      fillColor: whiteColor,
                    ),
                  ],
                ),
              ),
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
