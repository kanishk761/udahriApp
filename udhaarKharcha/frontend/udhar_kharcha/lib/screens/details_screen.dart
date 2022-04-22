import 'dart:io';

import 'package:intl/intl.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/event_details_screen.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';
import 'dart:math';


class U2UDetails extends StatefulWidget {
  U2UDetails({
    Key? key,
    required this.phone_to,
    required this.name_to,
    required this.amount
  }) : super(key: key);

  final String phone_to;
  final String name_to;
  double amount;


  @override
  State<U2UDetails> createState() => _U2UDetailsState();
}

class _U2UDetailsState extends State<U2UDetails> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  bool loading = true;
  bool isFabVisible = true;

  List<Color> _colors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.blueGrey,
    Colors.indigo,
    Colors.brown,
    Colors.pink,
    Colors.deepPurpleAccent
  ];


  List<Event> _events = [];

  getData() async{
    setState(() {
      loading = true;
    });
    _events = [];
    try{
      GetPairDetails obj = GetPairDetails(_phoneNumber, widget.phone_to);
      await obj.sendQuery();
      setState(() {
        loading = false;
        if(obj.success) {
          // print(obj.data);
          var data = obj.data.reversed;
          data.forEach((element) {
            _events.add(Event(
                element[1], element[0], element[2].abs(), (element[2] >= 0), element[4], element[3]));
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Couldn\'t fetch data'),duration: Duration(seconds: 1),)
          );
        }
      });
    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong'),duration: Duration(seconds: 1))
      );
    }
  }

  String parseDate(date) {
    final DateFormat formatter = DateFormat('dd MMM');
    final String formatted = formatter.format(HttpDate.parse(date));
    return formatted;
  }

  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            'Transactions',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if(notification.direction == ScrollDirection.forward){
            if(!isFabVisible) {
              setState(() {
                isFabVisible = true;
              });
            }
          }
          else if(notification.direction == ScrollDirection.reverse){
            if(isFabVisible){
              setState(() {
                isFabVisible = false;
              });
            }
          }
          return true;
        },
        child: loading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10,10,10,kFloatingActionButtonMargin + 80),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\u{20B9} ${widget.amount.abs()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                    color: widget.amount > 0 ? Colors.green : widget.amount < 0 ? Colors.red : Colors.black,
                  ),
                ),

                widget.amount > 0 ? TagWidget(emoji: '💰', label: '${widget.name_to} will pay you', width: 150, color: 0xffffffff,) :
                widget.amount < 0 ? TagWidget(emoji: '💸', label: 'You have to pay ${widget.name_to}', width: 150,color: 0xffffffff,) :
                TagWidget(emoji: '🤝', label: 'You are all settled', width: 120, color: 0xffffffff,),
                SizedBox(height: 20,),
                Text(
                  'Transactions with ${widget.name_to}',
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                for(var element in _events)
                  transactionCard(element),
              ]
            ),
          ),
        ),
      ),

      floatingActionButton: AnimatedSlide(
        duration: Duration(milliseconds : 300),
        offset: isFabVisible ? Offset.zero : Offset(0, 2),
        child: widget.amount < 0 ? Padding(
          padding: const EdgeInsets.fromLTRB(0,0,10,20),
          child: AnimatedOpacity(
            duration: Duration(milliseconds : 300),
            opacity: isFabVisible ? 1 : 0,
            child: FloatingActionButton.extended(
              onPressed: () async{
                var ret = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  var _controllerAmount = TextEditingController();
                  return AlertDialog(
                    content: Padding(
                      padding: const EdgeInsets.all(10),
                      child: AutoSizeTextField(
                        maxLength: 9,
                        minWidth: 100,
                        autofocus: true,
                        controller: _controllerAmount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // prefixText: showPrefix ? '\u{20B9}' : '',
                          hintText: '\u{20B9} 0',
                          counterText: '',
                          // errorText: _validateAmt ? 'Enter amount' : null,
                        ),
                        fullwidth: false,
                        minFontSize: 24,
                        style: TextStyle(fontSize: 50),
                        textAlign: TextAlign.center,
                        // onChanged: (_val) {
                        //   if(_val.length > 0)
                        //     showPrefix = true;
                        //   else
                        //     showPrefix = false;
                        //   setState(() {});
                        // },
                      ),
                    ),
                    actionsPadding: EdgeInsets.all(20),
                    actions: [
                      ElevatedButton(
                        child: Text('Ok'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context,_controllerAmount.text);
                          });
                        },
                      ),
                    ],
                  );
                });
                // TODO : Settle payment HTTP error
                if(ret!=null && ret!='' && ret!='0'){
                  double amt = double.parse(ret!);
                  try{
                    SettlePayments obj = SettlePayments(
                        _phoneNumber, widget.phone_to, amt
                    );
                    await obj.sendQuery();
                    if(obj.success) {
                      setState(() {
                        widget.amount += amt;
                      });
                    }
                  }
                  catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Something went very wrong'),duration: Duration(seconds: 1))
                    );
                  }
                  print(amt);
                }
              },
              icon: Icon(
                  Icons.handshake
              ),
              label: Text('Settle'),
            ),
          ),
        ): null,
      )
    );
  }


  Widget transactionCard(element) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EventScreen(eventData: element, name_to: widget.name_to,))
        );
      },
      child: Card(
        elevation: 0,
        color: (!element.isApproved)?Colors.purple[50]:Colors.teal[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 15, 20,10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TagWidget(emoji: '📅', label: parseDate(element.date) ,width: 70,),
                  SizedBox(width: 5,),
                  element.willGiveMoney ? TagWidget(emoji: '💰', label: 'You took \u{20B9}${element.amount.abs()}' ,width: 120,) :
                  TagWidget(emoji: '💸', label: 'You gave \u{20B9}${element.amount.abs()}' ,width: 120,),
                  SizedBox(width: 5,),
                  element.isApproved ? TagWidget(emoji: '👍', label: 'Approved', width: 80) :
                  TagWidget(emoji: '⏳', label: 'Pending', width: 80)
                ],
              ),
              SizedBox(height: 8,),
              Text(
                element.name,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w200
                ),
              ),

              Divider(
                  color: Colors.grey[300]
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
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
                                backgroundColor: _colors[Random().nextInt(_colors.length)]
                            )
                        ),
                        SizedBox(height: 5,),
                        Text('You'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: !element.willGiveMoney ? [
                            Icon(Icons.arrow_right,
                              size: 20,
                            ),
                            Icon(Icons.arrow_right,
                              size: 20,
                            ),
                            Icon(Icons.arrow_right,
                              size: 20,
                            ),
                          ] : [
                            Icon(Icons.arrow_left,
                              size: 20,
                            ),
                            Icon(Icons.arrow_left,
                              size: 20,
                            ),
                            Icon(Icons.arrow_left,
                              size: 20,
                            ),
                          ]
                        ),
                        Text(
                          '\u{20B9} ${element.amount}',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                                child: Text(
                                    widget.name_to.isNotEmpty ? widget.name_to[0] : '',
                                    style: TextStyle(color: Colors.white)
                                ),
                                backgroundColor: _colors[Random().nextInt(_colors.length)]
                            )
                        ),
                        SizedBox(height: 5,),
                        Text(
                          widget.name_to,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),

              // Approve and Reject UI
              (!element.isApproved && element.willGiveMoney) ?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.purple[100])
                      ),
                      icon: Icon(
                        Icons.thumb_up,
                        color: Colors.purple[400],
                      ),
                      label: Text(
                        'Approve',
                        style: TextStyle(
                        ),
                      ),
                      onPressed: () async {
                        try{
                          ApproveRejectUdhar obj = ApproveRejectUdhar(
                              _phoneNumber,
                              widget.phone_to,
                              element.id,
                              true
                          );
                          await obj.sendQuery();
                          if(obj.success){
                            widget.amount -= element.amount;
                            await getData();
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Something went wrong'),duration: Duration(seconds: 1))
                            );
                          }
                        }
                        catch(e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Something went very wrong'),duration: Duration(seconds: 1))
                          );
                        }
                      },
                    ),
                  ),
                ],
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
