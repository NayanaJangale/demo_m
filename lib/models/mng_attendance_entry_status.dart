import 'package:teachers/handlers/string_handlers.dart';

class AttendanceEntryStatus {
  String at_status;
  int class_id;
  String class_name;
  int division_id;
  String division_name;
  String emp_name;
  int emp_no;
  DateTime ent_date_time;

  AttendanceEntryStatus({
    this.at_status,
    this.class_id,
    this.class_name,
    this.division_id,
    this.division_name,
    this.emp_name,
    this.emp_no,
    this.ent_date_time,
  });

  AttendanceEntryStatus.fromMap(Map<String, dynamic> map) {
    at_status = map[AttendanceEntryStatusConst.at_statusConst] ??
        StringHandlers.NotAvailable;
    ;
    class_id = map[AttendanceEntryStatusConst.class_idConst] ?? 0;
    class_name = map[AttendanceEntryStatusConst.class_nameConst] ??
        StringHandlers.NotAvailable;
    ;
    division_id = map[AttendanceEntryStatusConst.division_idConst] ?? 0;
    division_name = map[AttendanceEntryStatusConst.division_nameConst] ??
        StringHandlers.NotAvailable;
    ;
    emp_name = map[AttendanceEntryStatusConst.emp_nameConst] ?? '';
    emp_no = map[AttendanceEntryStatusConst.emp_noConst] ?? 0;
    ent_date_time = map[AttendanceEntryStatusConst.ent_date_timeConst] != null
        ? DateTime.parse(map[AttendanceEntryStatusConst.ent_date_timeConst])
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        AttendanceEntryStatusConst.at_statusConst: at_status,
        AttendanceEntryStatusConst.class_idConst: class_id,
        AttendanceEntryStatusConst.class_nameConst: class_name,
        AttendanceEntryStatusConst.division_idConst: division_id,
        AttendanceEntryStatusConst.division_nameConst: division_name,
        AttendanceEntryStatusConst.emp_nameConst: emp_name,
        AttendanceEntryStatusConst.emp_noConst: emp_no,
        AttendanceEntryStatusConst.ent_date_timeConst:
            ent_date_time == null ? null : ent_date_time.toIso8601String(),
      };
}

class AttendanceEntryStatusConst {
  static const String at_statusConst = "at_status";

  static const String class_idConst = "class_id";
  static const String class_nameConst = "class_name";
  static const String division_idConst = "division_id";
  static const String division_nameConst = "division_name";
  static const String emp_nameConst = "emp_name";
  static const String emp_noConst = "emp_no";
  static const String ent_date_timeConst = "ent_date_time";
}

class AttendanceEntryStatusUrls {
  static const String GET_ATTENDANCE_ENTRY_STATUS =
      'Management/GetAttendanceEntryStatus';
}
