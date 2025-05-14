import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/presentation/pages/user/form_user_page.dart';
import 'package:safeships_flutter/presentation/widgets/user_delete_modal.dart';
import 'package:safeships_flutter/presentation/widgets/user_detail_modal.dart';
import 'package:safeships_flutter/providers/user_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch users on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsers();
    });
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<UserProvider>().getUsers(
      errorCallback: (error) {
        Fluttertoast.showToast(msg: error.toString());
      },
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _showDetailModal(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailModal(
        user: user,
        onDelete: () {
          _showDeleteConfirmation(user);
        },
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormUserPage(
                user: user,
                isResetPassword: false,
              ),
            ),
          );
        },
        onResetPassword: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormUserPage(
                user: user,
                isResetPassword: true,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDeleteModal(
        user: user,
        onConfirm: () async {
          await context
              .read<UserProvider>()
              .deleteUser(
                id: user.id,
                errorCallback: (error) {
                  Fluttertoast.showToast(msg: error.toString());
                },
              )
              .then(
            (value) {
              if (value) {
                Fluttertoast.showToast(msg: 'Pengguna berhasil dihapus');
                Navigator.pop(context); // Close modal
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget roleWidget(String role) {
      // Konfigurasi berdasarkan role
      IconData icon;
      Color backgroundColor;
      String label;

      switch (role.toLowerCase()) {
        case 'manager':
          icon = Icons.engineering_rounded;
          backgroundColor =
              orangeLableColor; // pastikan variabel ini sudah didefinisikan
          label = 'MANAGER';
          break;
        case 'super_admin':
          icon = Icons.admin_panel_settings_rounded;
          backgroundColor = redLableColor;
          label = 'SUPER ADMIN';
          break;
        case 'user':
          icon = Icons.person_rounded;
          backgroundColor = primaryColor500;
          label = 'USER';
          break;
        default:
          icon = Icons.help_outline_rounded;
          backgroundColor = Colors.grey;
          label = role.toUpperCase(); // fallback
      }

      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(100.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              color: whiteColor,
              size: 12,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: primaryTextStyle.copyWith(
                fontSize: 10,
                color: whiteColor,
                fontWeight: semibold,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: greyBackgroundColor,
      // appBar: AppBar(
      //   iconTheme: IconThemeData(color: whiteColor),
      //   surfaceTintColor: transparentColor,
      //   backgroundColor: greyBackgroundColor,
      //   title: Text(
      //     'Manajemen Pengguna',
      //     style: primaryTextStyle.copyWith(
      //       fontSize: 18,
      //       fontWeight: semibold,
      //       // color: black,
      //     ),
      //   ),
      // ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return Center(
                child: CircularProgressIndicator(color: primaryColor500));
          }
          if (provider.users.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada pengguna ditemukan',
                style: primaryTextStyle.copyWith(
                    fontSize: 16, color: subtitleTextColor),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _fetchUsers,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                return Card(
                  color: whiteColor,
                  elevation: 0,
                  margin: EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: primaryTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semibold,
                              color: primaryColor900,
                            ),
                          ),
                        ),
                        roleWidget(user.role),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          user.email,
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            color: blackColor,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            Text(
                              'Last Update: ',
                              style: primaryTextStyle.copyWith(
                                fontSize: 10,
                                color: subtitleTextColor,
                              ),
                            ),
                            Text(
                              AppHelper.formatDateToString(user.updatedAt),
                              style: primaryTextStyle.copyWith(
                                fontSize: 10,
                                color: blackColor,
                                fontWeight: semibold,
                              ),
                            ),
                          ],
                        ),

                        // const SizedBox(
                        //   height: 3,
                        // ),
                        // Text(
                        //   'ROLE: ${user.role.replaceAll('_', ' ').toUpperCase()}',
                        //   style: primaryTextStyle.copyWith(
                        //     fontSize: 12,
                        //     color: subtitleTextColor,
                        //   ),
                        // ),
                      ],
                    ),

                    // trailing:
                    onTap: () => _showDetailModal(user),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor500,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormUserPage(
                isResetPassword: false,
              ),
            ),
          );
        },
        child: Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}
