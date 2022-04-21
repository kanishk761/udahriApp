import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/analytics_screen.dart';
import 'package:udhar_kharcha/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:udhar_kharcha/screens/loading.dart';
import 'package:udhar_kharcha/screens/personal_expense.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  // loading...
  // bool homeLoading = true;
  // bool personalExpenseLoading = true;

  // Nav bar variables
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


  // void _onNavItemTapped(int index){
  //   setState(() {
  //     _selectedNavIndex = index;
  //     _screenTitle = _screenName[index];
  //   });
  // }
  //
  // Widget getPage(int index) {
  //   switch (index){
  //     case 0:
  //       return HomeScreen(); //homeLoading ? ShimmerLoading() : HomeScreen(persons: persons);
  //     case 1:
  //       return AnalyticsScreen();
  //     default:
  //       return PersonalExpenseScreen();//personalExpenseLoading ? ShimmerLoading() : PersonalExpenseScreen(expenses: expenses,);
  //   }
  // }

  // get Udhar
  // Map persons  = {}; // phoneNumber : [name,amount]
  //
  // void getUdharData() async {
  //   setState(() {
  //     homeLoading = true;
  //   });
  //   //await Future.delayed(Duration(seconds: 2));
  //   GetUdhar obj = GetUdhar(_phoneNumber);
  //   await obj.sendQuery();
  //   setState(() {
  //     homeLoading = false;
  //     if(obj.success) {
  //       persons = obj.data;
  //     }
  //     else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Couldn\'t fetch data'),duration: Duration(seconds: 1),)
  //       );
  //     }
  //   });
  //   print(persons);
  // }
  //


  // get personal expenses
  // List expenses = [];  // List of lists of 3
  // getPersonalExpense() async{
  //   try {
  //     setState(() {
  //       personalExpenseLoading = true;
  //     });
  //     GetPersonalExpense obj = GetPersonalExpense(_phoneNumber);
  //     await obj.sendQuery();
  //     setState(() {
  //       if(obj.success)
  //         expenses = obj.data;
  //       personalExpenseLoading = false;
  //     });
  //   }
  //   catch (e) {
  //     print('Failed to get personal expense');
  //   }
  // }


  @override
  void initState() {
    super.initState();
    // getUdharData();
    // getPersonalExpense();
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

      // floatingActionButton: _selectedNavIndex > 1 ?
      //   FloatingActionButton.extended(
      //     onPressed: () async{
      //       await Navigator.pushNamed(context, '/addPersonal');
      //       getPersonalExpense();
      //     },
      //     label: const Text('Add Personal Expense'),
      //     icon: const Icon(Icons.add),
      //   ) : _selectedNavIndex == 0 ?
      //   FloatingActionButton.extended(
      //     onPressed: () async{
      //       await Navigator.pushNamed(context, '/add');
      //       getUdharData();
      //     },
      //     label: const Text('Add Udhar'),
      //     icon: const Icon(Icons.add),
      //   ) : Container(),
    );
  }

}
