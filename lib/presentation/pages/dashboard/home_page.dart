import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/notification_handler.dart';
import 'package:safeships_flutter/presentation/pages/notification/notification_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:safeships_flutter/presentation/pages/document/list_category_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_patrol/pengajuan_safety_patrol_page.dart';
import 'package:safeships_flutter/presentation/widgets/notification_card.dart';
import 'package:safeships_flutter/providers/notification_provider.dart';
import 'package:safeships_flutter/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .getNotifications(
        errorCallback: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading notifications: $error')),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ListCategoryPage(),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.description_outlined,
                                  size: 26,
                                  color: Color(0xffD5ABA8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Dokumentasi K3',
                                style: primaryTextStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: semibold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PengajuanSafetyPatrolPage(),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.forward_to_inbox,
                                  size: 26,
                                  color: Color(0xffD6BB7F),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Formulir Safety Patrol',
                                style: primaryTextStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: semibold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            log('Safety Induction tapped');
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.badge_outlined,
                                  size: 26,
                                  color: Color(0xffA4C0B6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Formulir Safety Induction',
                                style: primaryTextStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: semibold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notifications',
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontSize: 14,
                              fontWeight: semibold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationPage(),
                                  ));
                            },
                            child: Text(
                              'See All',
                              style: primaryTextStyle.copyWith(
                                color: subtitleTextColor,
                                fontSize: 10,
                                fontWeight: semibold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Consumer<NotificationProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              itemCount: 3,
                              itemBuilder: (context, index) =>
                                  Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: 90,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          } else if (provider.notifications.isEmpty) {
                            return const Center(
                                child: Text('No notifications found'));
                          } else {
                            final latestNotifications =
                                provider.notifications.take(5).toList();
                            return ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 10,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: latestNotifications.length,
                              itemBuilder: (context, index) {
                                final notification = latestNotifications[index];
                                return NotificationCard(
                                  notification: notification,
                                  onTap: () async {
                                    setState(() => _isLoading = true);
                                    await NotificationHandler
                                        .handleNotificationTap(
                                            context, notification);
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          ColoredBox(
            color: blackColor.withOpacity(0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
