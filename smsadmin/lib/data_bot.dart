import 'package:cron/cron.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smsadmin/controller.dart';

class DataBotPage extends StatefulWidget {
  const DataBotPage({super.key});

  @override
  State<DataBotPage> createState() => _DataBotPageState();
}

class _DataBotPageState extends State<DataBotPage> {
  Controller controller = Get.find(tag: 'Controller');
  @override
  void initState() {
    super.initState();
    controller.getALLBot();
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
        await controller.getALLBot();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách các thiết bị'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await controller.getALLBot();
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Obx(
        () => DataTable2(
          columnSpacing: 10,
          horizontalMargin: 10,
          columns: const [
            DataColumn2(
              label: Text('SĐT thiết bị'),
            ),
            DataColumn2(
              label: Text('Trạng thái'),
            ),
            DataColumn2(
              label: Text('Nhà mạng'),
            ),
            DataColumn2(
              label: Text('Kết nối gần nhất'),
            ),
            DataColumn2(
              label: Text('Tin đã gửi'),
            ),
            DataColumn2(
              label: Text('Ngày kết nối'),
            ),
            DataColumn2(
              label: Text('Ngày gửi gần nhất'),
            ),
          ],
          rows: controller.listBot.map((dynamic bot) {
            DateTime dateLoged = DateTime.fromMillisecondsSinceEpoch(
                int.parse(bot['bot_loged']) * 1000);
            String loged =
                '${dateLoged.hour}:${dateLoged.minute} ${dateLoged.day}/${dateLoged.month}/${dateLoged.year}';
            DateTime dateCreated = DateTime.fromMillisecondsSinceEpoch(
                int.parse(bot['bot_created']) * 1000);
            String created =
                '${dateCreated.hour}:${dateCreated.minute} ${dateCreated.day}/${dateCreated.month}/${dateCreated.year}';
            DateTime dateUpdated = DateTime.fromMillisecondsSinceEpoch(
                int.parse(bot['bot_created']) * 1000);
            String updated =
                '${dateUpdated.hour}:${dateUpdated.minute} ${dateUpdated.day}/${dateUpdated.month}/${dateUpdated.year}';
            Widget stt = SttBot(
              stt: dateLoged.millisecondsSinceEpoch,
              now: controller.dateNow.value * 1000,
            );
            Widget net = SttNet(net: bot['bot_net']);
            return DataRow(cells: [
              DataCell(Text(bot['bot_phone'])),
              DataCell(stt),
              DataCell(net),
              DataCell(Text(loged)),
              DataCell(Text(bot['bot_sended'])),
              DataCell(Text(created)),
              DataCell(Text(updated)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SttNet extends StatelessWidget {
  String net;
  SttNet({super.key, required this.net});

  @override
  Widget build(BuildContext context) {
    if (net == 'All') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.green, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Tất cả',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else if (net == 'Stop') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Mất kết nối',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.green, borderRadius: BorderRadius.circular(2)),
        child: Text(
          net,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }
}

// ignore: must_be_immutable
class SttBot extends StatelessWidget {
  int stt;
  int now;
  SttBot({super.key, required this.stt, required this.now});

  @override
  Widget build(BuildContext context) {
    if (stt >= (now - 5000)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.green, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Đang kết nối',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Mất kết nối',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
