import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/screens/analytics_screen.dart';
import 'package:udhar_kharcha/screens/home_screen.dart';
import 'package:udhar_kharcha/screens/personal_expense.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  final _pageController = PageController();
  final _screenList = [HomeScreen(), AnalyticsScreen(), PersonalExpenseScreen()];

  int _selectedNavIndex = 0;
  final _screenName = ['Home','Analytics','Personal Expense'];
  String _screenTitle = 'Home';

  void _onNavItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      _selectedNavIndex = index;
      _screenTitle = _screenName[index];
    });
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

      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: _screenList,
        physics: NeverScrollableScrollPhysics(),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: 'Analytics'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_rounded),
            label: 'Personal'
          )
        ],
        currentIndex: _selectedNavIndex,
        onTap: _onNavItemTapped,
      ),

    );
  }

}
