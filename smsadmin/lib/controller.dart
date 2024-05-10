// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Controller extends GetConnect {
  RxInt timePM = 5.obs;
  RxBool stt = false.obs;
  RxInt sttCode = 0.obs;
  RxString server = ''.obs;
  RxString token = ''.obs;

  Future sysnNoti() async {
    await checkServer();
    await getNoti();
  }

  Future<dynamic> getNoti() async {
    if (server.value.length > 5) {
      GetStorage box = GetStorage();
      var headers = {
        'access_token': box.read('token').toString(),
        'bot_phone': box.read('phone').toString(),
        'bot_net': box.read('net').toString(),
      };
      var request =
          http.MultipartRequest('POST', Uri.parse('https://${server.value}'));
      request.headers.addAll(headers);
      request.fields.addAll({'action': 'checkNotify'});
      http.StreamedResponse response = await request.send();
      sttCode.value = response.statusCode;
      if (sttCode.value == 200) {
        stt.value = true;
        dynamic data = await response.stream.bytesToString();
        dynamic body = jsonDecode(data);
        return body;
      }
    } else {
      return null;
    }
  }

  Future checkServer() async {
    GetStorage box = GetStorage();
    String sv = box.read('server').toString();
    if (server.value == 'null') {
      box.write('server', '');
    }
    if (sv.length > 5) {
      server.value = sv;
    } else {
      stt.value = false;
    }
    String tk = box.read('token').toString();
    if (token.value == 'null') {
      box.write('token', '');
    }
    if (tk.length > 2) {
      token.value = tk;
    } else {
      stt.value = false;
    }
  }

  Future setServer(String val) async {
    GetStorage box = GetStorage();
    box.write('server', val);
    server.value = val;
    getNoti();
  }

  Future setToken(String val) async {
    GetStorage box = GetStorage();
    box.write('token', val);
    token.value = val;
    getNoti();
  }
}
