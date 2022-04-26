import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/requests.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  List _notifications = [];

  getNotifications() async{
    try {
      GetNotificationDetails obj = GetNotificationDetails(_phoneNumber);
      await obj.sendQuery();
      setState(() {
        if(obj.success)
          _notifications = obj.data;
      });
    }
    catch(e) {
      if (kDebugMode) {
        print('failed to get notifications');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getNotifications();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black
          ),
        ),
      ),

      body: ScreenBody(context),
    );
  }

  Widget ScreenBody(context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          index = _notifications.length - index -1;
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              isThreeLine: true,
              title : Text(
                _notifications[index][0]
              ),
              subtitle: Text(
                _notifications[index][1],
              ),
            ),
          );
        }
      ),
    );
  }



}
