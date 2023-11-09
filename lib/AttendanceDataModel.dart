import 'package:intl/intl.dart';

class AttendanceDataModel {
  String? name;
  String? phone;
  DateTime? date;
  String? dateStr;
  String? duration;

  AttendanceDataModel({required this.name, required this.phone, required this.dateStr});

  AttendanceDataModel.fromJson(Map<String, dynamic> json)
  {
    name = json['user'];
    phone = json['phone'];
    String oriDate = json['check-in'];
    date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(oriDate);
    dateStr = DateFormat("dd MMM yyyy, h:mm a").format(date!);
    duration = getTimeDifference();    
  }

  String getTimeDifference() {
    if (date != null) {
      // Get the current time
      DateTime now = DateTime.now();

      // Calculate the difference between the date in the model and the current time
      Duration difference = now.difference(date!);

      if (difference.inSeconds < 60) {
        return "Just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minute(s) ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hour(s) ago";
      } else {
        return "${difference.inDays} days ago"; // For older dates, just display the date
      }
    } else {
      return "Date not available";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user': name,
      'phone': phone,
      'check-in': dateStr,
    };
  }
}