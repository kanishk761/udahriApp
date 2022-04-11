import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';


class ContactsController {
  List<ContactWithCounter> contacts = [];
  List<ContactWithCounter> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  bool contactsLoaded = false;

  List<bool> values = [];

  // final list returned
  List<UdharPerson> selectedPeople = [];

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    List<Contact> _contacts = await FlutterContacts.getContacts(
      withPhoto: false,
      withGroups: false,
      withThumbnail: false,
      withAccounts: false,
      withProperties: true);
    int count = 0;
    _contacts.forEach((element) {
      contacts.add(ContactWithCounter(count, element));
      count++;
      values.add(false);
    });
  }

  filterContacts(String val) {
    if (val.isNotEmpty) {
      return contacts.where((element) {
        Contact contact = element.contact;
        String searchTerm = val.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhereOrNull((phn) {
          String phnFlattened = flattenPhoneNumber(phn.normalizedNumber);
          return phnFlattened.contains(searchTermFlatten);
        });

        return phone != null;
      }).toList();
    }
  }


  Future<void> openContactList(context) async{
    selectedPeople = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isSearching = searchController.text.isNotEmpty;
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios)),
                      Text(
                        'Add your friends',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            List<UdharPerson> people = [];
                            for(var i=0;i<values.length;i++) {
                              if(values[i]) {
                                people.add(UdharPerson(
                                  contacts[i].contact.displayName,
                                  contacts[i].contact.phones.elementAt(0).normalizedNumber,
                                  0
                                ));
                              }
                            }
                            Navigator.pop(context,people);
                          },
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: TextField(
                      controller: searchController,
                      onChanged: (_val) {
                        print(_val);
                        var _lst = filterContacts(_val);
                        setState(() {
                          if(_lst==null)
                            isSearching = false;
                          else
                            contactsFiltered = _lst;
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor
                              )
                          ),
                          prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: isSearching == true ? contactsFiltered.length : contacts.length,
                      itemBuilder: (context, index) {
                        ContactWithCounter contactWithID = isSearching == true ? contactsFiltered[index] : contacts[index];
                        Contact contact = contactWithID.contact;
                        int ID = contactWithID.id;
                        return LabeledCheckbox(
                          label: contact.displayName,
                          value: values[ID],
                          onChanged: (bool newValue) {
                            setState(() {
                              values[ID] = newValue;
                            });
                          },
                          subtitle: contact.phones.isNotEmpty ? contact.phones.elementAt(0).normalizedNumber : '',
                        );
                      }
                    ),
                  )
                ]
              )
            );
          }
        );
      },
    );
  }

}

class LabeledCheckbox extends StatelessWidget {
  LabeledCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.subtitle
  }) : super(key: key);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
        child: CheckboxListTile(
          title: Text(label),
          value: value,
          onChanged: (bool? newValue) {
            onChanged(newValue!);
          },
          subtitle: Text(subtitle),
          secondary: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              child: Text(
                label.isNotEmpty ? label[0] : '',
                style: TextStyle(color: Colors.white)
              ),
              backgroundColor: Colors.redAccent
            )
          )
        )
      ),
    );
  }
}