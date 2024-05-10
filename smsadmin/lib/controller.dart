// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Controller extends GetConnect {
  RxInt timePM = 2.obs;
  RxInt timeNM = 3.obs;
  RxInt typeData = 0.obs;
  RxBool stt = false.obs;
  RxInt sttCode = 0.obs;
  RxString server = ''.obs;
  RxString token = ''.obs;
  RxList listNotify = [].obs;
  RxList listBot = [].obs;
  RxString dataS = ''.obs;
  RxInt dateNow = 0.obs;

  Future<dynamic> checkServer() async {
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
    if (server.value.length > 5) {
      GetStorage box = GetStorage();
      var headers = {
        'ACCESS_TOKEN': box.read('token').toString(),
      };
      var request =
          http.MultipartRequest('POST', Uri.parse('https://${server.value}'));
      request.headers.addAll(headers);
      request.fields.addAll({'action': 'checkServer'});
      http.StreamedResponse response = await request.send();
      sttCode.value = response.statusCode;
      if (sttCode.value == 200) {
        stt.value = true;
        dynamic data = await response.stream.bytesToString();
        dynamic body = jsonDecode(data);
        return body;
      } else {
        stt.value = false;
      }
    } else {
      return null;
    }
  }

  Future<dynamic> getALLNotify() async {
    GetStorage box = GetStorage();
    var headers = {
      'ACCESS_TOKEN': box.read('token').toString(),
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('https://${server.value}'));
    request.fields.addAll({'action': 'getALLNotify'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      dynamic data = await response.stream.bytesToString();
      dynamic body = jsonDecode(data.toString());
      List<dynamic> list = body['data'];
      listNotify.clear();
      listNotify.addAll(list);
    } else {}
  }

  Future<dynamic> getALLBot() async {
    GetStorage box = GetStorage();
    var headers = {
      'ACCESS_TOKEN': box.read('token').toString(),
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('https://${server.value}'));
    request.fields.addAll({'action': 'getALLBot'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      dynamic data = await response.stream.bytesToString();
      dynamic body = jsonDecode(data.toString());
      dateNow.value = int.parse(body['now'].toString());
      List<dynamic> list = body['data'];
      listBot.clear();
      listBot.addAll(list);
    } else {}
  }

  Future setServer(String val) async {
    GetStorage box = GetStorage();
    box.write('server', val);
    server.value = val;
    checkServer();
  }

  Future setToken(String val) async {
    GetStorage box = GetStorage();
    box.write('token', val);
    token.value = val;
    checkServer();
  }
}
