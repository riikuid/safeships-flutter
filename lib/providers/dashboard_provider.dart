import 'package:flutter/material.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/approval_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/home_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/my_submissions_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/user_page.dart';
import 'package:safeships_flutter/theme.dart';

class DashboardProvider with ChangeNotifier {
  int _currentIndex = 0;

  List dashboardMenu = [
    [
      'Home',
      Icon(
        Icons.home_outlined,
        color: subtitleTextColor,
        size: 16,
      ),
      Icon(
        Icons.home_rounded,
        color: primaryColor800,
        size: 16,
      ),
      const HomePage(),
    ],
    [
      'Approvals',
      Icon(
        Icons.fact_check_outlined,
        color: subtitleTextColor,
        size: 16,
      ),
      Icon(
        Icons.fact_check_rounded,
        color: primaryColor800,
        size: 16,
      ),
      const ApprovalPage(),
    ],
    [
      'My Submissions',
      Icon(
        Icons.archive_outlined,
        color: subtitleTextColor,
        size: 16,
      ),
      Icon(
        Icons.archive_rounded,
        color: primaryColor800,
        size: 16,
      ),
      const MySubmissionsPage(),
    ],
    [
      'User Management',
      Icon(
        Icons.people_outline,
        color: subtitleTextColor,
        size: 16,
      ),
      Icon(
        Icons.people,
        color: primaryColor800,
      ),
      const UserPage(),
    ],
  ];

  int get currentIndex => _currentIndex;

  List<Widget> get pages =>
      dashboardMenu.map((item) => item[3] as Widget).toList();

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  bool isOnTopUp = false;
}
