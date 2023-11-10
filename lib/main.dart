import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/AttendanceDataModel.dart';
import 'package:attendance_app/add_record.dart';
import 'package:attendance_app/view_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:path_provider/path_provider.dart';
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
  List<AttendanceDataModel> backupData = [];
  bool isDescending = true;
  bool isDuration = true;
  String timeText = "";
  final ScrollController scrollController = ScrollController();
  bool showEndListIndicator = false;
  TextEditingController searchController = TextEditingController();
  bool searchNotEmpty = false;

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
                      ? Icons.calendar_today
                      : Icons.access_time_filled))
            ],
          ),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Enter keyword..',
              // errorText: nameValidate ? 'Oops, you miss out here' : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.red, width: 3)),
              prefixIcon: Icon(Icons.search),
              suffixIcon: searchNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
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

                    return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewDetailsPage(data: sortedData[index]))),
                        child: Card(
                          elevation: 5,
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                    child: Text(
                                        sortedData[index].phone.toString()),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    child: isDuration
                                        ? Text(sortedData[index]
                                            .duration
                                            .toString())
                                        : Text(sortedData[index]
                                            .dateStr
                                            .toString()),
                                  )
                                ],
                              )),
                        ));
                  })),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddRecordPage()))
                .then((value) {
              fetchData();
            });
          },
          child: Icon(Icons.add),
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
