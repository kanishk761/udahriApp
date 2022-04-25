import 'dart:io';
import 'package:intl/intl.dart';

String parseDate(date,format) {
  final DateFormat formatter = DateFormat(format);
  final String formatted = formatter.format(HttpDate.parse(date));
  return formatted;
}