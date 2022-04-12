import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:udhar_kharcha/screens/loading.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String _user = 'Saransh';

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  // loading...
  bool homeLoading = true;

  // Nav bar variables
  int _selectedNavIndex = 0;
  final _screenName = ['Home','History','yolo'];
  String _screenTitle = 'Home';

  void _onItemTapped(int index){
    setState(() {
      _selectedNavIndex = index;
      _screenTitle = _screenName[index];
    });
  }

  Widget getPage(int index) {
    switch (index){
      case 0:
        return homeLoading ? ShimmerLoading() : HomeScreen(persons: persons);
      case 1:
        return Center(child: Text('Second'),);
      default:
        return Center(child: Text('Third'),);
    }
  }

  // get Udhar
  Map persons = {}; // <String,int>

  void getUdharData() async {
    setState(() {
      homeLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    GetUdhar obj = GetUdhar(_username);
    await obj.sendQuery();
    setState(() {
      persons = obj.data;
      homeLoading = false;
    });
    print(persons);
  }

  @override
  void initState() {
    super.initState();
    getUdharData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xfff7f6fb),
        iconTheme: IconThemeData(color: Colors.purple),
        title: Text(
          _screenTitle=='Home' ? 'Hi ${_username}' : _screenTitle,
          style: TextStyle(
              color: Colors.black
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed('/notify');
            },
            icon: Icon(Icons.notifications_none_rounded),
            iconSize: 27,
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_username),
              accountEmail: Text(_phoneNumber),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.purple, Colors.pinkAccent])
              ),
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Text((_username.isNotEmpty?_username[0] :''),
                    style : TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async{
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),

      body: getPage(_selectedNavIndex),

      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search'
          )

        ],
        currentIndex: _selectedNavIndex,
        onTap: _onItemTapped,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async{
          await Navigator.pushNamed(context, '/add');
          getUdharData();
        },
        label: const Text('Add Udhaar'),
        icon: const Icon(Icons.add),
      ),
    );
  }

}
