import 'package:cron/cron.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smsadmin/controller.dart';

class DataNotiPage extends StatefulWidget {
  const DataNotiPage({super.key});

  @override
  State<DataNotiPage> createState() => _DataNotiPageState();
}

class _DataNotiPageState extends State<DataNotiPage> {
  Controller controller = Get.find(tag: 'Controller');
  @override
  void initState() {
    super.initState();
    controller.getALLNotify();
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
      int numPM = (60 / controller.timeNM.value).floor();
      for (var i = 0; i < numPM; i++) {
        await Future.delayed(Duration(seconds: controller.timeNM.value));
        await controller.getALLNotify();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách các thông báo gần nhất'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await controller.getALLNotify();
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
              label: Text('ID'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('Trạng thái'),
            ),
            DataColumn2(
              label: Text('SĐT nhận'),
            ),
            DataColumn2(
              label: Text('Nội dung'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('Máy gửi'),
            ),
            DataColumn2(
              label: Text('Ngày tạo'),
            ),
            DataColumn2(
              label: Text('Ngày gửi'),
            ),
          ],
          rows: controller.listNotify.map((dynamic notify) {
            DateTime dateCreated = DateTime.fromMillisecondsSinceEpoch(
                int.parse(notify['notify_created']) * 1000);
            String created =
                '${dateCreated.hour}:${dateCreated.minute} ${dateCreated.day}/${dateCreated.month}/${dateCreated.year}';
            DateTime dateUpdated = DateTime.fromMillisecondsSinceEpoch(
                int.parse(notify['notify_created']) * 1000);
            String updated =
                '${dateUpdated.hour}:${dateUpdated.minute} ${dateUpdated.day}/${dateUpdated.month}/${dateUpdated.year}';
            Widget stt = SttNotify(stt: notify['notify_stt']);

            return DataRow(cells: [
              DataCell(Text(notify['notify_id'])),
              DataCell(stt),
              DataCell(Text(notify['notify_phone'])),
              DataCell(Text(notify['notify_content'])),
              DataCell(Text(notify['notify_bot'])),
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
class SttNotify extends StatelessWidget {
  String stt = '-2';
  SttNotify({super.key, required this.stt});

  @override
  Widget build(BuildContext context) {
    if (stt == '2') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.green, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Đã gửi thành công',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else if (stt == '1') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Đang chuẩn bị gửi',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else if (stt == '-1') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Gửi thất bại',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else if (stt == '0') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Chuẩn bị gửi',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(2)),
        child: const Text(
          'Không xác định',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
