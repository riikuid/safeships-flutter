import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/theme.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dashboardProvider = Provider.of<DashboardProvider>(context);

    return Drawer(
      child: Container(
        color: whiteColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor800,
              ),
              child: Text(
                'SafeShips Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
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
                      color: isSelected ? primaryColor800 : subtitleTextColor,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  tileColor:
                      isSelected ? primaryColor800.withOpacity(0.1) : null,
                  onTap: () {
                    dashboardProvider.setIndex(index);
                    Navigator.pop(context); // Tutup sidebar setelah memilih
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
