import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/details_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map persons;
  HomeScreen({Key? key, required this.persons}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _user = FirebaseAuth.instance.currentUser?.displayName ?? '';

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: RefreshIndicator(
        onRefresh: () async{
          GetUdhar obj = GetUdhar(_phoneNumber);
          await obj.sendQuery();
          print(obj.data);
          await Future.delayed(Duration(seconds: 2));
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: widget.persons.keys.length,
          itemBuilder: (context, index) {
            String key = widget.persons.keys.elementAt(index);
            String name = widget.persons[key][0];
            double value = widget.persons[key][1];
            return Card(
              elevation: 0,
              color: value > 0 ? Colors.green[50] : value < 0 ? Colors.red[50] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => U2UDetails(phone_to: key, name_to: name, amount: value))
                  );
                },
                title: Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                subtitle: Text(
                  key
                ),
                leading: value > 0 ? Icon(
                  Icons.south_west_rounded,
                  color: Colors.green,
                  //size: 45,
                ) : value <  0 ? Icon(
                  Icons.north_east_rounded,
                  color: Colors.red,
                  //size: 45,
                ) : Icon(
                  Icons.done_all,
                  color: Colors.purple,
                  //size: 45,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text : TextSpan(
                        text : value > 0 ? '💰 You will get' : value < 0 ? '💸 You will pay' : '🤝 Settled' ,
                        style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Nunito',
                            color: Colors.black54
                        ),
                      )
                    ),
                    Text(
                      '\u{20B9} ${value.abs()}',
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

