import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/AttendanceDataModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ViewDetailsPage extends StatefulWidget {
  final AttendanceDataModel data;

  const ViewDetailsPage({Key? key, required this.data}) : super(key: key);
  final String title = "Add New Record";

  @override
  State<ViewDetailsPage> createState() => _ViewDetailsPageState();
}

class _ViewDetailsPageState extends State<ViewDetailsPage> {
  late AttendanceDataModel data;

  @override
  Widget build(BuildContext context) {
    data = widget.data;

    return Scaffold(
        appBar: AppBar(
          // title: Text(data.name.toString()),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Text(data.name.toString()),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Text(data.phone.toString()),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Text(data.duration.toString()),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Text(data.dateStr.toString()),
              ),
              IconButton(onPressed: (){shareInfo();}, icon: Icon(Icons.share))
            ],
          ),
        ));
  }

  void shareInfo() async {
    String contactInfo = "Name: ${widget.data.name}\nPhone No.: ${widget.data.phone}";

    await Share.share(contactInfo, subject: "Contact Information");
  }
}
