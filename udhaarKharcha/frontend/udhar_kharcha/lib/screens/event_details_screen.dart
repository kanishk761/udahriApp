import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';



class EventScreen extends StatefulWidget {
  final Event eventData;
  final String name_to;

  const EventScreen({
    Key? key,
    required this.eventData,
    required this.name_to,
  }) : super(key: key);



  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  Map bill = {};
  Map payers = {};
  Map names = {};
  List<Widget> billWidget = [];
  List<Widget> payerWidget = [];

  bool loading = true;

  getEventDetails(event_id) async {
    setState(() {
      loading = true;
    });
    try {
      EventDetails obj = EventDetails(event_id);
      await obj.sendQuery();
      print(obj.data);
      setState(() {
        loading = false;
        if (obj.success) {
          names = obj.data['phone_to_username'];
          bill = obj.data['event_bill'];
          var eveP = obj.data['event_payers'];
          eveP.keys.toList().forEach((key) {
            if (eveP[key] != 0) {
              payers.addAll({key: eveP[key]});
            }
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Couldn\'t fetch data'),duration: Duration(seconds: 1),)
          );
        }
      });
    }
    catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong'),duration: Duration(seconds: 1))
      );
    }
  }

  List<Widget> showBill() {
    billWidget = [];
    bill.forEach((key, value) {
      billWidget.add(ListTile(
        title: Text(
          names[key],
          overflow: TextOverflow.fade,
          softWrap: false,
          maxLines: 1,
        ),
        subtitle: Text(key),
        trailing: Text(
          '\u{20B9} ${value}',
          overflow: TextOverflow.fade,
          softWrap: false,
          maxLines: 1,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900
          ),
        ),
      ),);
    });
    return billWidget;
  }


  List<Widget> showPayers() {
    payerWidget = [];
    payers.forEach((key, value) {
      payerWidget.add(ListTile(
        title: Text(names[key],),
        subtitle: Text(key),
        trailing: Text(
          '\u{20B9} ${value}',
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900
          ),
        ),
      ),);
    });
    return payerWidget;
  }


  @override
  void initState() {
    super.initState();
    getEventDetails(widget.eventData.id);
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
      body: loading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\u{20B9} ${widget.eventData.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                      color: !widget.eventData.willGiveMoney ? Colors.green : Colors.red
                    ),
                  ),
                ]
              ),
              SizedBox(height: 10,),
              Text(
                widget.eventData.name,
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 5,),
              Row(
                children: [
                  TagWidget(emoji: '📅', label: '17 Jul' ,width: 50,color: 0xffffffff,),
                  SizedBox(width: 5,),

                  !widget.eventData.willGiveMoney ?
                  TagWidget(emoji: '💰', label: 'Take from ${widget.name_to}', width: 100,color: 0xffffffff,) :
                  TagWidget(emoji: '💸', label: 'Pay to ${widget.name_to}', width: 100,color: 0xffffffff,)
                ],
              ),

              SizedBox(height: 10,),
              Container(
                //width: double.infinity,
                padding: EdgeInsets.fromLTRB(0,10,0,10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment : MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Bill',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                        color: Colors.grey[300]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: showBill(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.fromLTRB(0,10,0,10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment : MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Paid by',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                        color: Colors.grey[300]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: showPayers(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ]
          )
        ),
      ),
    );
  }
}
