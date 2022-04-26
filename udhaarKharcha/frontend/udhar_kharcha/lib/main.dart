import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/screens/addPersonalExpense_screen.dart';
import 'package:udhar_kharcha/screens/add_debt_screen.dart';
import 'package:udhar_kharcha/screens/navigationScreen.dart';
import 'package:udhar_kharcha/screens/login_screen.dart';
import 'package:udhar_kharcha/screens/signup_screen.dart';
import 'package:udhar_kharcha/screens/welcome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:udhar_kharcha/screens/notification_screen.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
bool notification_clicked = false;

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> selectNotification(String? payload) async {
  if (payload != null) {
    if (kDebugMode) {
      print('notification payload:');
      print(payload.length);
      print("select notification");
    }
    navigatorKey.currentState?.pushNamed('/notify');
  }
  else
    if (kDebugMode) {
      print("received null");
    }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print(message.notification?.title);
    print('Handling a background message ${message.messageId}');
  }
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

    if (kDebugMode) {
      print(notificationAppLaunchDetails!.didNotificationLaunchApp);
    }

    if(notificationAppLaunchDetails!.didNotificationLaunchApp == true) {
      notification_clicked = true;
      if (kDebugMode) {
        print("not lauched by notification:(");
      }
      navigatorKey.currentState?.pushNamed('/notify');
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("hello there");
        print(message.notification!.body != null);
      }
    });

    if (kDebugMode) {
      print("finally running");
    }

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
        '/add' : (context) => SplitBillsScreen(),
        '/notify' : (context) => NotificationScreen(),
        '/addPersonal' : (context) => AddPersonalExpenseScreen(),
      },
    );
  }
}