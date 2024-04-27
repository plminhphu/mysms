// import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // Workmanager().registerPeriodicTask(
  //   "task-identifier",
  //   "simpleTask",
  //   frequency: const Duration(seconds: 1),
  // );
  // AwesomeNotifications().initialize(
  //     // set the icon to null if you want to use the default app icon
  //     'resource://drawable/res_app_icon',
  //     [
  //       NotificationChannel(
  //           channelGroupKey: 'basic_channel_group',
  //           channelKey: 'basic_channel',
  //           channelName: 'Basic notifications',
  //           channelDescription: 'Notification channel for basic tests',
  //           defaultColor: const Color.fromARGB(255, 36, 30, 216),
  //           ledColor: Colors.white)
  //     ],
  //     channelGroups: [
  //       NotificationChannelGroup(
  //           channelGroupKey: 'basic_channel_group',
  //           channelGroupName: 'Basic group')
  //     ],
  //     debug: true);
  runApp(const MyApp());
}

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     print("Native called background task: $task");
//     return Future.value(true);
//   });
// }

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
  Future _sendSMS(String message, List<String> recipents) async {
    // AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //   id: 10,
    //   channelKey: 'basic_channel',
    //   actionType: ActionType.Default,
    //   title: 'Hello World!',
    //   body: 'This is my first notification!',
    //   wakeUpScreen: true,
    //   badge: 1,
    // ));
    // for (var recipent in recipents) {
    //   SmsStatus result = await BackgroundSms.sendMessage(
    //       phoneNumber: recipent, message: message);
    //   if (result == SmsStatus.sent) {
    //     print("Sent");
    //   } else {
    //     print("Failed");
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String message = "This is a test message!";
          List<String> recipents = ["0329886884"];
          await _sendSMS(message, recipents);
        },
        child: const Icon(Icons.question_mark_outlined),
      ),
    );
  }
}
