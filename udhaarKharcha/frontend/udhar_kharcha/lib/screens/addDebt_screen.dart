import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:udhar_kharcha/controllers/contactController.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:udhar_kharcha/controllers/requests.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({Key? key}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  String _user = 'Shubham';

  ContactsController _contact = ContactsController();
  final _controllerEvent = TextEditingController();
  final controller = TextEditingController();
  List<TextEditingController> _controllerAmount = [];

  // complile all persons
  List <Widget> _personsWidget = [];
  bool _validate = false;

  void _addPeople() {
    _personsWidget = [];
    _controllerAmount = [];
    for(var i = 0;i<_contact.selectedPeople.length;i++) {
      UdharPerson element = _contact.selectedPeople[i];
      print(element.name);
      _controllerAmount.add(TextEditingController());
      _personsWidget.add(udhaarEntryField(element.name, '0', i));
    }
    setState(() {});
  }

  void _onPersonFieldTapped(context) async {
    await _contact.openContactList(context);
    _addPeople();
  }

  addUdhar(String from, String event) async{
    try {
      for(var ele in _contact.selectedPeople) {
        print('Adding : ${ele.name}');
        AddUdhar obj = AddUdhar(from, ele.name, ele.amount, event);
        await obj.sendQuery();
      }
    }
    catch(e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _contact.getPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Color(0xfff7f6fb),
          title: const Text(
            'Add Udhaar',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
      body: screenBody(),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(vertical: 0,horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () async {
              setState(() {
                _controllerEvent.text.isEmpty ? _validate = true : _validate = false;
              });
              if(!_validate) {
                for (int i = 0; i < _contact.selectedPeople.length; i++) {
                  if (_controllerAmount[i].text.isNotEmpty)
                    _contact.selectedPeople[i].amount = int.parse(_controllerAmount[i].text);
                }
                await addUdhar(_user, _controllerEvent.text);
                Navigator.pop(context);
              }
            },
            label: Text(
              'Add',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
          ),
        ),
      ),
    );
  }


  Widget screenBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controllerEvent,
              onChanged: (_num) {
              },
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              style: TextStyle(
                  fontSize: 20
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20),
                border: OutlineInputBorder(),
                hintText: 'What is this for ?',
                errorText: _validate ? 'Cannot be empty' : null,
              ),
            ),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _onPersonFieldTapped(context),
              icon: Icon(Icons.add),
              label: Text('Add people to udhar',
                style: TextStyle(
                  fontSize: 15
                ),
              ),
            ),
            Column(
              children: _personsWidget,
            ),
          ],
        ),
      ),
    );
  }

  Widget udhaarEntryField(String name,String amount,int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child : Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text(
                      'Take from',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600]
                    ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
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
                  SizedBox(width: 20,),
                ],
              ),
            ),
            Text(
              '\u{20B9} ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(width: 5,),
            Flexible(
              flex: 1,
              child: TextField(
                controller: _controllerAmount[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0'
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
