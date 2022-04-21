import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/details_screen.dart';
import 'package:udhar_kharcha/screens/loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';


  Map persons  = {}; // phoneNumber : [name,amount]
  bool homeLoading = true;

  Future<void> getUdharData() async {
    setState(() {
      homeLoading = true;
    });
    //await Future.delayed(Duration(seconds: 2));
    GetUdhar obj = GetUdhar(_phoneNumber);
    await obj.sendQuery();
    setState(() {
      homeLoading = false;
      if(obj.success) {
        persons = obj.data;
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t fetch data'),duration: Duration(seconds: 1),)
        );
      }
    });
    print(persons);
  }


  @override
  void initState() {
    print('home init');
    getUdharData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      body: homeLoading ? ShimmerLoading() : Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: () async{
            await getUdharData();
          },
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: persons.keys.length,
            itemBuilder: (context, index) {
              String key = persons.keys.elementAt(index);
              String name = persons[key][0];
              double value = persons[key][1];
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
                  subtitle: Text(key),
                  leading: value > 0 ?
                  Icon(
                    Icons.south_west_rounded,
                    color: Colors.green,
                  ) : value <  0 ?
                  Icon(
                    Icons.north_east_rounded,
                    color: Colors.red,
                  ) :
                  Icon(
                    Icons.done_all,
                    color: Colors.purple,
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async{
          await Navigator.pushNamed(context, '/add');
          getUdharData();
        },
        label: const Text('Add Udhar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

