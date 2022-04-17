import 'package:flutter/material.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';



class EventScreen extends StatefulWidget {
  final Event eventData;

  const EventScreen({
    Key? key,
    required this.eventData,
  }) : super(key: key);



  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  Map bill = {};
  Map payers = {};
  List<Widget> billWidget = [];
  List<Widget> payerWidget = [];

  getEventDetails(event_id) async {
    try {
      EventDetails obj = EventDetails(event_id);
      await obj.sendQuery();
      print(obj.data);
      if(obj.success){
        setState(() {
          bill = obj.data['event_bill'];
          var eveP = obj.data['event_payers'];
          eveP.keys.toList().forEach((key) {
            if(eveP[key]!=0) {
              payers.addAll({key : eveP[key]});
            }
          });
        });
      }
    }
    catch (e) {
      print(e);
    }
  }

  List<Widget> showBill() {
    billWidget = [];
    bill.forEach((key, value) {
      billWidget.add(ListTile(
        title: Text(key),
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
    return billWidget;
  }


  List<Widget> showPayers() {
    payerWidget = [];
    payers.forEach((key, value) {
      payerWidget.add(ListTile(
        title: Text(key),
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
    getEventDetails('82d1cc9882d9f4ff99c3c980cfcd8960');
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
      body: SingleChildScrollView(
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
                    ),
                  ),
                ]
              ),
              SizedBox(height: 10,),
              Text(
                widget.eventData.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TagWidget(emoji: '📅', label: '17 Jul' ,width: 50,),
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
