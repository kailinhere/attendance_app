import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/AttendanceDataModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
// import 'package:share_plus/share_plus.dart';
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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
                  onPressed: () {
                    shareInfo();
                  },
                  icon: Icon(Icons.share))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 40,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/paint.png', width: 180),
                  Positioned(
                      child: Text(
                    data.name!.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.eduTasBeginner(
                        fontSize: 50, fontWeight: FontWeight.bold),
                  ))
                ],
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 40, bottom: 18, left: 30, right: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(data.name.toString(),
                      style: GoogleFonts.eduTasBeginner(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 45,
                        letterSpacing: 2,
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20, bottom: 15),
                child: Align(
                    alignment: Alignment.center,
                    child: Text('Phone No.: ' + data.phone.toString(),
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 21,
                          letterSpacing: 1,
                        ))),
              ),
              
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Align(
                    alignment: Alignment.center,
                    child: Text('Date: ' + data.dateStr.toString(),
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 21,
                          letterSpacing: 1,
                        ))),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 15),
                child: Align(
                    alignment: Alignment.center,
                    child: Text('- ' + data.duration.toString() + ' -',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 21,
                          letterSpacing: 1,
                        ))),
              ),
              
            ],
          ),
        ));
  }

  void shareInfo() {
    String contactInfo =
        "Name: ${widget.data.name}\nPhone No.: ${widget.data.phone}";

    Share.share(contactInfo, subject: "Contact Information");
    // Share.share('check out my website https://example.com',
    //     subject: 'Look what I made!');
  }
}
