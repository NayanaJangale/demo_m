import 'package:teachers/handlers/string_handlers.dart';

class TeacherTimeTable {
  int emp_no;
  String emp_name;
  int section_no;
  String period_desc;
  String report_date;
  String Monday;
  String Tuesday;
  String Wednesday;
  String Thursday;
  String Friday;
  String Saturday;
  String Sunday;

  TeacherTimeTable({
    this.emp_no,
    this.emp_name,
    this.section_no,
    this.period_desc,
    this.report_date,
    this.Monday,
    this.Tuesday,
    this.Wednesday,
    this.Thursday,
    this.Friday,
    this.Saturday,
    this.Sunday,
  });

  TeacherTimeTable.fromJson(Map<String, dynamic> map) {
    emp_no = map[TeacherTimeTableFieldNames.emp_no] ?? 0;
    emp_name = map[TeacherTimeTableFieldNames.emp_name] ?? '';
    section_no = map[TeacherTimeTableFieldNames.section_no] ?? 0;
    period_desc = map[TeacherTimeTableFieldNames.period_desc] ?? 'Free Period';
    report_date = map[TeacherTimeTableFieldNames.report_date] ??
        StringHandlers.NotAvailable;
    Monday = map[TeacherTimeTableFieldNames.Monday] ?? 'Free Period';
    Tuesday = map[TeacherTimeTableFieldNames.Tuesday] ?? 'Free Period';
    Wednesday = map[TeacherTimeTableFieldNames.Wednesday] ?? 'Free Period';
    Thursday = map[TeacherTimeTableFieldNames.Thursday] ?? 'Free Period';
    Friday = map[TeacherTimeTableFieldNames.Friday] ?? 'Free Period';
    Saturday = map[TeacherTimeTableFieldNames.Saturday] ?? 'Free Period';
    Sunday = map[TeacherTimeTableFieldNames.Sunday] ?? 'Free Period';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        TeacherTimeTableFieldNames.emp_no: emp_no,
        TeacherTimeTableFieldNames.emp_name: emp_name,
        TeacherTimeTableFieldNames.section_no: section_no,
        TeacherTimeTableFieldNames.period_desc: period_desc,
        TeacherTimeTableFieldNames.report_date: report_date,
        TeacherTimeTableFieldNames.Monday: Monday,
        TeacherTimeTableFieldNames.Tuesday: Tuesday,
        TeacherTimeTableFieldNames.Wednesday: Wednesday,
        TeacherTimeTableFieldNames.Thursday: Thursday,
        TeacherTimeTableFieldNames.Friday: Friday,
        TeacherTimeTableFieldNames.Saturday: Saturday,
        TeacherTimeTableFieldNames.Sunday: Sunday,
      };
}

class TeacherTimeTableFieldNames {
  static String emp_no = "emp_no";
  static String emp_name = "emp_name";
  static String section_no = "section_no";
  static String period_desc = "period_desc";
  static String report_date = "report_date";
  static String Monday = "Monday";
  static String Tuesday = "Tuesday";
  static String Wednesday = "Wednesday";
  static String Thursday = "Thursday";
  static String Friday = "Friday";
  static String Saturday = "Saturday";
  static String Sunday = "Sunday";
}

class TeacherTimeTableUrls {
  static const String GET_TEACHER_TIMETABLE = 'TimeTable/GetTeacherTimeTable';
}
