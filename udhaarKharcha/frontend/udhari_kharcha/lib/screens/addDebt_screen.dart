import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:udhari_kharcha/screens/contactController.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({Key? key}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {

  ContactsController _contact = ContactsController();

  List <Widget> _persons = [];
  final _controllerEvent = TextEditingController();
  dynamic _controllerPerson = TextEditingController();
  final _controllerAmount = TextEditingController();

  void _addPerson(String person,String amount) {
    _persons.insert(0, detailsCard(person,amount));
    _controllerPerson.clear();
    _controllerAmount.clear();
    setState(() {});
  }

  void _onPersonFieldTapped(context) async {
    await _contact.openContactList(context);
    _controllerPerson.text = _contact.selectedPerson;
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
            onPressed: (){},
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
                border: OutlineInputBorder(),
                hintText: 'What is this for ?',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Add your friends'
            ),
            SizedBox(height: 15),
            udhaarEntryField(),
            TextButton.icon(
              onPressed: () => _addPerson(_controllerPerson.text,_controllerAmount.text),
              icon: Icon(Icons.add),
              label: Text('Add person'),
            ),
            Column(
              children: _persons,
            ),
          ],
        ),
      ),
    );
  }

  Widget udhaarEntryField() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Take from'),
          SizedBox(width: 20,),

          Flexible(
            child: TextField(
              controller: _controllerPerson,
              onTap: () => _onPersonFieldTapped(context),
              style: TextStyle(),
              showCursor: false,
              readOnly: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 20),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded)
              ),
            ),
            flex: 5,
          ),
          SizedBox(width: 15,),
          Text(
            '\u{20B9} ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          Flexible(
            flex: 2,
            child: TextField(
              controller: _controllerAmount,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailsCard(String person,String amount) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        leading: Icon(Icons.south_west_rounded),
        iconColor: Colors.green,
        title: Text('Take from ${person} ${amount}'),
      ),
    );
  }

}
