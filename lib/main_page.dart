import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_diary/add_page.dart';

void main() {
  runApp(const MainPage());
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Directory? directory;
  String fileName = 'diary.json';
  String filePath = '';
  dynamic myList = const Text('준비');
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getPath().then((value) => showList());
  }

  Future<void> getPath() async {
    directory = await getApplicationSupportDirectory();
    if (directory != null) {
      filePath = '${directory!.path}/$fileName';
      print(filePath);
    }
  }

  Future<void> deleteFile() async {
    try {
      var file = File(filePath);
      var result = file.delete().then((value) {
        print(value);
        showList();
      });
      print(result.toString());
    } catch (e) {
      print('delete error');
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
                var d = snapshot.data;
                var dataList = jsonDecode(d!) as List<dynamic>;
                if (dataList.isEmpty) {
                  return const Text('내용이 없습니다');
                }
                var filteredList = dataList.where((item) {
                  var itemDate = DateTime.parse(item['date']);
                  return itemDate.year == selectedDate.year &&
                      itemDate.month == selectedDate.month &&
                      itemDate.day == selectedDate.day;
                }).toList();
                if (filteredList.isEmpty) {
                  return const Text('해당 날짜에 내용이 없습니다');
                }
                return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = filteredList[index] as Map<String, dynamic>;
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
                  itemCount: filteredList.length,
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
      appBar: AppBar(
        title: const Text('일기장 앱'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                    );
                    if (newDate != null) {
                      setState(() {
                        selectedDate = newDate;
                      });
                      showList();
                    }
                  },
                  child: const Text('날짜 조회'),
                ),
                ElevatedButton(
                  onPressed: () {
                    deleteFile();
                  },
                  child: const Text('전부 삭제'),
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
          if (result == 'ok') {
            showList();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
