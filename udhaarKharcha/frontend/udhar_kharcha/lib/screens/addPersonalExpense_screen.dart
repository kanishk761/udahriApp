import 'dart:ui';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udhar_kharcha/controllers/requests.dart';


class AddPersonalExpenseScreen extends StatefulWidget {
  const AddPersonalExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddPersonalExpenseScreen> createState() => _AddPersonalExpenseScreenState();
}

class _AddPersonalExpenseScreenState extends State<AddPersonalExpenseScreen> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';


  TextEditingController _controllerAmount = TextEditingController();
  TextEditingController _controllerDesc = TextEditingController();

  bool showPrefix = false;
  bool _validateAmt = false;
  bool _validateDesc = false;

  addPersonalExpense() async {
    try {
      AddPersonalExpense obj = AddPersonalExpense(
        _phoneNumber,
        double.parse(_controllerAmount.text),
        _controllerDesc.text
      );
      await obj.sendQuery();
    }
    catch (e) {
      print('Failed to add personal expense');
    }
  }

  @override
  void dispose() {
    _controllerDesc.dispose();
    _controllerAmount.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.purple),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Color(0xfff7f6fb),
          title: const Text(
            'Add Personal Expense',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeTextField(
              maxLength: 9,
              minWidth: 100,
              autofocus: true,
              controller: _controllerAmount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: showPrefix ? '\u{20B9}' : '',
                hintText: '\u{20B9} 0',
                counterText: '',
                errorText: _validateAmt ? 'Enter amount' : null,
              ),
              fullwidth: false,
              minFontSize: 24,
              style: TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
              onChanged: (_val) {
                if(_val.length > 0)
                  showPrefix = true;
                else
                  showPrefix = false;
                setState(() {});
              },
            ),
            SizedBox(height: 30,),

            TextField(
              controller: _controllerDesc,
              onChanged: (_num) {
              },
              maxLength: 50,
              style: TextStyle(
                  fontSize: 20
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20),
                border: OutlineInputBorder(),
                hintText: 'What is this for ?',
                counterText: '',
                errorText: _validateDesc ? 'Field cannot be empty' : null,
              ),
            ),
            Expanded(child: Container()),
            SizedBox(
              width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                    'Add',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      if(_controllerAmount.text.isEmpty)
                        _validateAmt = true;
                      else
                        _validateAmt = false;
                      if(_controllerDesc.text.isEmpty)
                        _validateDesc = true;
                      else
                        _validateDesc = false;
                    });
                    if(!_validateAmt && !_validateDesc) {
                      await addPersonalExpense();
                      Navigator.of(context).pop();
                    }
                  },
                )
            )
          ],
        ),
      )
    );
  }

}
