import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/presentation/pages/auth/login_page.dart';
import 'package:safeships_flutter/presentation/pages/dashboard/dashboard.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/theme.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final tokenRepository = TokenRepository();
  late AuthProvider authProvider =
      Provider.of<AuthProvider>(context, listen: false);

  Future authCheck() async {
    log("MASUK AUTH");
    final token = await tokenRepository.getToken();
    log(token.toString());

    if (token != null) { 
      log("TOKEN ONOK");
      bool success = await authProvider.getProfile(token: token);

      if (success) {
        log("SUKSES BOLO");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(),
            ));
      } else {
        log("GAISOK ");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
      }
    } else {
      log("TOKEN KOSONG ");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    // authCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    authCheck();
    return Scaffold(
      body: Center(
          child: Text(
        'Loading',
        style: primaryTextStyle.copyWith(
          fontSize: 18,
          fontWeight: semibold,
        ),
      )),
    );
  }
}
