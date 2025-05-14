import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safeships_flutter/presentation/pages/approval/approval_document_page.dart';
import 'package:safeships_flutter/presentation/pages/approval/approval_patrol_page.dart';
import 'package:safeships_flutter/theme.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage>
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
                Tab(text: 'Documents'),
                Tab(text: 'Patrols'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ApprovalDocumentPage(),
                ApprovalPatrolPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
