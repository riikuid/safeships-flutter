import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/widgets/bottom_bar.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';

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
      backgroundColor: Colors.grey,
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return dashboardProvider.pages[dashboardProvider.currentIndex];
        },
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
