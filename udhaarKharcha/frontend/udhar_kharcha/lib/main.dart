import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/screens/addDebt_screen.dart';
import 'package:udhar_kharcha/screens/details_screen.dart';
import 'package:udhar_kharcha/screens/navigationScreen.dart';
import 'package:udhar_kharcha/screens/login_screen.dart';
import 'package:udhar_kharcha/screens/signup_screen.dart';
import 'package:udhar_kharcha/screens/welcome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String _vapidKey = 'BBYPo_xxWOjx6lvpNdGob0zmLTXUOQv0k2s1hOeQTL8r_HgY6_d0Go_pn_o2e9iYPO1hkxGJgSjkhVsNg6pd6Gw';

  String? token = await messaging.getToken(vapidKey: _vapidKey);
  print(token);
  print("tokenPrinted");
  channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

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
          fontFamily: 'Nunito'
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => FirebaseAuth.instance.currentUser==null ? WelcomeScreen() : NavigationScreen(),
        '/login' : (context) => Login(),
        '/signup' : (context) => SignupScreen(),
        '/home' : (context) => NavigationScreen(),
        '/add' : (context) => AddDebtScreen(),
        '/details' : (context) => U2UDetails()
      },
    );
  }
}