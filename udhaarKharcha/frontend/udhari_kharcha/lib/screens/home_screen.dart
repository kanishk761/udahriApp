import 'package:flutter/material.dart';
import 'package:udhari_kharcha/screens/details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String,String> _persons = {
    'Shubham' : '5',
    'Kanishk' : '20',
    'Chirag': '12',
    'Naved' : '10',
    'Rathin' : '120'
  };

  List<Widget> listBuilder() {
    List<Widget> lst = [];
    _persons.forEach((key, value) {
      lst.add(Card(
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
      ));
    });
    return lst;
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: Column(
            children: listBuilder()
        ),
      ),
    );
  }
}
