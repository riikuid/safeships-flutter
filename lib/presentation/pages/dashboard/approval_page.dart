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
      appBar: AppBar(
        backgroundColor: primaryColor500,
        title: Text(
          'Approvals',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semibold,
            color: whiteColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Documents'),
            Tab(text: 'Patrols'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ApprovalDocumentPage(),
          ApprovalPatrolPage(),
        ],
      ),
    );
  }
}
