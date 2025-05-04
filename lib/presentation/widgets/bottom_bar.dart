import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/theme.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dashboardProvider = Provider.of<DashboardProvider>(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [defaultShadow],
      ),
      child: NavigationBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        elevation: 5,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: dashboardProvider.currentIndex,
        onDestinationSelected: (value) {
          dashboardProvider.setIndex(value);
        },
        destinations: dashboardProvider.dashboardMenu.map(
          (item) {
            return NavigationDestination(
              icon: item[1],
              label: item[0],
              selectedIcon: Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    height: double.infinity,
                    child: item[2],
                  ),
                  SizedBox(
                    height: 3,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: primaryColor800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
