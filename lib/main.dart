import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/firebase_options.dart';
import 'package:safeships_flutter/presentation/pages/auth_wrapper.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/notification_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/providers/user_provider.dart';
import 'package:safeships_flutter/theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
  // Tidak perlu showFlutterNotification karena notification payload ditangani FCM
}

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) return;

  channel = const AndroidNotificationChannel(
    'safeships_notifications', // Samakan dengan FcmHelper
    'SafeShips Notifications',
    description: 'Notifications for SafeShips app',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Inisialisasi plugin
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Gunakan ikon valid
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Buat channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Atur foreground notification
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

  print('Received message: ${message.toMap()}');
  print('Notification payload: ${notification?.toMap()}');
  print('Android details: ${android?.toMap()}');
  print('Data payload: $data');

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
      print('Displayed notification: ${notification.title}');
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
      print('Displayed data-only notification: ${data['title']}');
    } else {
      print('No valid notification or data payload to display');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase init error: $e');
  }

  // Atur background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();

    // Atur foreground handler
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('====== FULL FCM PAYLOAD ======');
      print(jsonEncode(message.toMap()));
      print('================================');

      showFlutterNotification(message);
    });

    // Atur handler untuk notifikasi yang diklik
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification clicked: ${message.toMap()}');
      // Tambahkan navigasi jika perlu
    });

    // Cek jika aplikasi dibuka dari notifikasi
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification: ${initialMessage.toMap()}');
      // Tambahkan navigasi jika perlu
    }

    // Cetak FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
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
        home: const AuthWrapper(),
      ),
    );
  }
}
