// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:dio/dio.dart';

var options = BaseOptions(
  baseUrl: 'http://ec2-43-204-23-206.ap-south-1.compute.amazonaws.com',
  connectTimeout: 5000,
  receiveTimeout: 3000,
);
Dio dio = Dio(options);

class SignUp {
  late String phone_no;
  late String username;
  String? upi_id;

  bool success = false;
  String message = "Network Error";
  Map data = {};

  SignUp(String phone, String user, String? upi) {
    phone_no = phone;
    username = user;
    upi_id = upi;
  }

  Future<void> sendQuery() async {
    try {
      dynamic response = await dio.post('/signup', data: {
        'phone_no': phone_no,
        'username': username,
        'upi_id': upi_id
      });
      response = jsonDecode(response.data);
      success = response.success;
      message = response.message;
      data = response.data;
    }
    catch(e) {}
  }

}

class AddUdhar {
	late String username_from;
	late String username_to;
	late int amount;
	late String event_name;

  bool success = false;
  String message = "Network Error";
  Map data = {};

	AddUdhar(String username_f, String username_t, int amt, String event_n) {
		username_from = username_f;
		username_to = username_t;
		amount = amt;
		event_name = event_n;
	}

	Future<void> sendQuery() async {
    try {
      dynamic response = await dio.post('/addUdhar', data: {
                      'username_from': username_from,
                      'username_to': username_to,
                      'amount': amount,
                      'event_name': event_name
                    });
      response = jsonDecode(response.data);
      success = response.success;
      message = response.message;
      data = response.data;
    }
    catch(e) {}
	}
}

class GetUdhar {
	late String username_from;
	bool success = false;
	String message = "Network Error";
	Map data = {};

	GetUdhar(String username) {
		username_from = username;
	}

	Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/getUdhar', data: {
                      'username_from': username_from
                    });
      response = jsonDecode(response.data);
      success = response.success;
      message = response.message;
      data = response.data;
    }
    catch(e) {}
	}
}