import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/screens/addDebt_screen.dart';
import 'package:udhar_kharcha/screens/addPersonalExpense_screen.dart';
import 'package:udhar_kharcha/screens/details_screen.dart';
import 'package:udhar_kharcha/screens/navigationScreen.dart';
import 'package:udhar_kharcha/screens/login_screen.dart';
import 'package:udhar_kharcha/screens/newAddDebt.dart';
import 'package:udhar_kharcha/screens/personal_expense.dart';
import 'package:udhar_kharcha/screens/signup_screen.dart';
import 'package:udhar_kharcha/screens/welcome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:udhar_kharcha/screens/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification);
  print('Handling a background message ${message.messageId}');
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
          fontFamily: 'Nunito'
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => FirebaseAuth.instance.currentUser==null ? WelcomeScreen() : NavigationScreen(),
        '/login' : (context) => Login(),
        '/signup' : (context) => SignupScreen(),
        '/home' : (context) => NavigationScreen(),
        '/add' : (context) => SplitBillsScreen(),
        '/details' : (context) => U2UDetails(),
        '/notify' : (context) => NotificationScreen(),
        '/addPersonal' : (context) => AddPersonalExpenseScreen(),
      },
    );
  }
}