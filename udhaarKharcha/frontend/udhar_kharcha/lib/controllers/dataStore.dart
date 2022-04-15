import 'package:flutter_contacts/flutter_contacts.dart';

class UdharPerson {
  late String name;
  late String phoneNumber;
  late int amount;
  UdharPerson(this.name,this.phoneNumber,this.amount);
}


class ContactPerson {
  late String name;
  late String phoneNumber;
  ContactPerson(this.name,this.phoneNumber);
}


class ContactWithCounter{
  late Contact contact;
  late int id;
  ContactWithCounter(this.id,this.contact);
}

class SplitBillPerson {
  late String name;
  late String phoneNumber;
  late double paidAmount;
  late double billedAmount;
  SplitBillPerson(this.name,this.phoneNumber,this.paidAmount,this.billedAmount);
}