import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_diary/add_page.dart';
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
  String fileName = 'diary.json';
  String filePath = '';
  dynamic myList = const Text('준비');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPath().then((value) => {showList()});
  }

  Future<void> getPath() async {
    directory = await getApplicationSupportDirectory(); // 모든 플랫폼에서 사용 가능하기 때문에
    if (directory != null) {
      filePath = '${directory!.path}/$fileName'; // 경로/경로/diary.json
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
                var d = snapshot.data; // String - [{'title' : 'asd'}....]
                var dataList = jsonDecode(d!) as List<dynamic>;
                return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = dataList[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['contents']),
                      trailing: const Icon(Icons.delete),
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
              onPressed: () {
                showList();
              },
              child: const Text('조회'),
            ),
            Expanded(
              child: myList,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage(
                filePath: filePath,
              ),
            ),
          );
          if (result == 'ok') {}
        },
        child: const Icon(Icons.pest_control_outlined),
      ),
    );
  }
}
