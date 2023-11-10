import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/AttendanceDataModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({Key? key}) : super(key: key);
  final String title = "Add New Record";

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final phoneFocus = FocusNode();
  bool nameNotEmpty = false;
  bool phoneNotEmpty = false;
  bool nameValidate = false;
  bool phoneValidate = false;
  String phoneErrText = "";
  String directory =
      "C:\\Users\\USER\\Desktop\\TARC\\AInternship\\vimigo\\attendance_app\\data";

  @override
  void initState() {
    super.initState();
    nameController.addListener(nameListener);
    phoneController.addListener(phoneListener);
  }

  @override
  void dispose() {
    nameController.removeListener(nameListener);
    nameController.dispose();
    phoneController.removeListener(phoneListener);
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            TextField(
              controller: nameController,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')),
              ],
              decoration: InputDecoration(
                hintText: 'Your Name',
                labelText: 'Name',
                errorText: nameValidate ? 'Oops, you miss out here' : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.red, width: 3)),
                prefixIcon: Icon(Icons.person),
                suffixIcon: nameNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            nameController.clear();
                            nameNotEmpty = false;
                          });
                        },
                      )
                    : null,
              ),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(phoneFocus),
            ),
            SizedBox(height: 20),
            TextField(
              focusNode: phoneFocus,
              controller: phoneController,
              decoration: InputDecoration(
                hintText: "Your Phone No. (eg. 0xxxxxxxxxx)",
                labelText: 'Phone No.',
                errorText: phoneValidate ? phoneErrText : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.red, width: 3)),
                prefixIcon: Icon(Icons.phone),
                suffixIcon: phoneNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            phoneController.clear();
                            phoneNotEmpty = false;
                          });
                        },
                      )
                    : null,
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 11,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    nameController.text.isEmpty
                        ? nameValidate = true
                        : nameValidate = false;
                    if (phoneController.text.isEmpty ||
                        phoneController.text.length < 10) {
                      phoneValidate = true;
                      if (phoneController.text.isEmpty)
                        phoneErrText = "Oops, you miss out here";
                      else
                        phoneErrText = "Invalid format (eg. 0xxxxxxxxxx)";
                    } else {
                      phoneValidate = false;
                    }

                    nameValidate == false && phoneValidate == false
                        ? writeJsonData()
                        : print('hello');
                  });
                },
                child: Text('Submit'))
          ]),
        ));
  }

  void nameListener() {
    setState(() {
      nameNotEmpty = nameController.text.isNotEmpty;
    });
  }

  void phoneListener() {
    setState(() {
      phoneNotEmpty = phoneController.text.isNotEmpty;
    });
  }

  // Future<void> writeJsonData() async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   File file = File(directory.path + '/attendance_list.json');
  //   // File file = File('C:\\Users\\USER\\Desktop\\TARC\\AInternship\\vimigo\\attendance_app\\data\\attendance_list.json');

  //   print('filepath: ' + file.toString());

  //   final AttendanceDataModel newData = AttendanceDataModel(
  //     name: nameController.text, // Replace with the value from your text field
  //     phone:
  //         phoneController.text, // Replace with the value from your text field
  //     oriDate: getCurrentTime(),
  //   );

  //   print(newData);

  //   List<AttendanceDataModel> existingData = [];

  //   final jsondata =
  //       await rootBundle.rootBundle.loadString('data/attendance_list.json');
  //   final list = json.decode(jsondata) as List<dynamic>;

  //   existingData.clear(); // Clear existing data before adding new data

  //   existingData.addAll(list
  //       .map((e) => AttendanceDataModel.fromJson(e))
  //       .cast<AttendanceDataModel>());

  //   print('existing data : ' + existingData.length.toString());
  //   // if (await file.exists()) {
  //   //   String data = await file.readAsString();
  //   //   Iterable decoded = json.decode(data);
  //   //   existingData =
  //   //       decoded.map((model) => AttendanceDataModel.fromJson(model)).toList();
  //   // }

  //   existingData.add(newData);
  //   print('new exist data : ' + existingData.length.toString());
  //   if (!await file.exists()){
  //     print('file not exist');
  //   } else {
  //     print('file exist');
  //   }

  //   List<Map<String, dynamic>> updatedData =
  //       existingData.map((record) => record.toJson()).toList();

  //   try {
  //     print(updatedData);
  //     await file.writeAsString(json.encode(updatedData));
  //     print('helo');

  //   } catch (e) {
  //     print('Error writing to file: $e');
  //   }
  // }

  Future<void> writeJsonData() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/attendance_list.json');

    print('filepath: ' + file.toString());

    final AttendanceDataModel newData = AttendanceDataModel(
      name: nameController.text,
      phone: phoneController.text,
      oriDate: getCurrentTime(),
    );

    print(newData);

    List<AttendanceDataModel> existingData = [];

    if (await file.exists()) {
      String data = await file.readAsString();
      Iterable decoded = json.decode(data);
      existingData =
          decoded.map((model) => AttendanceDataModel.fromJson(model)).toList();
    }

    print('existing data : ' + existingData.length.toString());

    existingData.add(newData);
    print('new exist data : ' + existingData.length.toString());

    List<Map<String, dynamic>> updatedData =
        existingData.map((record) => record.toJson()).toList();

    try {
      print(updatedData);
      await file.writeAsString(json.encode(updatedData));
      print('File write successful');
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  String getCurrentTime() {
    var now = DateTime.now();
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }
}
