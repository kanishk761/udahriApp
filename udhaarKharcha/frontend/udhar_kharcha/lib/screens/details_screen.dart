import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/event_details_screen.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';

class U2UDetails extends StatefulWidget {
  const U2UDetails({
    Key? key,
    required this.phone_to,
    required this.name_to,
    required this.amount
  }) : super(key: key);

  final String phone_to;
  final String name_to;
  final double amount;


  @override
  State<U2UDetails> createState() => _U2UDetailsState();
}

class _U2UDetailsState extends State<U2UDetails> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';


  List<Event> _events = [];
  List<Widget> _eventsWidgets = [];

  getData () async{
    _events = [];
    try{
      GetPairDetails obj = GetPairDetails(_phoneNumber, widget.phone_to);
      await obj.sendQuery();
      if(obj.success){
        var data = obj.data;
        _events.add(Event(data[1], data[0], data[2].abs(), (data[2]>=0) , data[3]));
      }
    }
    catch(e){
    }
  }

  showTransactionCard() {
    _events.forEach((element) {
      _eventsWidgets.add(transactionCard(element));
    });

  }


  @override
  void initState() {
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xfff7f6fb),
          iconTheme: IconThemeData(color: Colors.purple),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Details',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
      body: detailBody(),
    );
  }

  Widget detailBody() {
    return  SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\u{20B9} ${widget.amount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 45,
                        ),
                      ),
                      Icon(
                        Icons.south_west_rounded,
                        color: Colors.green[300],
                        size: 45,
                      ),
                    ]
                ),
                SizedBox(height: 20,),
                Text(
                  'Transactions with ${widget.name_to} -- ${widget.phone_to}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 15,),
              ]
          )
      ),
    );
  }

  Widget transactionCard(element) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EventScreen(eventData: element,))
        );
      },
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TagWidget(emoji: '📅', label: 'parseDate(date)' ,width: 90,),
                    element.isApproved ? TagWidget(emoji: '👍', label: 'Approved', width: 90) :
                    TagWidget(emoji: '⏳', label: 'Pending', width: 90)
                  ],
                ),
                Text(
                  element.name,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),

                Divider(
                    color: Colors.grey[300]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                                child: Text('Y',
                                    style: TextStyle(color: Colors.white)
                                ),
                                backgroundColor: Colors.green
                            )
                        ),
                        Text('You'),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.arrow_forward_ios,
                              size: 10,
                            ),
                            Icon(Icons.arrow_forward_ios,
                              size: 10,
                            ),
                            Icon(Icons.arrow_forward_ios,
                              size: 10,
                            ),
                          ],
                        ),
                        Text(
                          '\u{20B9} amt',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                                child: Text('H',
                                    style: TextStyle(color: Colors.white)
                                ),
                                backgroundColor: Colors.redAccent
                            )
                        ),
                        Text('Him'),
                      ],
                    ),
                  ],
                ),
                !element.isApproved ? Container() :
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                          onPressed: () {},
                          child: Text(
                              'Approve',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          )
                      ),
                    ),

                    Expanded(
                      child: TextButton(
                        onPressed: (){},
                        child: Text(
                          'Reject',
                          style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
      ),
    );
  }
}
