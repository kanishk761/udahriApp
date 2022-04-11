import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  void handleMessage(RemoteMessage message) {
    print(message.data);
    if(message.data["type"] == 'udhar') {
      Navigator.pushNamed(context, '/home');
    }
  }

  Future<void> _helperInitState() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  @override
  void initState() {
    super.initState();

    _helperInitState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification);
      print(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(message.notification);
      print(message.data);
    });
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

