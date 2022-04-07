import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/screens/addDebt_screen.dart';
import 'package:udhar_kharcha/screens/details_screen.dart';
import 'package:udhar_kharcha/screens/navigationScreen.dart';
import 'package:udhar_kharcha/screens/login_screen.dart';
import 'package:udhar_kharcha/screens/signup_screen.dart';
import 'package:udhar_kharcha/screens/welcome.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'udhar Kharcha',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          //fontFamily: 'NunitoLight'
      ),
      initialRoute: '/home',
      routes: {
        '/' : (context) => WelcomeScreen(),
        '/login' : (context) => Login(),
        '/signup' : (context) => SignupScreen(),
        '/home' : (context) => NavigationScreen(),
        '/add' : (context) => AddDebtScreen(),
        '/details' : (context) => U2UDetails()
      },
    );
  }
}