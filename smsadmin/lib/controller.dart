// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Controller extends GetConnect {
  RxInt timePM = 2.obs;
  RxInt timeNM = 3.obs;
  RxInt typeData = 0.obs;
  RxBool stt = false.obs;
  RxInt sttCode = 0.obs;
  String server = 'https://sms.fiinvietnam.vn';
  String token = 'fiinvietnam.vn';
  RxList listNotify = [].obs;
  RxList listBot = [].obs;
  RxString dataS = ''.obs;
  RxInt dateNow = 0.obs;

  Future<dynamic> checkServer() async {
    if (server.length > 5) {
      var headers = {
        'ACCESS_TOKEN': 'fiinvietnam.vn',
      };
      var request = http.MultipartRequest('POST', Uri.parse(server));
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
    var headers = {
      'ACCESS_TOKEN': 'fiinvietnam.vn',
    };
    var request = http.MultipartRequest('POST', Uri.parse(server));
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
    var headers = {
      'ACCESS_TOKEN': 'fiinvietnam.vn',
    };
    var request = http.MultipartRequest('POST', Uri.parse(server));
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
}
