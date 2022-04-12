import 'package:flutter_contacts/flutter_contacts.dart';

class UdharPerson {
  late String name;
  late String phoneNumber;
  late int amount;
  UdharPerson(this.name,this.phoneNumber,this.amount);
}

class ContactWithCounter{
  late Contact contact;
  late int id;
  ContactWithCounter(this.id,this.contact);
}