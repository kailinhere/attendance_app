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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
        key: scaffoldKey,
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

  Future<void> writeJsonData() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/attendance_list.json');

    final AttendanceDataModel newData = AttendanceDataModel(
      name: nameController.text,
      phone: phoneController.text,
      oriDate: getCurrentTime(),
    );

    List<AttendanceDataModel> existingData = [];

    if (await file.exists()) {
      String data = await file.readAsString();
      Iterable decoded = json.decode(data);
      existingData =
          decoded.map((model) => AttendanceDataModel.fromJson(model)).toList();
    }

    existingData.add(newData);

    List<Map<String, dynamic>> updatedData =
        existingData.map((record) => record.toJson()).toList();

    try {
      print(updatedData);
      await file.writeAsString(json.encode(updatedData));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yay! Record added successfully'),
          duration: Duration(seconds: 5), 
        ),
      );
      nameController.clear();
      phoneController.clear();

    } catch (e) {
      print('Error writing to file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! Record not added.'),
          duration: Duration(seconds: 5), 
        ),
      );
    }
  }

  String getCurrentTime() {
    var now = DateTime.now();
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }
}
