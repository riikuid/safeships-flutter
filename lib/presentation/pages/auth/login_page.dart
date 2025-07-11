import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/dashboard.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/home_page.dart';
import 'package:safeships_flutter/presentation/widgets/custom_text_field.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/dashboard_provider.dart';
import 'package:safeships_flutter/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');

  bool _isObscure = true;
  bool _isLoading = false;
  bool _isLoadingScaffold = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    Future<void> handleGuestLogin() async {
      setState(() {
        _isLoadingScaffold = true;
      });

      String? fcmToken = "";

      FocusScope.of(context).requestFocus(FocusNode());

      if (Platform.isAndroid) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: true,
          criticalAlert: true,
          provisional: true,
          sound: true,
        );
        fcmToken = await messaging.getToken();
        log('User granted permission: ${settings.authorizationStatus}');
      } else if (Platform.isIOS) {
        // iOS-specific code
      }

      log("FCM TOKEN $fcmToken");

      AuthProvider authProvider =
          Provider.of<AuthProvider>(context, listen: false);

      await authProvider
          .guestLogin(
        fcmToken: fcmToken!,
        errorCallback: (p0) {
          Fluttertoast.showToast(msg: p0.toString());
        },
      )
          .then(
        (value) {
          if (value) {
            context.read<DashboardProvider>().updateRole(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const Dashboard(),
              ),
              (route) => false,
            );
          } else {
            // ThrowSnackbar().showError(context, errorText);
          }
        },
      );

      setState(() {
        _isLoadingScaffold = false;
      });
    }

    Future<void> handleLogin() async {
      setState(() {
        _isLoading = true;
      });

      String? fcmToken = "";

      FocusScope.of(context).requestFocus(FocusNode());
      AuthProvider authProvider =
          Provider.of<AuthProvider>(context, listen: false);

      if (Platform.isAndroid) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: true,
          criticalAlert: true,
          provisional: true,
          sound: true,
        );
        fcmToken = await messaging.getToken();
        log('User granted permission: ${settings.authorizationStatus}');
      } else if (Platform.isIOS) {
        // iOS-specific code
      }

      log("FCM TOKEN $fcmToken");

      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        AuthProvider authProvider =
            Provider.of<AuthProvider>(context, listen: false);

        await authProvider
            .login(
          email: emailController.text,
          password: passwordController.text,
          fcmToken: fcmToken!,
          errorCallback: (p0) {
            Fluttertoast.showToast(msg: p0.toString());
          },
        )
            .then(
          (value) {
            if (value) {
              context.read<DashboardProvider>().updateRole(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const Dashboard(),
                ),
                (route) => false,
              );
            } else {
              // ThrowSnackbar().showError(context, errorText);
            }
          },
        );
      } else {
        Fluttertoast.showToast(msg: 'Email atau password tidak boleh kosong!');
      }

      setState(() {
        _isLoading = false;
      });
    }

    return Stack(
      children: [
        Scaffold(
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   elevation: 10,
          //   shadowColor: primaryColor400,
          //   toolbarHeight: 70,
          //   title: Text(
          //     'SafeSHIPS',
          //     style: primaryTextStyle.copyWith(
          //       color: whiteColor,
          //       fontWeight: semibold,
          //     ),
          //   ),
          //   // flexibleSpace: const Image(
          //   //   image: AssetImage(
          //   //     'assets/bg_appbar.png',
          //   //   ),
          //   //   fit: BoxFit.cover,
          //   // ),
          //   backgroundColor: primaryColor500,
          // ),
          body: SingleChildScrollView(
            controller: ScrollController(),
            child: Container(
              height: screenSize.height - 90,
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
                // bottom:
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 70,
                      ),
                      Image.asset(
                        'assets/login_image.png',
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Selamat Datang!',
                        style: primaryTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: semibold,
                        ),
                      ),
                      Text(
                        'Masuk ke Akun Anda',
                        style: primaryTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: medium,
                          color: blackColor.withOpacity(0.8),
                        ),
                      ),

                      const SizedBox(
                        height: 35,
                      ),
                      CustomTextField(
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 5),
                          child: Icon(
                            Icons.mail_outline,
                            color: primaryColor500,
                            size: 14,
                          ),
                        ),
                        labelText: 'Email',
                        hintText: 'example@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        textFieldType: CustomTextFieldType.outline,
                        controller: emailController,
                        borderColor: transparentColor,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomTextField(
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 5),
                          child: Icon(
                            Icons.lock_outline,
                            color: primaryColor500,
                            size: 14,
                          ),
                        ),
                        labelText: 'Kata Sandi',
                        hintText: '************',
                        isObscure: _isObscure,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        textFieldType: CustomTextFieldType.outline,
                        controller: passwordController,
                        borderColor: transparentColor,
                        rightIcon: InkWell(
                          child: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 15,
                            color: subtitleTextColor,
                          ),
                          onTap: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      PrimaryButton(
                        isLoading: _isLoading,
                        onPressed: handleLogin,
                        child: Text(
                          'Masuk',
                          style: primaryTextStyle.copyWith(
                            fontWeight: semibold,
                            color: whiteColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tidak Punya Akun? ',
                            style: primaryTextStyle.copyWith(
                              color: subtitleTextColor,
                              fontWeight: regular,
                              fontSize: 12,
                            ),
                          ),
                          InkWell(
                            onTap: handleGuestLogin,
                            child: Text(
                              'Masuk Sebagai Tamu',
                              style: primaryTextStyle.copyWith(
                                color: primaryColor800,
                                fontWeight: semibold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      )

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       'Belum punya akun?',
                      //       style: primaryTextStyle.copyWith(
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //     const SizedBox(
                      //       width: 5,
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         // Navigator.pushReplacement(
                      //         //   context,
                      //         //   MaterialPageRoute(
                      //         //     builder: (context) => const RegisterPage(),
                      //         //   ),
                      //         // );
                      //       },
                      //       child: Text(
                      //         'Yuk daftar!',
                      //         style: primaryTextStyle.copyWith(
                      //           color: primaryColor500,
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoadingScaffold)
          ColoredBox(
            color: blackColor.withOpacity(0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
