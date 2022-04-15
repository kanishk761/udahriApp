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

import 'package:udhar_kharcha/screens/notification_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> selectNotification(String? payload) async {
  if (payload != null) {
    print('notification payload:');
    print(payload);
    print("select notification");
    navigatorKey.currentState?.pushNamed('/notify');
    print("no way");
  }
  else
    print("received null");
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification?.title);
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation
          <AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

    var initialzationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    print(notificationAppLaunchDetails!.didNotificationLaunchApp);

    if(notificationAppLaunchDetails.didNotificationLaunchApp == false) {
      print("lauched by notification:)");
      navigatorKey.currentState?.pushNamed('/notify');
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("hello there");
      print(message.notification!.body != null);
      // if (message.notification!.body != null) {
        print("inside");
        navigatorKey.currentState?.pushNamed('/notify');
      // }
    });

    print("finally running");

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
      // routes: {
      //   '/' : (context) => FirebaseAuth.instance.currentUser==null ? WelcomeScreen() : NavigationScreen(),
      //   '/login' : (context) => Login(),
      //   '/signup' : (context) => SignupScreen(),
      //   '/home' : (context) => NavigationScreen(),
      //   '/add' : (context) => AddDebtScreen(),
      //   '/details' : (context) => U2UDetails(),
      //   '/notify' : (context) => NotificationScreen(),
      // },
      onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const WelcomeScreen(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const NavigationScreen(),
              );
            case '/notify':
              print("notify");
              return MaterialPageRoute(
                builder: (_) => NotificationScreen()
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => Login()
              );
            case '/signup':
              return MaterialPageRoute(
                builder: (_) => SignupScreen()
              );
            default:
              return MaterialPageRoute(
                builder: (_) => AddDebtScreen()
              );
          }
      }
    );
  }
}