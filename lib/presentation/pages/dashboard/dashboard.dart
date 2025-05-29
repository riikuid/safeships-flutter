import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/auth/login_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/profile_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/sidebar.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/theme.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: greyBackgroundColor,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: whiteColor,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: primaryColor500,
        title: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, child) {
            String pageTitle;
            if (dashboardProvider.pages.isNotEmpty) {
              pageTitle = dashboardProvider
                  .dashboardMenu[dashboardProvider.currentIndex][0] as String;
            } else {
              pageTitle = '';
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SafeSHIPS ',
                      style: primaryTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semibold,
                        color:
                            (pageTitle != 'Home') ? disabledColor : whiteColor,
                      ),
                    ),
                    if (pageTitle != 'Home')
                      Text(
                        '/ $pageTitle',
                        style: primaryTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semibold,
                          color: whiteColor,
                        ),
                      ),
                  ],
                ),
                if (pageTitle == 'Home')
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.manage_accounts,
                      size: 24,
                      color: whiteColor,
                    ),
                  )
              ],
            );
          },
        ),
      ),
      drawer: Sidebar(),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.pages.isNotEmpty) {
            return dashboardProvider.pages[dashboardProvider.currentIndex];
          } else {
            return Center(child: Text('No pages available'));
          }
        },
      ),
    );
  }
}
