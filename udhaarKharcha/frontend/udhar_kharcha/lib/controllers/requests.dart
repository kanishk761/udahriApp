// ignore_for_file: non_constant_identifier_names
import 'package:dio/dio.dart';

var options = BaseOptions(
  baseUrl: 'http://ec2-43-204-23-206.ap-south-1.compute.amazonaws.com',
  connectTimeout: 5000,
  receiveTimeout: 3000,
);
Dio dio = Dio(options);

class AddUdhar {
	late String username_from;
	late String username_to;
	late int amount;
	late String event_name;

	AddUdhar(String username_f, String username_t, int amt, String event_n) {
		username_from = username_f;
		username_to = username_t;
		amount = amt;
		event_name = event_n;
	}

	Future<dynamic> sendQuery() async {
    try {
      dynamic response = await dio.post('/addUdhar', data: {
                      'username_from': username_from,
                      'username_to': username_to,
                      'amount': amount,
                      'event_name': event_name
                    });
      return response;
    }
    catch(e) {
      return;
    }
	}
}

class GetUdhar {
	late String username_from;

	GetUdhar(String username) {
		username_from = username;
	}

	Future<dynamic> sendQuery() async {

    try {
      dynamic response = await dio.post('/getUdhar', data: {
                      'username_from': username_from
                    });
      return response;
    }
    catch(e) {
      return;
    }
	}
}