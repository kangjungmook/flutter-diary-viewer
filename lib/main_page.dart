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
  String fileName = 'diary.json';
  String filePath = '';
  dynamic myList = const Text('준비');

  @override
  void initState() {
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

  Future<void> deleteFile() async {
    try {
      var file = File(filePath);
      var result = file.delete().then((value) => (value) {
            print(value);
            showList();
          });
      print(result.toString());
    } catch (e) {
      print('delet error');
    }
  }

  Future<void> deleteContents(int index) async {
    try {
      File file = File(filePath);
      var fileContents = await file.readAsString();
      var dataList = jsonDecode(fileContents) as List<dynamic>;
      dataList.removeAt(index);
      var jsondata = jsonEncode(dataList);
      var res = await file.writeAsString(jsondata);
      showList();
    } catch (e) {
      print('delete contents error');
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
                      trailing: IconButton(
                        onPressed: () {
                          deleteContents(index);
                        },
                        icon: const Icon(Icons.delete),
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
      } else {
        setState(() {
          myList = const Text('파일이 없습니다.');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showList();
                  },
                  child: const Text('조회'),
                ),
                ElevatedButton(
                  onPressed: () {
                    deleteFile();
                  },
                  child: const Text('삭제'),
                ),
              ],
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
        child: const Icon(Icons.apple),
      ),
    );
  }
}
