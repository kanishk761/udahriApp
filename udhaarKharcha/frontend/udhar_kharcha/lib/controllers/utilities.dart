import 'dart:io';
import 'package:intl/intl.dart';

String parseDate(date,format) {
  final DateFormat formatter = DateFormat(format);
  final String formatted = formatter.format(HttpDate.parse(date));
  return formatted;
}

double precision(double num) {
  String num_string = num.toStringAsFixed(2);
  return double.parse(num_string);
}

Map<String, double> calculateTaxAmount(Map<String, double> bill, double tax_percent, double tax_amount) {
  double total_amount_including_tax = 0;
  double total_amount_excluding_tax = 0;

  bill.forEach((phone_no, amount) {
    total_amount_excluding_tax += amount;
  });

  double tax = (total_amount_excluding_tax * tax_percent) / 100;
  double difference = tax-tax_amount;
  if(difference.abs() >= 0.01) {
    return {};
  }

  total_amount_including_tax = total_amount_excluding_tax + tax_amount;

  double added_amount = 0;
  String last_phone_no = "";

  Map<String, double> bill_including_tax = {};

  bill.forEach((phone_no, amount) {
    double tax = precision((amount * tax_percent) / 100);
    print(tax);
    double taxed_amount = tax + amount;
    print(taxed_amount);
    bill_including_tax[phone_no] = taxed_amount;
    added_amount += taxed_amount;
    last_phone_no = phone_no;
  });
  double difference_in_amount = total_amount_including_tax - added_amount;
  bill_including_tax[last_phone_no] = precision(bill_including_tax[last_phone_no]! + difference_in_amount);

  return bill_including_tax;
}