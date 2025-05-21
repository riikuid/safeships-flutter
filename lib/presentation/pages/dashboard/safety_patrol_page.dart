import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safeships_flutter/presentation/pages/approval/approval_document_page.dart';
import 'package:safeships_flutter/presentation/pages/approval/safety_patrol_approval_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/my_safety_patrol_submissions_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/need_action_patrol_page.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyPatrolPage extends StatefulWidget {
  const SafetyPatrolPage({super.key});

  @override
  State<SafetyPatrolPage> createState() => _SafetyPatrolPageState();
}

class _SafetyPatrolPageState extends State<SafetyPatrolPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyBackgroundColor,
      body: Column(
        children: [
          Container(
            color: primaryColor500, // Warna latar belakang TabBar
            child: TabBar(
              controller: _tabController,
              labelColor: whiteColor,
              unselectedLabelColor: Colors.white70,
              indicatorColor: whiteColor,
              labelStyle: primaryTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semibold,
              ),
              unselectedLabelStyle: primaryTextStyle.copyWith(
                fontSize: 16,
                fontWeight: regular,
              ),
              tabs: const [
                Tab(text: 'My Submissions'),
                Tab(text: 'Need Action'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MySafetyPatrolSubmissionsPage(),
                NeedActionPatrolPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
