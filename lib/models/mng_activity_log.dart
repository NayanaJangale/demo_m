import 'package:teachers/handlers/string_handlers.dart';

class ActivityLog {
  int row_no;
  String activity;
  int usage;
  String log_date;

  ActivityLog({
    this.row_no,
    this.activity,
    this.usage,
    this.log_date,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> parsedJson) {
    return ActivityLog(
      row_no: parsedJson['row_no'] ?? 0,
      activity: parsedJson['activity'] ?? StringHandlers.NotAvailable,
      usage: parsedJson['usage'] ?? 0,
      log_date: parsedJson['log_date'] ?? StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ActivityLogConst.row_noConst: row_no,
        ActivityLogConst.activityConst: activity,
        ActivityLogConst.usageConst: usage,
        ActivityLogConst.log_dateConst: log_date,
      };
}

class ActivityLogUrls {
  static const String GET_ACTIVITY_LOG = "Management/GetBranchwiseActivityLog";
}

class ActivityLogConst {
  static const String row_noConst = "row_no";
  static const String activityConst = "activity";
  static const String usageConst = "usage";
  static const String log_dateConst = "log_date";
}
