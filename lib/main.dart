import 'dart:convert';

import 'package:attendance_app/AttendanceDataModel.dart';
import 'package:attendance_app/add_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  bool isDescending = true;
  bool isDuration = true;
  String timeText = "";
  final ScrollController scrollController = ScrollController();
  bool showEndListIndicator = false;

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
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(children: [
          Row(
            children: [
              IconButton(
                  onPressed: () => setState(() {
                        isDescending = !isDescending;
                        saveSharedPrefData();
                      }),
                  icon: Icon(
                      isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 28)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      isDuration = !isDuration;
                      saveSharedPrefData();
                    });
                  },
                  icon: Icon(isDuration
                      ? Icons.access_time_filled
                      : Icons.calendar_today))
            ],
          ),
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

                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  sortedData[index].name.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(sortedData[index].phone.toString()),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: isDuration
                                    ? Text(
                                        sortedData[index].duration.toString())
                                    : Text(
                                        sortedData[index].dateStr.toString()),
                              )
                            ],
                          )),
                    );
                  })),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push( 
                        context, 
                        MaterialPageRoute( 
                            builder: (context) => 
                                AddRecordPage())); 
          },
          child: Icon(Icons.add),
          tooltip: 'Add record',
        ));
  }

  Future<List<AttendanceDataModel>> readJsonData() async {
    final jsondata =
        await rootBundle.rootBundle.loadString('data/attendance_list.json');
    final list = json.decode(jsondata) as List<dynamic>;

    return list.map((e) => AttendanceDataModel.fromJson(e)).toList();
  }

  Future<void> fetchData() async {
    List<AttendanceDataModel> data = await readJsonData();
    setState(() {
      attendanceData =
          data.reversed.toList(); // Update the state with fetched data
    });
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
}
