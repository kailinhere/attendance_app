import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/AttendanceDataModel.dart';
import 'package:attendance_app/add_record.dart';
import 'package:attendance_app/view_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Attendance Records'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AttendanceDataModel> attendanceData = [];
  List<AttendanceDataModel> backupData = [];
  bool isDescending = true;
  bool isDuration = true;
  String timeText = "";
  final ScrollController scrollController = ScrollController();
  bool showEndListIndicator = false;
  TextEditingController searchController = TextEditingController();
  bool searchNotEmpty = false;

  Color lightGreen =
      Color(int.parse("#03DAC5".substring(1, 7), radix: 16) + 0xFF000000);
  Color lightPurple =
      Color(int.parse("#BB86FC".substring(1, 7), radix: 16) + 0xFF000000);
  Color darkGrey =
      Color(int.parse("#202020".substring(1, 7), radix: 16) + 0xFF000000);

  @override
  void initState() {
    super.initState();
    loadSharedPrefData();
    fetchData();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          showEndListIndicator = true;
        });
      } else {
        setState(() {
          showEndListIndicator = false;
        });
      }
    });
    searchController.addListener(searchListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.removeListener(searchListener);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
          SizedBox(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'ATTENDANCE RECORDS',
                  style: GoogleFonts.eduTasBeginner(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            height: 100,
          ),
          SizedBox(height: 30),
          Padding(
              padding: EdgeInsets.only(right: 18, left: 18, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    style: GoogleFonts.roboto(
                        color: Colors.white, fontSize: 18, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: 'Enter keyword..',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(width: 2, color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: lightGreen, width: 2)),
                      prefixIcon: Icon(Icons.search),
                      prefixIconColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.focused)
                              ? lightGreen
                              : Colors.grey),
                      suffixIconColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.focused)
                              ? lightGreen
                              : Colors.grey),
                      suffixIcon: searchNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                              ),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  searchNotEmpty = false;
                                  attendanceData = backupData;
                                });
                              },
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: searchList,
                  )),
                  IconButton(
                      onPressed: () => setState(() {
                            isDescending = !isDescending;
                            saveSharedPrefData();
                          }),
                      icon: Icon(
                          isDescending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 28)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isDuration = !isDuration;
                          saveSharedPrefData();
                        });
                      },
                      icon: Icon(
                        isDuration
                            ? Icons.calendar_today
                            : Icons.access_time_filled,
                        size: 24,
                      ))
                ],
              )),
          Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: attendanceData.length + 1,
                  itemBuilder: (context, index) {
                    if (index == attendanceData.length) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('You have reached the end of the list'),
                        ),
                      );
                    }

                    final sortedData = isDescending
                        ? attendanceData
                        : attendanceData.reversed.toList();

                    return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewDetailsPage(data: sortedData[index]))),
                        child: Card(
                          color: darkGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Adjust the radius as needed
                          ),
                          elevation: 5,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 22),
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset('assets/paint.png',
                                          width: 85),
                                      Positioned(
                                          child: Text(
                                        sortedData[index]
                                            .name!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: GoogleFonts.eduTasBeginner(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold),
                                      ))
                                    ],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 12),
                                          child: Text(
                                            sortedData[index].name.toString(),
                                            style: GoogleFonts.roboto(
                                                letterSpacing: 2,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: null,
                                          )),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 8, bottom: 6),
                                        child: Text(
                                          sortedData[index].phone.toString(),
                                          style: GoogleFonts.roboto(
                                            letterSpacing: 2,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: isDuration
                                            ? Text(
                                                sortedData[index]
                                                    .duration
                                                    .toString(),
                                                style: GoogleFonts.roboto(
                                                  letterSpacing: 2,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : Text(
                                                sortedData[index]
                                                    .dateStr
                                                    .toString(),
                                                style: GoogleFonts.roboto(
                                                  letterSpacing: 2,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      )
                                    ],
                                  ))
                                ],
                              )),
                        ));
                  })),
        ]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: lightGreen,
          elevation: 5,
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddRecordPage()))
                .then((value) {
              fetchData();
            });
          },
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
            ),
          ),
          tooltip: 'Add record',
        ));
  }

  Future<List<AttendanceDataModel>> readJsonData() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/attendance_list.json');

    print('filepath: ' + file.toString());
    List<AttendanceDataModel> existingData = [];

    if (await file.exists()) {
      String data = await file.readAsString();
      Iterable decoded = json.decode(data);
      existingData =
          decoded.map((model) => AttendanceDataModel.fromJson(model)).toList();
    }

    return existingData;
  }

  Future<void> fetchData() async {
    List<AttendanceDataModel> data = await readJsonData();
    setState(() {
      attendanceData =
          data.reversed.toList(); // Update the state with fetched data
    });
    backupData = attendanceData;
  }

  void loadSharedPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedIsDescending = prefs.getBool('isDescending') ?? true;
    bool savedIsDuration = prefs.getBool('isDuration') ?? true;
    setState(() {
      isDescending = savedIsDescending;
      isDuration = savedIsDuration;

      print('isDescending start: $isDescending');
      print('isDuration start: $isDuration');
    });
  }

  void saveSharedPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDescending', isDescending);
    prefs.setBool('isDuration', isDuration);

    print('isDescending stop: $isDescending');
    print('isDuration stop: $isDuration');
  }

  void searchListener() {
    setState(() {
      searchNotEmpty = searchController.text.isNotEmpty;
    });
  }

  void searchList(String query) {
    print('Search query: $query');
    attendanceData = backupData;

    if (query.isNotEmpty) {
      final result = attendanceData.where((data) {
        final name = data.name?.toLowerCase();
        final phone = data.phone;
        final date = data.dateStr?.toLowerCase();
        final input = query.toLowerCase();

        return name!.contains(input) ||
            phone!.contains(input) ||
            date!.contains(input);
      }).toList();

      setState(() => attendanceData = result);
    }
  }
}
