import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {


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
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              isThreeLine: true,
              title : Text(
                'Notification body'
              ),
              subtitle: Text(
                'asdfjkjasdfkjasdfajkdasdfadsfasdfadsfadsfawewfajkdsfhhakjdfhadjfkha',
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ),
          );
        }
      ),
    );
  }



}
