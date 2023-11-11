// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:attendance_app/AttendanceDataModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  bool nameNotEmpty = false;
  bool phoneNotEmpty = false;
  bool nameValidate = false;
  bool phoneValidate = false;
  String phoneErrText = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Color lightGreen =
      Color(int.parse("#03DAC5".substring(1, 7), radix: 16) + 0xFF000000);
  Color lightPurple =
      Color(int.parse("#BB86FC".substring(1, 7), radix: 16) + 0xFF000000);
  Color lightBlue =
      Color(int.parse("#3700b3".substring(1, 7), radix: 16) + 0xFF000000);

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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'ADD NEW RECORDS',
                    style: GoogleFonts.eduTasBeginner(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              height: 90,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 24, top: 70),
              child: TextField(
                controller: nameController,
                focusNode: nameFocus,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'Your Name',
                  labelText: 'Name',
                  labelStyle: GoogleFonts.roboto(
                    color: nameFocus.hasFocus ? lightGreen : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 2,
                  ),
                  errorText: nameValidate ? 'Oops, you miss out here' : null,
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(width: 2, color: Colors.red)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(width: 2, color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: lightGreen, width: 2)),
                  prefixIcon: const Icon(
                    Icons.person,
                    size: 20,
                  ),
                  prefixIconColor: MaterialStateColor.resolveWith((states) =>
                      states.contains(MaterialState.focused)
                          ? lightGreen
                          : Colors.grey),
                  suffixIconColor: MaterialStateColor.resolveWith((states) =>
                      states.contains(MaterialState.focused)
                          ? lightGreen
                          : Colors.grey),
                  suffixIcon: nameNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                          ),
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
            ),
            Padding(
                padding: const EdgeInsets.only(
                    right: 24, left: 24, bottom: 30, top: 30),
                child: TextField(
                  focusNode: phoneFocus,
                  controller: phoneController,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: "Your Phone No. (without '-')",
                    labelText: 'Phone No.',
                    labelStyle: GoogleFonts.roboto(
                      color: phoneFocus.hasFocus ? lightGreen : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: 2,
                    ),
                    errorText: phoneValidate ? phoneErrText : null,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(width: 2, color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: lightGreen, width: 2)),
                    prefixIcon: const Icon(
                      Icons.phone,
                      size: 20,
                    ),
                    prefixIconColor: MaterialStateColor.resolveWith((states) =>
                        states.contains(MaterialState.focused)
                            ? lightGreen
                            : Colors.grey),
                    suffixIconColor: MaterialStateColor.resolveWith((states) =>
                        states.contains(MaterialState.focused)
                            ? lightGreen
                            : Colors.grey),
                    suffixIcon: phoneNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 20,
                            ),
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
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 21, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        nameController.text.isEmpty
                            ? nameValidate = true
                            : nameValidate = false;
                        if (phoneController.text.isEmpty ||
                            phoneController.text.length < 10) {
                          phoneValidate = true;
                          if (phoneController.text.isEmpty) {
                            phoneErrText = "Oops, you miss out here";
                          } else {
                            phoneErrText = "Invalid format (eg. 0xxxxxxxxxx)";
                          }
                        } else {
                          phoneValidate = false;
                        }

                        nameValidate == false && phoneValidate == false
                            ? writeJsonData()
                            : print('hello');
                      });
                    },
                    child: Text(
                      'SUBMIT',
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    )),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        nameController.clear();
                        phoneController.clear();
                      });
                    },
                    child: Text(
                      'CLEAR',
                      style: GoogleFonts.roboto(
                        color: lightPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ))
              ],
            ),
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
        const SnackBar(
          content: Text('Yay! Record added successfully'),
          duration: Duration(seconds: 5),
        ),
      );
      nameController.clear();
      phoneController.clear();
    } catch (e) {
      print('Error writing to file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
