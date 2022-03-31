import 'package:flutter/material.dart';
import 'package:udhari_kharcha/screens/home_screen.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  String _username = 'Saransh';
  String _phoneNumber = '+91987654321';

  // Nav bar variables
  int _selectedNavIndex = 0;
  final _screens = <Widget>[
    HomeScreen(),
    Center(child: Text('Second'),),
    Center(child: Text('Third'),),
  ];

  final _screenName = ['Home','History','yolo'];
  String _screenTitle = 'Home';


  void _onItemTapped(int index){
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
            // UserAccountsDrawerHeader(
            //     accountName: Text(_username),
            //     accountEmail: Text(_phoneNumber)
            // ),
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.redAccent,
                          child: const Text('S',
                            style : TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                        SizedBox(width: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _username,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                                _phoneNumber,
                              style: TextStyle(
                                fontSize: 12
                              ),
                            ),
                            Text(
                              'UPI ID',
                              style: TextStyle(
                                  fontSize: 12
                              ),
                            )
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {},
                        )
                      ],
                    )
                  ],
                )
              )
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Login'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/login');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Otp'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/otp');
              },
            ),
          ],
        ),
      ),

      body: _screens.elementAt(_selectedNavIndex),

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
        onPressed: (){
          Navigator.pushNamed(context, '/add');
        },
        label: const Text('Add Udhaar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}