// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'package:background_sms/background_sms.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smsapi/controller.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var settings = InitializationSettings(android: android);
  await flnp.initialize(settings);
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Controller controller = Get.put(Controller(), tag: 'Controller');
  final cron = Cron();
  cron.schedule(
      Schedule.parse(
        Schedule(
          seconds: '*',
          minutes: '*',
          hours: '*',
          days: '*',
          months: '*',
          weekdays: '*',
        ).toCronString(),
      ), () async {
    int numPM = (60 / controller.timePM.value).floor();
    for (var i = 0; i < numPM; i++) {
      await Future.delayed(Duration(seconds: controller.timePM.value));
      await controller.sysnNoti();
    }
  });
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await GetStorage.init();
    GetStorage box = GetStorage();
    var request =
        http.MultipartRequest('POST', Uri.parse('https://sms.tayninh.store'));
    request.headers.addAll({
      'ACCESS_TOKEN': 'tayninh.store',
      'bot_phone': box.read('phone').toString(),
      'bot_net': box.read('net').toString(),
    });
    request.fields.addAll({'action': 'checkNotify'});
    http.StreamedResponse response = await request.send();
    var data = await response.stream.bytesToString();
    var body = jsonDecode(data);
    if (response.statusCode == 200) {
      if (body['id'].toString().isNotEmpty &&
          body['phone'].toString().isNotEmpty &&
          body['content'].toString().isNotEmpty) {
        await BackgroundSms.isSupportCustomSim.then((isSim) async {
          if (isSim ?? false) {
            SmsStatus result = await BackgroundSms.sendMessage(
              phoneNumber: body['phone'].toString(),
              message: body['content'].toString(),
            );
            bool smsStatus = true;
            if (result == SmsStatus.failed) {
              smsStatus = false;
            }
            GetStorage box = GetStorage();
            var headers = {
              'ACCESS_TOKEN': 'tayninh.store',
              'bot_phone': box.read('phone').toString(),
              'bot_net': box.read('net').toString(),
            };
            var request = http.MultipartRequest(
                'POST', Uri.parse('https://sms.tayninh.store'));
            request.headers.addAll(headers);
            request.fields.addAll({
              'action': 'setNotify',
              'idNotify': body['id'].toString(),
              'sttNotify': smsStatus ? '1' : '0',
            });
            await request.send().whenComplete(() async {
              await FlutterLocalNotificationsPlugin().show(
                int.parse(body['id'].toString()),
                '${smsStatus ? 'Đã gửi tin nhắn' : 'Thất bại trong lúc gửi'} đến ${box.read('phone')}',
                'Nội dung: ${body['content']}',
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
            });
          }
        });
      }
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SMS MyBot',
      theme: ThemeData(
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      onInit: () async {
        if (!GetPlatform.isWeb) {
          await [
            Permission.sms,
            Permission.backgroundRefresh,
          ].request();
        }
      },
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
  TextEditingController ctrlTextPhone = TextEditingController();
  String dropdownValue = '';
  @override
  void initState() {
    super.initState();
    controller.sysnNoti();
    load();
  }

  Future load() async {
    int numPM = (60 / controller.timePM.value).floor();
    for (var i = 0; i < numPM; i++) {
      await Future.delayed(Duration(seconds: controller.timePM.value));
      await controller.sysnNoti();
    }
  }

  @override
  Widget build(BuildContext context) {
    dropdownValue = controller.netList.first;
    return Scaffold(
      backgroundColor: context.width > 700 ? Colors.black : Colors.white,
      body: Obx(() {
        if (controller.phone.value != 'null' && controller.phone.value != '') {
          ctrlTextPhone.text = controller.phone.value;
        }
        if (controller.net.value != 'null' && controller.net.value != '') {
          if (!controller.netList.contains(controller.net.value)) {
            controller.net.value = controller.netList.last;
          }
          dropdownValue = controller.net.value;
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
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Server: https://sms.tayninh.store',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: controller.stt.value ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 20),
                      controller.stt.value
                          ? const Text(
                              'Đã kết nối',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              'Kết nối thất bại',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const SizedBox(width: 20),
                      Text(
                        controller.sttCode.value.toString(),
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String? value) {
                      controller.setNet(value!).whenComplete(() {
                        MySnackbar.show(
                          title: 'Đã cập nhật',
                          message: 'Đã cập nhật phương thức',
                        );
                      });
                      setState(() {
                        dropdownValue = value;
                      });
                    },
                    items: controller.netList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            dropdownValue == value
                                ? const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.check_box_outline_blank,
                                  ),
                            const SizedBox(width: 10),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.subNet.value,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ctrlTextPhone,
                    onSubmitted: (val) {
                      controller.setPhone(val).whenComplete(() {
                        MySnackbar.show(
                          title: 'Đã cập nhật',
                          message: 'Đã cập nhật số điện thoại',
                        );
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Số điện thoại:',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Bản quyền thuộc về tayninh.store',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.notifications_active),
        onPressed: () async {
          await Workmanager().cancelAll();
          if (!GetPlatform.isWeb) {
            await [
              Permission.accessNotificationPolicy,
              Permission.notification,
              Permission.backgroundRefresh,
            ].request();
          }
          for (int i = 0; i < 300; i++) {
            String uid = 'un$i';
            await Workmanager().registerPeriodicTask(
              "r$uid",
              "r$uid",
              frequency: const Duration(minutes: 15),
              initialDelay: Duration(seconds: i * 3),
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
            title: 'Bắt đầu chạy dưới nền',
            message: 'Đã khởi tạo chanel chạy ngầm dưới ứng dụng',
          );
          await Future.delayed(const Duration(seconds: 3));
          await FlutterLocalNotificationsPlugin().show(
            001,
            'Bắt đầu chạy dưới nền',
            'Đã khởi tạo chanel chạy ngầm dưới ứng dụng',
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
