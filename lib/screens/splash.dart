import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final nextScreen = await Provider.of<AuthProvider>(context, listen: false).tryLogin();
      Navigator.pushReplacementNamed(context, nextScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.supervised_user_circle,
          size: 100,
        ),
      ),
    );
  }
}
