import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/main.dart'; // Impor navigatorKey
import 'package:safeships_flutter/presentation/pages/auth/login_page.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    var dashboardProvider = Provider.of<DashboardProvider>(context);

    Future<void> _handleLogout() async {
      final authProvider = context.read<AuthProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      try {
        await authProvider.logout(
          errorCallback: (error) {
            log('Logout error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout failed: $error')),
            );
          },
        );
        log('Logout successful, navigating to LoginPage');

        // Reset menu
        dashboardProvider.resetMenu();

        // Navigasi menggunakan navigatorKey
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false, // Hapus semua rute sebelumnya
          );
        } else {
          log('Error: navigatorKey.currentState is null');
        }
      } catch (e) {
        log('Unexpected logout error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    }

    return Drawer(
      child: Container(
        color: whiteColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: primaryColor800,
                    ),
                    child: Text(
                      'SafeShips Menu',
                      style: primaryTextStyle.copyWith(
                        color: whiteColor,
                        fontWeight: semibold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (dashboardProvider.dashboardMenu.isNotEmpty)
                    ...dashboardProvider.dashboardMenu.asMap().entries.map(
                      (entry) {
                        int index = entry.key;
                        var item = entry.value;
                        bool isSelected =
                            dashboardProvider.currentIndex == index;

                        return ListTile(
                          leading: isSelected ? item[2] : item[1],
                          title: Text(
                            item[0],
                            style: TextStyle(
                              color: isSelected
                                  ? primaryColor800
                                  : subtitleTextColor,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          tileColor: isSelected
                              ? primaryColor800.withOpacity(0.1)
                              : null,
                          onTap: () {
                            dashboardProvider.setIndex(index);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: redLableColor,
                size: 20,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: redLableColor,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context); // Tutup drawer
                await _handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
