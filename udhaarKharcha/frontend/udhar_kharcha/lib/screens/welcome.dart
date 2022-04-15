import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  _WelcomeScreenState({Key? key});

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  void handleMessage(RemoteMessage message) {
    print(message.data);
    if(message.data["screen"] == 'launch_analytics_page') {
      print("yes, I am changing screen");
      Navigator.pushNamed(context, '/notify');
    }
  }

  // Future<void> _initializeMessage() async {
  //   RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  //   if(initialMessage != null) {
  //     handleMessage(initialMessage);
  //   }

  //   FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  // }

  // Future<void> selectNotification(String? payload) async {
  //   if (payload != null) {
  //     print('notification payload:');
  //     print(payload);
  //     print("select notification");
  //     // navigatorKey.currentState?.pushNamed('/add');
  //     Navigator.pushNamed(context, '/notify');
  //     print("ye");
  //   }
  //   else
  //     print("received null");
  // }

  Future<void> handlerInitState() async {
    // _initializeMessage();

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    // var initialzationSettingsAndroid =
    // AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettings =
    // InitializationSettings(android: initialzationSettingsAndroid);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: selectNotification);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        print("hello");
        print("I am in foreground");
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
              largeIcon: const DrawableResourceAndroidBitmap('launch_background')
            ),
          ),
        );
      }
      handleMessage(message);
    });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print(message.notification);
    //   print(message.data);
    //   print("I am here");
    //   handleMessage(message);
    // });
  }


  @override
  void initState() {
    super.initState();
    print('chala');
    handlerInitState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20,50,20,0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.0,),

            Center(
              child: Text(
                'Udhar Kharcha',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 30
                ),
        ),
            ),
            SizedBox(height: 10.0,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(),
                onPressed: () {
                    Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

