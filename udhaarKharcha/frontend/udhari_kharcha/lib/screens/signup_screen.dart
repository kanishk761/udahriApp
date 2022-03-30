import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar : AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xfff7f6fb),
        title: const Text(
          'Sign Up',
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          child: Text(
            'Hello',
            style: TextStyle(
              fontSize: 90,
            ),
          ),
        )
      ),
    );
  }
}
