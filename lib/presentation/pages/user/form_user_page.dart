import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/presentation/widgets/custom_text_field.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/user_provider.dart';
import 'package:safeships_flutter/theme.dart';

class FormUserPage extends StatefulWidget {
  final UserModel?
      user; // Null untuk create, non-null untuk edit atau reset password
  final bool isResetPassword;
  const FormUserPage({super.key, this.user, this.isResetPassword = false});

  @override
  State<FormUserPage> createState() => _FormUserPageState();
}

class _FormUserPageState extends State<FormUserPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.user?.role ?? 'user';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    if (widget.isResetPassword) {
      if (_passwordController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'Password tidak boleh kosong');
        isValid = false;
      } else if (_passwordController.text.length < 8) {
        Fluttertoast.showToast(msg: 'Password minimal 8 karakter');
        isValid = false;
      }
    } else {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          (_selectedRole == null && !widget.isResetPassword)) {
        Fluttertoast.showToast(msg: 'Data tidak boleh kosong');
        isValid = false;
      } else if (!_emailController.text.contains('@') ||
          !_emailController.text.contains('.')) {
        Fluttertoast.showToast(msg: 'Masukkan email yang valid');
        isValid = false;
      } else if (widget.user == null && _passwordController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'Password tidak boleh kosong');
        isValid = false;
      } else if (_passwordController.text.isNotEmpty &&
          _passwordController.text.length < 8) {
        Fluttertoast.showToast(msg: 'Password minimal 8 karakter');
        isValid = false;
      }
    }
    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    final isEditMode = widget.user != null && !widget.isResetPassword;

    try {
      bool success;
      if (widget.isResetPassword) {
        if (widget.user == null) {
          Fluttertoast.showToast(
              msg: 'Pengguna tidak valid untuk reset password');
          return;
        }
        success = await userProvider.resetPassword(
          id: widget.user!.id,
          password: _passwordController.text,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      } else if (isEditMode) {
        success = await userProvider.updateUser(
          id: widget.user!.id,
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
          role: _selectedRole!,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      } else {
        success = await userProvider.createUser(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole!,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: error.toString());
          },
        );
      }

      if (success) {
        Fluttertoast.showToast(
          msg: widget.isResetPassword
              ? 'Password berhasil direset'
              : isEditMode
                  ? 'Pengguna berhasil diperbarui'
                  : 'Pengguna berhasil dibuat',
        );
        Navigator.pop(context);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.user != null && !widget.isResetPassword;
    final isCreateMode = widget.user == null && !widget.isResetPassword;

    return Scaffold(
      backgroundColor: greyBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: whiteColor),
        surfaceTintColor: transparentColor,
        backgroundColor: primaryColor500,
        title: Text(
          widget.isResetPassword
              ? 'Reset Password'
              : isEditMode
                  ? 'Edit Pengguna'
                  : 'Tambah Pengguna',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semibold,
            color: whiteColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textFieldType: CustomTextFieldType.outline,
                  fillColor: whiteColor,
                  enabled: !widget.isResetPassword,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: 'Email',
                  hintText: 'Masukkan email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textFieldType: CustomTextFieldType.outline,
                  fillColor: whiteColor,
                  enabled: !widget.isResetPassword,
                ),
                SizedBox(height: 15),
                Text(
                  'Role',
                  style: primaryTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
                SizedBox(height: 5),
                if (widget.isResetPassword)
                  CustomTextField(
                    keyboardType: TextInputType.name,
                    labelText: '',
                    hintText:
                        _selectedRole?.replaceAll('_', ' ').toUpperCase() ?? '',
                    controller: TextEditingController(
                      text: _selectedRole?.replaceAll('_', ' ').toUpperCase() ??
                          '',
                    ),
                    textFieldType: CustomTextFieldType.outline,
                    fillColor: whiteColor,
                    enabled: false,
                  )
                else
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whiteColor,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                    value: _selectedRole,
                    items: ['manager', 'user']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role.replaceAll('_', ' ').toUpperCase(),
                                style: primaryTextStyle.copyWith(fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: widget.isResetPassword
                        ? null
                        : (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                  ),
                SizedBox(height: 15),
                if (!isEditMode || widget.isResetPassword)
                  CustomTextField(
                    labelText:
                        widget.isResetPassword ? 'Password Baru' : 'Password',
                    hintText: widget.isResetPassword
                        ? 'Masukkan password baru'
                        : 'Masukkan password',
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    textFieldType: CustomTextFieldType.outline,
                    fillColor: whiteColor,
                    isPassword: true,
                    isObscure: true,
                  ),
                SizedBox(height: 20),
                PrimaryButton(
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  child: Text(
                    widget.isResetPassword
                        ? 'Reset Password'
                        : isEditMode
                            ? 'Perbarui'
                            : 'Buat',
                    style: primaryTextStyle.copyWith(
                      color: whiteColor,
                      fontWeight: semibold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
