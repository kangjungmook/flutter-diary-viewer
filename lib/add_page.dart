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
  String filePath = ' ';

  List<TextEditingController> contollers = [
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
        'title': contollers[0].text,
        'contents': contollers[1].text,
      };
      if (file.existsSync()) {
        var fileContents = await file.readAsString();
        dataList = jsonDecode(fileContents) as List<dynamic>;
      }
      dataList.add(data);
      var jsonData = jsonEncode(dataList);
      await file.writeAsString(jsonData, mode: FileMode.append);
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('title'),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: TextFormField(
                  controller: contollers[0],
                  maxLength: 500,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('contents'),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  var title = contollers[0].text;
                  var result = fileSave();
                  if (result == true) {
                    Navigator.pop(context, 'OK');
                  } else {
                    print('저장실패');
                  }
                },
                child: const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
