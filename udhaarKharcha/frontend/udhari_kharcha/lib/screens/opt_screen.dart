import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
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
            'Enter OTP',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10.0,),

            Text(
                'Please enter 6-digit OTP sent on number to continue'
            ),
            SizedBox(height: 10.0,),

            TextField(
              autofocus: true,
              style: TextStyle(
                letterSpacing: 6.0,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Verify'),
              ),
            )

          ],
        ),
      ),
    );
  }
}
