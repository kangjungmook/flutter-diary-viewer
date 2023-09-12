import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  String filePath;
  AddPage({super.key, required this.filePath});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  // var controller1 = TextEditingController();
  // var controller2 = TextEditingController();
  String filePath = '';
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filePath = widget.filePath;
  }

  Future<bool> fileSave() async {
    try {
      File file = File(filePath);
      List<dynamic> dataList = []; // 기존의 파일데이터를 읽어와서 저장할 목적
      var data = {
        'title': controllers[0].text,
        'contents': controllers[1].text,
      };

      // 기존에 파일이 있는 경우
      if (file.existsSync()) {
        var fileContents = await file.readAsString();
        dataList = jsonDecode(fileContents) as List<dynamic>;
      }
      // 내가 방금 쓴 글을 추가해야함
      dataList.add(data);
      var jsondata = jsonEncode(dataList); // 변수 map을 다시 json으로 변환
      var res = await file.writeAsString(jsondata);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filePath),
        centerTitle: true,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextFormField(
                controller: controllers[0],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('제목'),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: TextFormField(
                  controller: controllers[1],
                  maxLength: 500,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('내용'),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await fileSave(); // 저장이 잘 되었다면 T, 안되었다면 F
                  if (result == true) {
                    Navigator.pop(context, 'ok');
                  } else {
                    print('저장실패입니다.');
                  }
                },
                child: const Text('저장'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
