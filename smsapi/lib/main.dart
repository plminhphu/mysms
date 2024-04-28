// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'package:background_sms/background_sms.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final cron = Cron();
  cron.schedule(
      Schedule.parse(
        Schedule(
          minutes: '*',
          hours: '*',
          days: '*',
          months: '*',
          weekdays: '*',
        ).toCronString(),
      ), () async {
    await Future.delayed(const Duration(seconds: 10)).whenComplete(() async {
      await sysnNoti().whenComplete(() async {
        await Future.delayed(const Duration(seconds: 10))
            .whenComplete(() async {
          await sysnNoti().whenComplete(() async {
            await Future.delayed(const Duration(seconds: 10))
                .whenComplete(() async {
              await sysnNoti().whenComplete(() async {
                await Future.delayed(const Duration(seconds: 10))
                    .whenComplete(() async {
                  await sysnNoti().whenComplete(() async {
                    await Future.delayed(const Duration(seconds: 10))
                        .whenComplete(() async {
                      await sysnNoti().whenComplete(() async {
                        await Future.delayed(const Duration(seconds: 10))
                            .whenComplete(() async {
                          await Future.delayed(const Duration(seconds: 10));
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  });
  runApp(const MyApp());
}

Future sysnNoti() async {
  await getNoti().then((body) async {
    if (body['id'].isNotEmpty &&
        body['content'].isNotEmpty &&
        body['botTele'].isNotEmpty &&
        body['chatId'].isNotEmpty) {
      sendTele(
        bot: body['botTele'],
        chat_id: body['chatId'],
        text: '${body['phone']} ${body['email']}: ${body['content']}',
      );
    }
    if (body['id'].isNotEmpty &&
        body['phone'].isNotEmpty &&
        body['content'].isNotEmpty) {
      sendSMS(
        phoneNumber: body['phone'].toString(),
        message: body['content'].toString(),
      );
    }
    if (body['id'].isNotEmpty && body['email'].isNotEmpty) {
      sendMail(
        email: body['email'].toString(),
        phone: body['phone'].toString(),
        message: body['content'].toString(),
      );
    }
  });
}

Future<dynamic> getNoti() async {
  var headers = {'access_token': '330798'};
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://plminhphu.com/admin/notify.adm'));
  request.fields.addAll({'action': 'checkNoti'});
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    var data = await response.stream.bytesToString();
    var body = jsonDecode(data);
    return body;
  }
}

Future sendSMS({required String phoneNumber, required String message}) async {
  SmsStatus result = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber, message: message);
  if (result == SmsStatus.sent) {
    print("Sent");
  }
}

Future<void> sendTele(
    {required String bot,
    required String chat_id,
    required String text}) async {
  var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://api.telegram.org/bot$bot/sendMessage?chat_id=-1001855567868$chat_id'));
  request.fields.addAll({'text': text});
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  }
}

Future<void> sendMail(
    {required String email, String phone = '', String message = ''}) async {
  var request =
      http.MultipartRequest('POST', Uri.parse('https://mails.tayninh.site'));
  request.fields.addAll({
    'api': 'tayninh',
    'address': email,
    'name': email,
    'subject': 'Xin chào $email',
    'html':
        'https://plminhphu.com/email.html?email=$email&phone=$phone&note=$message'
  });
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PL Minh Phú SMS',
      theme: ThemeData(
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'PL Minh Phú SMS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              strokeWidth: 10,
            ),
          ],
        ),
      ),
    );
  }
}
