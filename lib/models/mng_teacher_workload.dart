import 'package:teachers/handlers/string_handlers.dart';

class TeacherWorkLoad {
  int emp_no, period_no, section_no;

  String activity, day, emp_name, period_desc, section_name;

  DateTime report_date;

  TeacherWorkLoad({
    this.emp_no,
    this.activity,
    this.day,
    this.emp_name,
    this.period_desc,
    this.period_no,
    this.report_date,
    this.section_name,
    this.section_no,
  });

  TeacherWorkLoad.fromJson(Map<String, dynamic> map) {
    emp_no = map[TeacherWorkLoadFieldNames.emp_no] ?? 0;
    activity = map[TeacherWorkLoadFieldNames.activity] ?? '';
    day = map[TeacherWorkLoadFieldNames.day] ?? '';
    emp_name =
        map[TeacherWorkLoadFieldNames.emp_name] ?? StringHandlers.NotAvailable;
    period_desc = map[TeacherWorkLoadFieldNames.period_desc] ??
        StringHandlers.NotAvailable;
    period_no = map[TeacherWorkLoadFieldNames.period_no] ?? 0;
    report_date = map[TeacherWorkLoadFieldNames.report_date] == null
        ? null
        : DateTime.parse(map[TeacherWorkLoadFieldNames.report_date]);
    section_name = map[TeacherWorkLoadFieldNames.section_name] ??
        StringHandlers.NotAvailable;
    section_no = map[TeacherWorkLoadFieldNames.section_no] ?? 0;
  }

  TeacherWorkLoad.map(Map<String, dynamic> map) {
    emp_no = map[TeacherWorkLoadFieldNames.emp_no] ?? 0;
    activity = map[TeacherWorkLoadFieldNames.activity] ?? '';
    day = map[TeacherWorkLoadFieldNames.day] ?? '';
    emp_name =
        map[TeacherWorkLoadFieldNames.emp_name] ?? StringHandlers.NotAvailable;
    period_desc = map[TeacherWorkLoadFieldNames.period_desc] ??
        StringHandlers.NotAvailable;
    period_no = map[TeacherWorkLoadFieldNames.period_no] ?? 0;
    report_date = map[TeacherWorkLoadFieldNames.report_date] == null
        ? null
        : DateTime.parse(map[TeacherWorkLoadFieldNames.report_date]);
    section_name = map[TeacherWorkLoadFieldNames.section_name] ??
        StringHandlers.NotAvailable;
    section_no = map[TeacherWorkLoadFieldNames.section_no] ?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        TeacherWorkLoadFieldNames.emp_no: emp_no,
        TeacherWorkLoadFieldNames.activity: activity,
        TeacherWorkLoadFieldNames.day: day,
        TeacherWorkLoadFieldNames.emp_name: emp_name,
        TeacherWorkLoadFieldNames.period_desc: period_desc,
        TeacherWorkLoadFieldNames.period_no: period_no,
        TeacherWorkLoadFieldNames.report_date:
            report_date == null ? null : report_date.toIso8601String(),
        TeacherWorkLoadFieldNames.section_name: section_name,
        TeacherWorkLoadFieldNames.section_no: section_no,
      };
}

class TeacherWorkLoadFieldNames {
  static String emp_no = "emp_no";
  static String activity = "activity";
  static String day = "day";
  static String emp_name = "emp_name";
  static String period_desc = "period_desc";
  static String period_no = "period_no";
  static String report_date = "report_date";
  static String section_name = "section_name";
  static String section_no = "section_no";
}

class TeacherWorkLoadUrls {
  static const String GET_DaywiseTeacherLoad = 'Management/GetDaywiseTeacherLoad';
}
