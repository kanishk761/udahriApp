import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';
import 'package:intl/intl.dart';


class PersonalExpenseScreen extends StatefulWidget {
  const PersonalExpenseScreen({Key? key, required this.expenses}) : super(key: key);

  final List expenses;

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  String _user = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
  
  
  String parseDate(date) {
    final DateFormat formatter = DateFormat('dd MMM');
    final String formatted = formatter.format(HttpDate.parse(date));
    return formatted;
  }
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: RefreshIndicator(
        onRefresh: () async{
          GetPersonalExpense obj = GetPersonalExpense(_phoneNumber);
          await obj.sendQuery();
          await Future.delayed(Duration(seconds: 2));
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: widget.expenses.length,
          itemBuilder: (context, index) {
            String event_desc = widget.expenses[index][0];
            String date = widget.expenses[index][1];
            double event_amount = widget.expenses[index][2];
            return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20,10,15,0),
                      child: Row(
                        children: [
                          TagWidget(emoji: '📅', label: parseDate(date) ,width: 50,),
                          SizedBox(width: 6,),
                          TagWidget(emoji: '✋', label: 'Personal' , width: 60,),
                          Expanded(
                            child: Text(
                              'You spent',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                        onTap: () { },
                        title: Text(
                          event_desc,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        trailing: Text(
                          '\u{20B9} ${event_amount}',
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900
                          ),
                        )
                    ),
                  ],
                )
            );
          }
        )
      ),
    );
  }
}

