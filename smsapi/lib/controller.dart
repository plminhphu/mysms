// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:background_sms/background_sms.dart';

class Controller extends GetConnect {
  RxInt timePM = 3.obs;
  RxBool stt = false.obs;
  RxInt sttCode = 0.obs;
  String server = 'https://sms.tayninh.store';
  String token = 'tayninh.store';
  RxString phone = ''.obs;
  RxString net = ''.obs;
  RxString subNet = ''.obs;
  RxList<String> netList = ['All', 'Stop'].obs;

  Future sysnNoti() async {
    await checkServer();
    await getNoti().then((body) async {
      if (body == null) {
        return;
      }
      if (body['id'].toString().isNotEmpty &&
          body['phone'].toString().isNotEmpty &&
          body['content'].toString().isNotEmpty) {
        sendSMS(
          id: body['id'].toString(),
          phoneNumber: body['phone'].toString(),
          message: body['content'].toString(),
        );
      }
    });
  }

  Future<dynamic> getNoti() async {
    if (server.length > 5) {
      GetStorage box = GetStorage();
      var headers = {
        'access_token': token,
        'bot_phone': box.read('phone').toString(),
        'bot_net': box.read('net').toString(),
      };
      var request = http.MultipartRequest('POST', Uri.parse(server));
      request.headers.addAll(headers);
      request.fields.addAll({'action': 'checkNotify'});
      http.StreamedResponse response = await request.send();
      sttCode.value = response.statusCode;
      if (sttCode.value == 200) {
        stt.value = true;
        dynamic data = await response.stream.bytesToString();
        dynamic body = jsonDecode(data);
        subNet.value = body['subNet'].toString();
        body['netList'] = "All,${body['netList']},Stop";
        netList.value = body['netList'].toString().split(',');
        return body;
      }
    } else {
      return null;
    }
  }

  Future sendSMS(
      {required String id,
      required String phoneNumber,
      required String message}) async {
    await BackgroundSms.isSupportCustomSim.then((isSim) async {
      if (isSim ?? false) {
        SmsStatus result = await BackgroundSms.sendMessage(
          phoneNumber: phoneNumber,
          message: message,
          simSlot: 1,
        );
        bool smsStatus = false;
        if (result == SmsStatus.sent) {
          smsStatus = true;
        }
        GetStorage box = GetStorage();
        var headers = {
          'access_token': token,
          'bot_phone': box.read('phone').toString(),
          'bot_net': box.read('net').toString(),
        };
        var request = http.MultipartRequest('POST', Uri.parse(server));
        request.headers.addAll(headers);
        request.fields.addAll({
          'action': 'setNotify',
          'idNotify': id,
          'sttNotify': smsStatus ? '1' : '0',
        });
        await request.send();
      }
    });
  }

  Future checkServer() async {
    GetStorage box = GetStorage();
    String ph = box.read('phone').toString();
    if (phone.value == 'null') {
      await box.write('phone', '');
    }
    if (ph.length > 8) {
      phone.value = ph;
    } else {
      stt.value = false;
    }
    String nt = box.read('net').toString();
    if (net.value == 'null') {
      await box.write('net', '');
    }
    if (nt.length > 1) {
      net.value = nt;
    } else {
      stt.value = false;
    }
    String sn = box.read('subnet').toString();
    if (subNet.value == 'null') {
      await box.write('subnet', '');
    }
    if (sn.length > 1) {
      subNet.value = sn;
    } else {
      stt.value = false;
    }
  }

  Future setPhone(String val) async {
    GetStorage box = GetStorage();
    await box.write('phone', val);
    phone.value = val;
    getNoti();
  }

  Future setNet(String val) async {
    GetStorage box = GetStorage();
    await box.write('net', val);
    net.value = val;
    getNoti();
  }
}
