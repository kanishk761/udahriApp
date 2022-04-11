import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void intiState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Already signed in');
      print(user);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
    else {
      print('Not signed in');
    }
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

