import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udhar_kharcha/screens/opt_screen.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _controller = TextEditingController();
  bool _isButtonDisabled = true;

  @override
  void initState() {
    _isButtonDisabled = true;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    print('number is +91'+_controller.text);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: '+91'+_controller.text,))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xfff7f6fb),
        title: const Text(
          'Enter Mobile Number',
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

            Text(
              'We\'ll send an OTP to verify that it\'s you',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10.0,),

            TextField(
              autofocus: true,
              controller: _controller,
              onChanged: (_num) {
                setState(() {
                  _isButtonDisabled = (_num.length == 10) ? false : true ;
                });
              },
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              style: TextStyle(
                  letterSpacing: 5
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '+91',
                    style: TextStyle(
                        letterSpacing: 5
                    ),
                  ),
                ),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
            ),

            Spacer(),
            //_buildCounterButton()
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(),
                onPressed: _isButtonDisabled ? null : _submit,
                child: const Text('Send OTP'),
              ),
            ),

          ],
        ),
      ),
    );
  }

}

