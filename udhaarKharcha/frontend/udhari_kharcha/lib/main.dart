import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udhari_kharcha/screens/addDebt_screen.dart';
import 'package:udhari_kharcha/screens/details_screen.dart';
import 'package:udhari_kharcha/screens/navigationScreen.dart';
import 'package:udhari_kharcha/screens/login_screen.dart';
import 'package:udhari_kharcha/screens/opt_screen.dart';
import 'package:udhari_kharcha/screens/signup_screen.dart';
import 'package:udhari_kharcha/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Udhari Kharcha',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'NunitoLight'
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => NavigationScreen(),
        '/login' : (context) => Login(),
        '/otp' : (context) => OtpScreen(),
        '/signup' : (context) => SignupScreen(),
        '/add' : (context) => AddDebtScreen(),
        '/details' : (context) => U2UDetails()
      },
    );
  }
}