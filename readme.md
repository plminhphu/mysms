Hướng dẫn triển khai TOOL SMS

- B1: Tạo mới tên miền phụ [sms.hpro24hcredit.vn]
- B2: Tạo mới database và add csdl mẫu [db_example.sql] vào
- B3: Giải nén source [server.zip] vào thư mục tên miền vừa tạo
- B4: Cấu hình lại csdl vừa tạo vào file [index.php]
- B5: Trên thiết bị quản lý cài đặt app [admin.apk] và bật thông báo
- B6: Trên thiết bị bot cài đặt app [mybot.apk] sau đó nhập số điện thoại, chọn mạng và bật thông báo
- B7: Test thử bằng code bên dưới: có thể tích hợp vào php

`````
var headers = {
  'access_token': 'hpro24hcredit.vn'
};
var request = http.MultipartRequest('POST', Uri.parse('https://sms.hpro24hcredit.vn'));
request.fields.addAll({
  'action': 'createNotify',
  'phone': '0987654321', // sdt nhan tin nhan
  'content': 'Ma OTP cua bạn la 123456' // noi dung tin nhan
});
request.headers.addAll(headers);
http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
  print(await response.stream.bytesToString());
}else {
  print(response.reasonPhrase);
}
`````

* Lưu ý: Trên thiết bị BOT có thể cấu hình cho phép truy cập dưới nền không giới hạn dữ liệu và pin để quyét nhanh và nhiều hơn
* Bản quyền đã được công ty HPRO24 mua lại