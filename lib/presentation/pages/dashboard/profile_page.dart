import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/auth_model.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  void _showEditProfileDialog(BuildContext context, AuthModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Edit Profil',
                style: primaryTextStyle.copyWith(fontWeight: semibold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: primaryTextStyle.copyWith(color: redLableColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor500,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setDialogState(() {
                            _isLoading = true;
                          });
                          final provider = context.read<AuthProvider>();
                          bool success = await provider.updateProfile(
                            name: nameController.text,
                            email: emailController.text,
                            errorCallback: (error) {
                              Fluttertoast.showToast(msg: error.toString());
                            },
                          );
                          setDialogState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                          if (success) {
                            Fluttertoast.showToast(
                                msg: 'Profil berhasil diperbarui');
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: whiteColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: primaryTextStyle.copyWith(color: whiteColor),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetPasswordDialog(BuildContext context, int userId) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Reset Kata Sandi',
                style: primaryTextStyle.copyWith(fontWeight: semibold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: primaryTextStyle.copyWith(color: redLableColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor500,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            Fluttertoast.showToast(
                                msg: 'Kata sandi tidak cocok');
                            return;
                          }
                          if (passwordController.text.length < 8) {
                            Fluttertoast.showToast(
                                msg: 'Kata sandi harus minimal 8 karakter');
                            return;
                          }
                          setDialogState(() {
                            _isLoading = true;
                          });
                          final provider = context.read<AuthProvider>();
                          bool success = await provider.resetPassword(
                            userId: userId,
                            password: passwordController.text,
                            errorCallback: (error) {
                              Fluttertoast.showToast(msg: error.toString());
                            },
                          );
                          setDialogState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                          if (success) {
                            Fluttertoast.showToast(
                                msg: 'Kata sandi berhasil direset');
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: whiteColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: primaryTextStyle.copyWith(color: whiteColor),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: AppBar(
        iconTheme: IconThemeData(color: whiteColor),
        surfaceTintColor: transparentColor,
        backgroundColor: primaryColor500,
        title: Text(
          'Profil',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semibold,
            color: whiteColor,
          ),
        ),
      ),
      body: user == null
          ? Center(
              child: Text(
                'Gagal memuat profil',
                style: primaryTextStyle.copyWith(color: subtitleTextColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama',
                          style: primaryTextStyle.copyWith(
                            color: subtitleTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.name,
                          style: primaryTextStyle.copyWith(
                            color: blackColor,
                            fontSize: 16,
                            fontWeight: semibold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Email',
                          style: primaryTextStyle.copyWith(
                            color: subtitleTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.email,
                          style: primaryTextStyle.copyWith(
                            color: blackColor,
                            fontSize: 16,
                            fontWeight: semibold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Role',
                          style: primaryTextStyle.copyWith(
                            color: subtitleTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.role.replaceAll('_', ' ').toUpperCase(),
                          style: primaryTextStyle.copyWith(
                            color: blackColor,
                            fontSize: 16,
                            fontWeight: semibold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(100),
                        ),
                        side: BorderSide(
                          color: primaryColor500,
                        ),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _showEditProfileDialog(context, user),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          color: primaryColor500,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Edit Profil',
                          style: primaryTextStyle.copyWith(
                            color: primaryColor500,
                            fontWeight: semibold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor500,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _showResetPasswordDialog(context, user.id),
                    child: Text(
                      'Reset Kata Sandi',
                      style: primaryTextStyle.copyWith(
                        color: whiteColor,
                        fontWeight: semibold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
