import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/home_screen.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String _user = 'Saransh';

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

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
        return HomeScreen(persons: persons,);
      case 1:
        return Center(child: Text('Second'),);
      default:
        return Center(child: Text('Third'),);
    }
  }


  // get Udhar
  Map persons = {}; // <String,int>

  void getUdharData() async {
    GetUdhar obj = GetUdhar(_user);
    await obj.sendQuery();
    setState(() {
      persons = obj.data;
    });
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
          _screenTitle,
          style: TextStyle(
              color: Colors.black
          ),
        )
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_username),
              accountEmail: Text(_phoneNumber),
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.redAccent,
                child: Text((_username.isNotEmpty?_username[0] :''),
                    style : TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
            // DrawerHeader(
            //     decoration: BoxDecoration(
            //       color: Colors.purple,
            //     ),
            //     child: SizedBox(
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.end,
            //           children: [
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 CircleAvatar(
            //                   radius: 30,
            //                   backgroundColor: Colors.redAccent,
            //                   child: const Text('S',
            //                       style : TextStyle(
            //                           fontSize: 30,
            //                           fontWeight: FontWeight.bold
            //                       )
            //                   ),
            //                 ),
            //                 SizedBox(width: 20,),
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       user!.displayName.toString(),
            //                       style: TextStyle(
            //                           fontSize: 20,
            //                           fontWeight: FontWeight.bold
            //                       ),
            //                     ),
            //                     Text(
            //                       user!.phoneNumber.toString(),
            //                       style: TextStyle(
            //                           fontSize: 12
            //                       ),
            //                     ),
            //                     Text(
            //                       'UPI ID',
            //                       style: TextStyle(
            //                           fontSize: 12
            //                       ),
            //                     )
            //                   ],
            //                 ),
            //                 Spacer(),
            //                 IconButton(
            //                   icon: Icon(Icons.edit),
            //                   onPressed: () {},
            //                 )
            //               ],
            //             )
            //           ],
            //         )
            //     )
            // ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async{
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Do '),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
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
