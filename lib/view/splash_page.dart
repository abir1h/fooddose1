import 'package:food_dose/view/login_page.dart';
import 'package:food_dose/view/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/buttom-navigation.dart';
import 'home-screen.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigatetowelcomePage();
  }

  _navigatetowelcomePage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    var is_first = pref.getBool('ON_BOARDING');

    is_first == null
        ? await Future.delayed(const Duration(milliseconds: 5000), () {
            Get.to(() => OnboardPage());
          })
        : token != null
            ? await Future.delayed(const Duration(milliseconds: 5000), () {
                Get.to(() => const AppBottomNavigation());
              })
            : await Future.delayed(const Duration(milliseconds: 5000), () {
                Get.to(() => const LoginPages());
              });
  }

  @override
  Widget build(BuildContext context) {
    // final Size size = Get.size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 250,
            ),
          ),
        ],
      ),
    );
  }
}
