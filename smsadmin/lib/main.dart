// ignore_for_file: avoid_print, non_constant_identifier_names, unrelated_type_equality_checks

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smsadmin/controller.dart';
import 'package:smsadmin/data_bot.dart';
import 'package:smsadmin/data_noti.dart';

Future<void> main() async {
  await GetStorage.init();
  Get.put(Controller(), tag: 'Controller');
  runApp(const MyApp());
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
    );
  }
}
