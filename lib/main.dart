import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/notification_handler.dart';
import 'package:safeships_flutter/firebase_options.dart';
import 'package:safeships_flutter/presentation/pages/auth_wrapper.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/dashboard.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/dashboard_page.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/notification_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/providers/user_provider.dart';
import 'package:safeships_flutter/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('Handling a background message: ${message.messageId}');
}

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) return;

  channel = const AndroidNotificationChannel(
    'safeships_notifications',
    'SafeShips Notifications',
    description: 'Notifications for SafeShips app',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!);
          log('Notification tapped with payload: $data');
          await handleNotificationTap(data);
        } catch (e) {
          log('Error parsing notification payload: $e');
        }
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  Map<String, dynamic> data = message.data;

  log('Received message: ${message.toMap()}');
  log('Notification payload: ${notification?.toMap()}');
  log('Android details: ${android?.toMap()}');
  log('Data payload: $data');

  if (!kIsWeb) {
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            color: Colors.blue,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(data),
      );
      log('Displayed notification: ${notification.title}');
    } else if (data.isNotEmpty) {
      flutterLocalNotificationsPlugin.show(
        0,
        data['title'] ?? 'SafeShips',
        data['body'] ?? 'New notification',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            color: Colors.blue,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(data),
      );
      log('Displayed data-only notification: ${data['title']}');
    } else {
      log('No valid notification or data payload to display');
    }
  }
}

Future<void> handleNotificationTap(Map<String, dynamic> data) async {
  final context = navigatorKey.currentContext;
  if (context == null) {
    log('Error: Navigator context is null');
    return;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final dashboardProvider =
      Provider.of<DashboardProvider>(context, listen: false);

  if (authProvider.user == null) {
    log('User not logged in, redirecting to login');
    navigatorKey.currentState?.pushReplacementNamed('/login');
    return;
  }

  try {
    // Set tab index ke 0 (Home Page)
    dashboardProvider.setIndexByPageName('Home');

    // Navigasi ke DashboardPage
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Dashboard()),
      (route) => false, // Hapus semua rute sebelumnya
    );

    // Navigasi lanjutan ke halaman sesuai reference_type
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notificationHandler = NotificationHandler();
      await notificationHandler.handleDeviceNotification(
        context: context,
        data: data,
      );
    });
  } catch (e) {
    log('Error handling notification: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    log('Firebase initialized successfully');
  } catch (e) {
    log('Firebase init error: $e');
  }

  if (!kIsWeb) {
    await setupFlutterNotifications();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log('Notification clicked: ${message.toMap()}');
      await handleNotificationTap(message.data);
    });
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log('App opened from notification: ${initialMessage.toMap()}');
      await handleNotificationTap(initialMessage.data);
    }
    String? token = await FirebaseMessaging.instance.getToken();
    log('FCM Token: $token');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DocumentProvider()),
        ChangeNotifierProvider(create: (context) => DashboardProvider(context)),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => SafetyPatrolProvider()),
      ],
      child: MaterialApp(
        title: 'SafeSHIPS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor500),
          primaryColor: primaryColor500,
          scaffoldBackgroundColor: whiteColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const AuthWrapper(),
        },
      ),
    );
  }
}
