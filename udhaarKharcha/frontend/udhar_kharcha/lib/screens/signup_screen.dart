import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udhar_kharcha/controllers/requests.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController _controller = TextEditingController();
  bool _validate = false;
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';


  void signupUserAccount(String phone ,String username, String? upi) async{
    if(phone.isNotEmpty && username.isNotEmpty) {
      SignUp obj = SignUp(phone, username, upi);
      await obj.sendQuery();
      if (obj.success) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(username);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
      else {
        if (kDebugMode) {
          print(obj.message);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong')
          )
        );
      }
    }
    else{
      if (kDebugMode) {
        print('Something went wrong');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
        elevation: 0,
        backgroundColor: Color(0xfff7f6fb),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),
        title: const Text(
          'SignUp',
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
                contentPadding: EdgeInsets.all(20),
                labelText: 'Enter your username',
                errorText: _validate ? 'Username Can\'t Be Empty' : null,
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.text.isEmpty ? _validate = true : _validate = false;
                  });
                  if(!_validate) {
                    signupUserAccount(_phoneNumber,_controller.text, 'upi');
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
