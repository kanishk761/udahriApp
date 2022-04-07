import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';


class ContactsController {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();
  bool contactsLoaded = false;

  String selectedPerson = '';

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
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    contacts = _contacts;
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName!.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones!.firstWhereOrNull((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value!);
          return phnFlattened.contains(searchTermFlatten);
        });

        return phone != null;
      });
      contactsFiltered = _contacts;
    }
  }


  Future<void> openContactList(context) async{
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemsExist = ((isSearching == true && contactsFiltered.length > 0) || (isSearching != true && contacts.length > 0));
    selectedPerson = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        bool isSearching = searchController.text.isNotEmpty;
        return //ContactListView();
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: searchController,
                      onChanged: (_val) {
                        filterContacts();
                      },
                      decoration: InputDecoration(
                          labelText: 'Search',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(
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
                        shrinkWrap: true,
                        itemCount: isSearching == true ? contactsFiltered.length : contacts.length,
                        itemBuilder: (context, index) {
                          Contact contact = isSearching == true ? contactsFiltered[index] : contacts[index];
                          return ListTile(
                            onTap: () {
                              Navigator.pop(context,contact.displayName!);
                            },
                            title: Text(contact.displayName!),
                            subtitle: Text(
                                contact.phones!.isNotEmpty ? contact.phones!.elementAt(0).value! : ''
                            ),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: (contact.avatar != null && contact.avatar!.length > 0) ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.avatar!),
                              )
                                  :
                              CircleAvatar(
                                child: Text(contact.initials(),
                                    style: TextStyle(color: Colors.white)
                                ),
                                backgroundColor: Colors.redAccent
                              )
                            )
                          );
                        }
                    ),
                  )
                ]
            )
        );
      },
    );
  }

}


class ContactListView extends StatefulWidget {
  const ContactListView({Key? key}) : super(key: key);

  @override
  State<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  ContactsController obj = ContactsController();

  @override
  Widget build(BuildContext context) {
    bool isSearching = obj.searchController.text.isNotEmpty;
    return Container(
        padding: EdgeInsets.all(20),
        child: Column(
            children: <Widget>[
              Container(
                child: TextField(
                  controller: obj.searchController,
                  onChanged: (_val) {
                    obj.filterContacts();
                  },
                  decoration: InputDecoration(
                      labelText: 'Search',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(
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
                    shrinkWrap: true,
                    itemCount: isSearching == true ? obj.contactsFiltered.length : obj.contacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = isSearching == true ? obj.contactsFiltered[index] : obj.contacts[index];
                      return CheckboxListTile(
                        value: false,
                        onChanged: (bool? value) {
                          value = value!;
                        },
                        // onTap: () {
                        //   Navigator.pop(context,contact.displayName!);
                        // },
                        title: Text(contact.displayName!),
                        subtitle: Text(
                            contact.phones!.isNotEmpty ? contact.phones!.elementAt(0).value! : ''
                        ),
                        // leading: Container(
                        //     width: 36,
                        //     height: 36,
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //     ),
                        //     child: (contact.avatar != null && contact.avatar!.length > 0) ? CircleAvatar(
                        //       backgroundImage: MemoryImage(contact.avatar!),
                        //     )
                        //         :
                        //     CircleAvatar(
                        //         child: Text(contact.initials(),
                        //             style: TextStyle(color: Colors.white)
                        //         ),
                        //         backgroundColor: Colors.redAccent
                        //     )
                        // )
                      );
                    }
                ),
              )
            ]
        )
    );
  }
}
