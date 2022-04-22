// ignore_for_file: non_constant_identifier_names
import 'package:dio/dio.dart';

var options = BaseOptions(
  baseUrl: 'http://ec2-35-154-234-121.ap-south-1.compute.amazonaws.com',
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
      response = response.data;
      success = response['success'];
      message = response['message'];
      data = Map<String, dynamic>.from(response['data']);
      print(message);
    }
    catch(e) {
      print(e);
    }
  }
}

class UpdateToken {
  late String phone_no;
  late String fcm_token;

  bool success = false;
  String message = "Network Error";
  Map data = {};

  UpdateToken(String phone_n, String fcm_t) {
    phone_no = phone_n;
    fcm_token = fcm_t;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/update_token', data: {
                      'phone_no': phone_no,
                      'fcm_token': fcm_token
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = Map<String, dynamic>.from(response['data']);
      print('response: '+ message);
    }
    catch(e) {
      print(e);
    }
	}
}

class GetPairDetails {
  late String user_id_from;
  late String user_id_to;

  bool success = false;
  String message = "Network Error";
  List data = [];

  GetPairDetails(String user_id_f, String user_id_t) {
    user_id_from = user_id_f;
    user_id_to = user_id_t;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/get_pair_details', data: {
                      'user_id_from': user_id_from,
                      'user_id_to': user_id_to
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = response['data'];
      print('response: '+ message);
    } on DioError catch(e) {
      print(e.message);
    }
	}
}

class BillSplit {
  late Map<String, double> participants_paid;
  late Map<String, double> participants_amount_on_bill;
  late String event_name;

  bool success = false;
  String message = "Network Error";
  Map data = {};

  BillSplit(Map<String, double> participants_p, Map<String, double> participants_amt_on_bill, String event_n) {
    participants_paid = participants_p;
    participants_amount_on_bill = participants_amt_on_bill;
    event_name = event_n;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/bill_split', data: {
                      'participants_paid': participants_paid,
                      'participants_amount_on_bill': participants_amount_on_bill,
                      'event_name': event_name
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = Map<String, dynamic>.from(response['data']);
      print('response: '+ message);
    }
    catch(e) {
      print(e);
    }
	}
}

class GetUdhar {
	late String user_phone_no;

	bool success = false;
	String message = "Network Error";
  Map data = {};

	GetUdhar(String user_phone_n) {
		user_phone_no = user_phone_n;
	}

	Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/get_udhars', data: {
                      'user_phone_no': user_phone_no
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = Map<String, dynamic>.from(response['data']);
      print('response: '+ message);
    }
    on DioError catch(e) {
      print(e.message);
    }
	}
}


class AddPersonalExpense {
  late String user_phone_no;
  late double amount;
  late String event_detail;

  bool success = false;
  String message = "Network Error";
  Map data = {};

  AddPersonalExpense(String user_phone_n, double amt, String event_d) {
    user_phone_no = user_phone_n;
    amount = amt;
    event_detail = event_d;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/personal_expense', data: {
                      'user_phone_no': user_phone_no,
                      'amount': amount,
                      'event_detail': event_detail
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
    }
    catch(e) {
      print(e);
    }
	}
}

class GetPersonalExpense {
  late String user_phone_no;

  bool success = false;
  String message = "Network Error";
  List data = [];

  GetPersonalExpense(String user_phone_n) {
    user_phone_no = user_phone_n;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/get_personal_expenses', data: {
                      'user_phone_no': user_phone_no
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = response['data'];
    }
    on DioError catch(e) {
      print(e.message);
    }
	}
}

class EventDetails {
  late String event_id;

  bool success = false;
  String message = "Network Error";
  Map data = {};

  EventDetails(String event_i) {
    event_id = event_i;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/event_details', data: {
                      'event_id': event_id
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = response['data'];
      print(data);
    }
    on DioError catch(e) {
      print(e.message);
    }
	}
}

class GetNotificationDetails {
  late String user_phone_no;

  bool success = false;
  String message = "Network Error";
  List data = [];

  GetNotificationDetails(String user_phone_n) {
    user_phone_no = user_phone_n;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post('/get_notification_details', data: {
                      'user_phone_no': user_phone_no
                    });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = response['data'];
      print(data);
    }
    on DioError catch(e) {
      print(e.message);
    }
	}
}

class ApproveRejectUdhar {
  late String user_phone_from;
  late String user_phone_to;
  late String event_id;
  late bool isApprove;

  bool success = false;
  String message = "Network Error";
  String data = '';

  ApproveRejectUdhar(String user_phone_f, String user_phone_t, String event_i, bool approve) {
    user_phone_from = user_phone_f;
    user_phone_to = user_phone_t;
    event_id = event_i;
    isApprove = approve;
  }

  Future<void> sendQuery() async {

    try {
      dynamic response = await dio.post(isApprove ? '/approve_udhar' : '/reject_udhar', data: {
        'user_phone_from': user_phone_from,
        'user_phone_to': user_phone_to,
        'event_id': event_id
      });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
      data = response['data'];
      print(data);
    }
    on DioError catch(e) {
      print(e.message);
    }
  }
}


// TODO : Settle request
class SettlePayments {
  late String payer_number;
  late String receiver_number;
  late double amount;

  bool success = false;
  String message = "Network Error";

  SettlePayments(String payer_no,String receiver_no,double amt) {
    payer_number = payer_no;
    receiver_number = receiver_no;
    amount = amt;
  }

  Future<void> sendQuery() async {
    try {
      dynamic response = await dio.post('/pay', data: {
        'payer_number': payer_number,
        'reciever_number' : receiver_number,
        'amount' : amount
      });
      response = response.data;//Map<String, dynamic>.from(response.data);
      success = response['success'];
      message = response['message'];
    }
    on DioError catch(e) {
      print(e.message);
    }
  }
}