// ignore_for_file: avoid_print, non_constant_identifier_names, unrelated_type_equality_checks

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smsadmin/controller.dart';
import 'package:smsadmin/data_bot.dart';
import 'package:smsadmin/data_noti.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
  var android = const AndroidInitializationSettings('logo');
  var settings = InitializationSettings(android: android);
  await flnp.initialize(settings);
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().cancelAll();
  Get.put(Controller(), tag: 'Controller');
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await GetStorage.init();
    GetStorage box = GetStorage();
    String sv = box.read('server').toString();
    box.remove('notify');
    var headers = {
      'ACCESS_TOKEN': box.read('token').toString(),
    };
    var request = http.MultipartRequest('POST', Uri.parse('https://$sv'));
    request.fields.addAll({'action': 'getLastNotify'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      dynamic data = await response.stream.bytesToString();
      dynamic body = jsonDecode(data.toString());
      await FlutterLocalNotificationsPlugin().show(
        int.parse(body['notify_id'].toString()),
        'Bot ${body['notify_bot']} ${body['notify_stt'] == '2' ? 'đã gửi đến' : 'chưa thể gửi'} ${body['notify_phone']}',
        'Nội dung: ${body['notify_content']}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sms-notify',
            'SmsNotify',
            channelDescription: 'SMS Notify',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Admin',
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: const ColorScheme.light(primary: Colors.black),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Controller controller = Get.find(tag: 'Controller');
  TextEditingController ctrlTextServer = TextEditingController();
  TextEditingController ctrlTextToken = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.checkServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.width > 700 ? Colors.black : Colors.white,
      body: Obx(() {
        if (controller.server.value != 'null' &&
            controller.server.value != '') {
          ctrlTextServer.text = controller.server.value;
        }
        if (controller.token.value != 'null' && controller.token.value != '') {
          ctrlTextToken.text = controller.token.value;
        }
        return Center(
          child: Container(
            width: context.width > 700 ? 500 : context.width - 20,
            margin: context.width > 700
                ? const EdgeInsets.symmetric(vertical: 50)
                : null,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: controller.stt.value ? Colors.green : Colors.red,
                width: 5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 15),
                  TextField(
                    controller: ctrlTextServer,
                    onSubmitted: (val) {
                      controller.setServer(val);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Server:',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: ctrlTextToken,
                    onSubmitted: (val) {
                      controller.setToken(val);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Token:',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              controller.stt.value ? Colors.green : Colors.red),
                        ),
                        onPressed: () {
                          if (controller.stt.value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DataBotPage()),
                            );
                          } else {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text(
                                    'Ồ, có lỗi!!!',
                                  ),
                                  content: const Text(
                                    'Bạn không có quyền xem dữ liệu rồi! Vui lòng cấu hình lại server rồi tính tiếp.',
                                  ),
                                  actions: [
                                    CupertinoButton(
                                      child: const Text('Đóng'),
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop("Discard");
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('Danh sách thiết bị'),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              controller.stt.value ? Colors.green : Colors.red),
                        ),
                        onPressed: () {
                          if (controller.stt.value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DataNotiPage()),
                            );
                          } else {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text(
                                    'Ồ, có lỗi!!!',
                                  ),
                                  content: const Text(
                                    'Bạn không có quyền xem dữ liệu rồi! Vui lòng cấu hình lại server rồi tính tiếp.',
                                  ),
                                  actions: [
                                    CupertinoButton(
                                      child: const Text('Đóng'),
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop("Discard");
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('Danh sách thông báo'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.notifications_active),
        onPressed: () async {
          await [
            Permission.accessNotificationPolicy,
            Permission.notification,
            Permission.backgroundRefresh,
          ].request();
          for (int i = 0; i < 180; i++) {
            String uid = 'un$i';
            await Workmanager().registerPeriodicTask(
              "r$uid",
              "r$uid",
              frequency: const Duration(minutes: 15),
              initialDelay: Duration(seconds: i * 5),
              tag: "r$uid",
              constraints: Constraints(
                networkType: NetworkType.connected,
                requiresCharging: false,
                requiresBatteryNotLow: false,
                requiresStorageNotLow: false,
              ),
            );
          }
          MySnackbar.show(
            title: 'Đã đăng ký',
            message: 'Đã tạo kênh thông báo',
          );
          await Future.delayed(const Duration(seconds: 3));
          await FlutterLocalNotificationsPlugin().show(
            001,
            'Đã đăng ký',
            'Đã tạo kênh thông báo',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'sms-notify',
                'SmsNotify',
                channelDescription: 'SMS Notify',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MySnackbar {
  MySnackbar();
  static Future show({
    required String title,
    required String message,
  }) async {
    Get.snackbar(
      title,
      message,
      margin: const EdgeInsets.all(20),
      borderRadius: 10,
      borderColor: Colors.black,
      borderWidth: 1,
      backgroundColor: Colors.white,
      barBlur: 33,
      overlayBlur: 5,
      overlayColor: Colors.black.withOpacity(.3),
      colorText: Colors.black,
      boxShadows: [
        const BoxShadow(
          color: Colors.grey,
          blurRadius: 30,
          blurStyle: BlurStyle.normal,
        )
      ],
    );
  }
}
