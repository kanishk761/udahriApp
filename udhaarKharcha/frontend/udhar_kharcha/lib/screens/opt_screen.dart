import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {


  final _controller = TextEditingController();
  String _otp ='';
  bool loading = true;

  // Phone Authentication
  verifyPhone() async{
    //await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential authCredential) async{
          print("Verification completed : ${authCredential.smsCode}");
          if(!mounted) return;
          setState(() {
            _otp = authCredential.smsCode.toString();
            _controller.text = _otp;
          });
          if (authCredential.smsCode != null) {
            try {
              await FirebaseAuth.instance.signInWithCredential(authCredential);
              print(FirebaseAuth.instance.currentUser);
              print('Ho raha hai sign in');
            } on FirebaseAuthException catch(e){
              print(e.message);
            }
            if(FirebaseAuth.instance.currentUser?.displayName != null)
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            else
              Navigator.pushReplacementNamed(context, '/signup');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String confimationCode, int? resendCode) {
          if(!mounted) return;
          print('OTP sent');
          setState(() {
            _otp = confimationCode;
            loading = false;
          });
        },
        codeAutoRetrievalTimeout: (String confimationCode) {
          print('Device stopped reading OTP automatically');
        },
    );
  }

  @override
  void initState() {
    super.initState();
    print(FirebaseAuth.instance.currentUser);
    verifyPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
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
                'Please enter 6-digit OTP sent on your number to continue'
            ),
            SizedBox(height: 10.0,),

            TextField(
              autofocus: true,
              controller: _controller,
              style: TextStyle(
                letterSpacing: 6.0,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20),
                border: OutlineInputBorder(),
                counterText: ''
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),

            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  print(_otp);

                  // login user
                  try {
                    await FirebaseAuth.instance
                        .signInWithCredential(PhoneAuthProvider.credential(
                        verificationId: _otp, smsCode: _controller.text))
                        .then((value) async {
                      if(value.user != null) {
                        print('Verified by click');
                        if(FirebaseAuth.instance.currentUser?.displayName != null)
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                        else
                          Navigator.pushReplacementNamed(context, '/signup');
                      }
                    });
                  } on FirebaseAuthException catch (e) {
                    print(e.message);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Invalid OTP')
                        )
                    );
                  }
                },
                child: loading==false ? Text('Verify') : SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }




}
