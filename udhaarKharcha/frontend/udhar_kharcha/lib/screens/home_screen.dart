import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/requests.dart';

class HomeScreen extends StatefulWidget {
  final Map persons;
  HomeScreen({Key? key, required this.persons}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _user = FirebaseAuth.instance.currentUser?.displayName ?? '';


  @override
  Widget build(BuildContext context) {
    return widget.persons.isEmpty ? Center(child: Text('Nothing to show'),)
        :Padding(
      padding: const EdgeInsets.all(10),
      child: RefreshIndicator(
        onRefresh: () async{
          GetUdhar obj = GetUdhar(_user);
          await obj.sendQuery();
          await Future.delayed(Duration(seconds: 2));
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: widget.persons.keys.length,
          itemBuilder: (context, index) {
            String key = widget.persons.keys.elementAt(index);
            int value = widget.persons[key];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/details',arguments: {
                    'total' : value,
                    'to' : key
                  });
                },
                title: Text(key,
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                leading: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.purple,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You get',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54
                      ),
                    ),
                    Text(
                      '\u{20B9} ${value}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900
                      ),
                    )
                  ],
                )
              )
            );
          }
        )
      ),
    );
  }
}

