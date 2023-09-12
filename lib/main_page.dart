import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_diary/add_page.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({
    super.key,
  });

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  Directory? directory;
  String filePath = '';
  dynamic myList = const Text('준비');

  @override
  void initState() async {
    super.initState();
    getPath();
  }

  Future<void> getPath() async {
    directory = await getApplicationSupportDirectory();
    if (directory != null) {
      var fileName = 'diary.json';
      filePath = '${directory!.path}/$fileName';
      print(filePath);
    }
  }

  Future<void> showList() async {
    try {
      var file = File(filePath);
      if (file.existsSync()) {
        setState(() {
          myList = FutureBuilder(
            future: file.readAsString(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var d = snapshot.data;
                var dataList = jsonDecode(d!) as List<dynamic>;
                return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = dataList[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text(
                        data['contents'],
                        trailing: const Icon(Icons.delete),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: dataList.length,
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          );
        });
      }
    } catch (e) {
      print('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showList();
            },
            child: const Text('조회'),
          ),
          Expanded(child: myList),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage(filePath: filePath),
            ),
          );
          if (result == 'ok') {
            showList();
          }
        },
        child: const Icon(Icons.apple),
      ),
    );
  }
}
