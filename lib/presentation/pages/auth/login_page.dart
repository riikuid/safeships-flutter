import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/home_page.dart';
import 'package:safeships_flutter/presentation/widgets/custom_text_field.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 10,
        shadowColor: primaryColor400,
        toolbarHeight: 70,
        // title: Image.asset(
        //   'assets/logo.png',
        //   height: 30,
        // ),
        // flexibleSpace: const Image(
        //   image: AssetImage(
        //     'assets/bg_appbar.png',
        //   ),
        //   fit: BoxFit.cover,
        // ),
        backgroundColor: Colors.transparent,
      ),
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
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  Text(
                    'Selamat Datang di SafeSHIPS!',
                    style: primaryTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: medium,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    'Daftar dengan lengkapi data dirimu',
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
                    labelText: 'Email',
                    hintText: 'Cth: example@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    textFieldType: CustomTextFieldType.outline,
                    controller: emailController,
                    borderColor: transparentColor,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextField(
                    labelText: 'Kata Sandi',
                    hintText: 'Masukan kata sandi',
                    isObscure: _isObscure,
                    isPassword: true,
                    keyboardType: TextInputType.visiblePassword,
                    textFieldType: CustomTextFieldType.outline,
                    controller: passwordController,
                    borderColor: transparentColor,
                    rightIcon: InkWell(
                      child: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
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
    );
  }
}
