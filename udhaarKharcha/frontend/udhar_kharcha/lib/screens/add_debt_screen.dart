import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udhar_kharcha/controllers/contactController.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';


class SplitBillsScreen extends StatefulWidget {
  const SplitBillsScreen({Key? key}) : super(key: key);

  @override
  State<SplitBillsScreen> createState() => _SplitBillsScreenState();
}

class _SplitBillsScreenState extends State<SplitBillsScreen> {
  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  ContactsController _contact = ContactsController();
  final _controllerEvent = TextEditingController();
  final controller = TextEditingController();
  List<TextEditingController> _controllerPaid = [];
  List<TextEditingController> _controllerBilled = [];

  // complile all persons
  List <Widget> _personsWidget = [];
  List <SplitBillPerson> _splitBillPeople = [];



  bool _validate = false;

  void _addPeople() {
    _personsWidget = [];
    _controllerPaid = [];
    _controllerBilled = [];
    _splitBillPeople = [];

    if(_contact.selectedPeople.isNotEmpty) {
      _controllerPaid.add(TextEditingController());
      _controllerBilled.add(TextEditingController());
      _splitBillPeople.add(SplitBillPerson(_username, _phoneNumber, 0, 0));
      _personsWidget.add(udhaarEntryField('You',_phoneNumber, 0, 0, 0));
    }
    for(var i = 0; i<_contact.selectedPeople.length; i++) {
      ContactPerson element = _contact.selectedPeople[i];
      _controllerPaid.add(TextEditingController());
      _controllerBilled.add(TextEditingController());
      _splitBillPeople.add(SplitBillPerson(element.name, element.phoneNumber, 0, 0));
      _personsWidget.add(udhaarEntryField(element.name, element.phoneNumber, 0, 0, i+1));
    }
    setState(() {});
  }

  void _onAddPeopleTapped(context) async {
    await _contact.openContactList(context);
    _addPeople();
  }

  AddBillSplit(String event) async{
    Map<String, double> participants_paid = {};
    Map<String, double> participants_amount_on_bill = {};
    _splitBillPeople.forEach((element) {
      participants_paid.addAll({element.phoneNumber : element.paidAmount});
      participants_amount_on_bill.addAll({element.phoneNumber : element.billedAmount});
    });
    try {
      BillSplit obj = BillSplit(participants_paid, participants_amount_on_bill, event);
      await obj.sendQuery();
      if(obj.success) {
        Navigator.pop(context);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${obj.message}'),duration: Duration(seconds: 1),)
        );
      }
    }
    catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation failed'),duration: Duration(seconds: 1),)
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _contact.getPermissions();
  }

  @override
  void dispose() {
    _controllerEvent.dispose();
    _controllerPaid.forEach((element) {
      element.dispose();
    });
    _controllerBilled.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: const Color(0xfff7f6fb),
      appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.purple),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: const Color(0xfff7f6fb),
          title: const Text(
            'Add Udhar',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
      body: screenBody(),
    );
  }


  Widget screenBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10,0,10,10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _controllerEvent,
            onChanged: (_num) {
            },
            maxLength: 50,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: const TextStyle(
                fontSize: 20
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(20),
              border: const OutlineInputBorder(),
              hintText: 'What is this for ?',
              errorText: _validate ? 'Cannot be empty' : null,
              counterText: '',
            ),
          ),

          TextButton.icon(
            onPressed: () => _onAddPeopleTapped(context),
            icon: const Icon(Icons.add),
            label: const Text('Add people to udhar',),
          ),

          Expanded(
            child: SingleChildScrollView(
              child : Column(
                children: _personsWidget,
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: const Text(
                'Add',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              onPressed: () async {
                setState(() {
                  _controllerEvent.text.isEmpty ? _validate = true : _validate = false;
                });
                bool uselessEntry = false;
                if(!_validate) {
                  double paidTotal = 0 , billTotal = 0;
                  for (int i = 0; i < _splitBillPeople.length; i++) {
                    if (_controllerPaid[i].text.isNotEmpty) {
                      _splitBillPeople[i].paidAmount = double.parse(_controllerPaid[i].text);
                      paidTotal += _splitBillPeople[i].paidAmount;
                    }
                    if (_controllerBilled[i].text.isNotEmpty) {
                      _splitBillPeople[i].billedAmount = double.parse(_controllerBilled[i].text);
                      billTotal += _splitBillPeople[i].billedAmount;
                    }
                    if(_splitBillPeople[i].paidAmount==0 &&_splitBillPeople[i].billedAmount==0){
                      uselessEntry = true;
                      break;
                    }
                  }
                  if(uselessEntry){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Some people are not involved in the event.')
                      )
                    );
                  }
                  else if(paidTotal!=0 && billTotal!=0 && paidTotal == billTotal) {
                    _splitBillPeople.forEach((element) {
                      print(element.name);
                      print(element.phoneNumber);
                      print(element.paidAmount);
                      print(element.billedAmount);
                    });
                    await AddBillSplit(_controllerEvent.text);
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              paidTotal != billTotal ? 'Paid amount and billed amount don\'t match.'
                                  : paidTotal == 0 ? 'Cannot be zero.'
                                  : 'Some error occured.'
                          )
                      )
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget udhaarEntryField(String name,String phone,double paid,double billed,int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child : Padding(
        padding: const EdgeInsets.fromLTRB(10,10,10,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 5,
              child: Column(
                children: [
                  TagWidget(emoji: '📞', label: phone, width: 110),
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text(
                      name,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 20,),

            Flexible(
              flex: 4,
              child: Column(
                children: [
                  TagWidget(emoji: '💸', label: 'Paid', width: 50),
                  Row(
                    children: [
                      Text(
                        '\u{20B9} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controllerPaid[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0'
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 20,),

            Flexible(
              flex: 4,
              child: Column(
                children: [
                  TagWidget(emoji: '🧾', label: 'Bill amount', width: 70),
                  Row(
                    children: [
                      Text(
                        '\u{20B9} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Flexible(
                        child: TextField(
                          controller: _controllerBilled[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0'
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
