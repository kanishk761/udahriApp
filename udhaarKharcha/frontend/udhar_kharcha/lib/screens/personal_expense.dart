import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/loading.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';
import 'package:intl/intl.dart';


class PersonalExpenseScreen extends StatefulWidget {
  const PersonalExpenseScreen({Key? key}) : super(key: key);

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

  bool personalExpenseLoading = true;


  // get personal expenses
  List expenses = [];  // List of lists of 3
  getPersonalExpense() async{
    try {
      setState(() {
        personalExpenseLoading = true;
      });
      GetPersonalExpense obj = GetPersonalExpense(_phoneNumber);
      await obj.sendQuery();
      setState(() {
        if(obj.success)
          expenses = obj.data;

        personalExpenseLoading = false;
      });
    }
    catch (e) {
      print('Failed to get personal expense');
    }
  }


  @override
  void initState() {
    print('personl init');
    getPersonalExpense();
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      body: personalExpenseLoading ? ShimmerLoading() : Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: () async{
            GetPersonalExpense obj = GetPersonalExpense(_phoneNumber);
            await obj.sendQuery();
            setState(() {
              expenses = obj.data;
            });
          },
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              String event_desc = expenses[index][0];
              String date = expenses[index][1];
              double event_amount = expenses[index][2];
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
      ),
      floatingActionButton :  FloatingActionButton.extended(
          onPressed: () async{
            await Navigator.pushNamed(context, '/addPersonal');
            getPersonalExpense();
          },
          label: const Text('Add Personal Expense'),
          icon: const Icon(Icons.add),
        )
    );

  }
}

