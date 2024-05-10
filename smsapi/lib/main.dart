// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:background_sms/background_sms.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smsapi/controller.dart';

Future<void> main() async {
  await GetStorage.init();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS MyBot',
      theme: ThemeData(
        useMaterial3: false,
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
  TextEditingController ctrlTextPhone = TextEditingController();
  TextEditingController ctrlTextToken = TextEditingController();
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
        if (controller.server.value != 'null' &&
            controller.server.value != '') {
          ctrlTextServer.text = controller.server.value;
        }
        if (controller.token.value != 'null' && controller.token.value != '') {
          ctrlTextToken.text = controller.token.value;
        }
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
                  const SizedBox(height: 10),
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
                      controller.setNet(value!);
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
                  const SizedBox(height: 5),
                  Text(
                    controller.subNet.value,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                  TextField(
                    controller: ctrlTextPhone,
                    onSubmitted: (val) {
                      controller.setPhone(val);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone:',
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          GetStorage box = GetStorage();
          await BackgroundSms.sendMessage(
            phoneNumber: box.read('phone').toString(),
            message: 'Test',
            simSlot: 1,
          );
        },
      ),
    );
  }
}
