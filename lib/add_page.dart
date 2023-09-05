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
                  print(title);
                  Navigator.pop(context, 'OK');
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
