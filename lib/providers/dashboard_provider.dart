import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/approval_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/home_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/my_documentation_submissions_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/my_safety_patrol_submissions_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/safety_patrol_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/user_page.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/theme.dart';

class DashboardProvider with ChangeNotifier {
  int _currentIndex = 0;
  List _dashboardMenu = [];

  // Full menu list (all possible menu items)
  final List _allMenuItems = [
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
      'My Documentation Submission',
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
      const MyDocumentationSubmissionsPage(),
    ],
    [
      'Safety Patrol',
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
      const SafetyPatrolPage(),
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

  DashboardProvider(BuildContext context) {
    _updateMenu(context);
  }

  int get currentIndex => _currentIndex;

  List get dashboardMenu => _dashboardMenu;

  List<Widget> get pages =>
      _dashboardMenu.map((item) => item[3] as Widget).toList();

  void setIndex(int index) {
    if (index >= 0 && index < _dashboardMenu.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Update menu based on user role
  void _updateMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = authProvider.user.role;

    if (role == 'super_admin') {
      _dashboardMenu = _allMenuItems; // Super Admin gets all menu items
    } else if (role == 'manager') {
      _dashboardMenu = _allMenuItems
          .where((item) => item[0] != 'User Management')
          .toList(); // Manager gets all except User Management
    } else if (role == 'user') {
      _dashboardMenu = _allMenuItems
          .where((item) =>
              item[0] == 'Home' ||
              item[0] == 'My Documentation Submission' ||
              item[0] == 'Safety Patrol')
          .toList(); // User gets only Home and My Submissions
    } else {
      _dashboardMenu = []; // Fallback for unknown role
    }
    notifyListeners();
  }

  void resetMenu() {
    _dashboardMenu = []; // Clear the menu
    _currentIndex = 0; // Reset index
    notifyListeners();
  }

  void updateRole(BuildContext context) {
    _updateMenu(context);
  }
}
