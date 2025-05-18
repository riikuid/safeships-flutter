import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/auth/login_page.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/theme.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dashboardProvider = Provider.of<DashboardProvider>(context);

    _handleLogout() async {
      await context
          .read<AuthProvider>()
          .logout(
            errorCallback: (p0) {},
          )
          .then(
        (value) {
          context.read<DashboardProvider>().resetMenu();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        },
      );
    }

    return Drawer(
      child: Container(
        color: whiteColor,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Push logout to bottom
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
                  ...dashboardProvider.dashboardMenu.asMap().entries.map(
                    (entry) {
                      int index = entry.key;
                      var item = entry.value;
                      bool isSelected = dashboardProvider.currentIndex == index;

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
                          Navigator.pop(
                              context); // Close sidebar after selection
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
              onTap: () {
                _handleLogout();
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Logging out...')),
                // );
                Navigator.pop(context); // Close sidebar after selection
              },
            ),
          ],
        ),
      ),
    );
  }
}
