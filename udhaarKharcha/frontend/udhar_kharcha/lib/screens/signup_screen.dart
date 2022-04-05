import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController _controller = TextEditingController();
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xfff7f6fb),
        title: const Text(
          'Signup',
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0,),
            TextField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your username',
                errorText: _validate ? 'Username Can\'t Be Empty' : null,
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  setState(() {
                    _controller.text.isEmpty ? _validate = true : _validate = false;
                  });
                  if(!_validate) {
                    await FirebaseAuth.instance.currentUser?.updateDisplayName(_controller.text);
                    Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/'));
                  }

                },
                style: ButtonStyle(),
                child: const Text('Signup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
