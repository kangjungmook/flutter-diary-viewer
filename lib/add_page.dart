import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  final String filePath;

  AddPage({Key? key, required this.filePath});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String filePath = '';
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    filePath = widget.filePath;
  }

  Future<bool> fileSave() async {
    try {
      File file = File(filePath);
      List<dynamic> dataList = [];
      var data = {
        'title': controllers[0].text,
        'contents': controllers[1].text,
        'date': DateTime.now().toIso8601String(), // 현재 날짜를 추가
      };

      if (file.existsSync()) {
        var fileContents = await file.readAsString();
        dataList = jsonDecode(fileContents) as List<dynamic>;
      }
      dataList.add(data);
      var jsondata = jsonEncode(dataList);
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
                  labelText: '제목',
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
                    labelText: '내용',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await fileSave();
                  if (result == true) {
                    Navigator.pop(context, 'ok');
                  } else {
                    print('저장 실패입니다.');
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
