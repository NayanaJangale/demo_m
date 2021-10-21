import 'package:teachers/handlers/string_handlers.dart';

class StudentAttendance {
  int ent_no;
  int stud_no;
  int roll_no;
  String student_name;
  int class_id;
  int division_id;
  int subject_id;
  DateTime at_date;
  String at_status;



  StudentAttendance({
    this.ent_no,
    this.stud_no,
    this.roll_no,
    this.student_name,
    this.class_id,
    this.division_id,
    this.at_date,
    this.at_status,
    this.subject_id,
  });

  StudentAttendance.fromMap(Map<String, dynamic> map) {
    ent_no = map[StudentAttendanceFieldNames.ent_no] ?? 0;
    stud_no = map[StudentAttendanceFieldNames.stud_no] ?? 0;
    roll_no = map[StudentAttendanceFieldNames.roll_no] ?? 0;
    student_name = map[StudentAttendanceFieldNames.student_name] ??
        StringHandlers.NotAvailable;
    class_id = map[StudentAttendanceFieldNames.class_id] ?? 0;
    division_id = map[StudentAttendanceFieldNames.division_id] ?? 0;
    at_date = map[StudentAttendanceFieldNames.at_date] != null
        ? DateTime.parse(map[StudentAttendanceFieldNames.at_date])
        : null;
    at_status = map[StudentAttendanceFieldNames.at_status] ??
        StringHandlers.NotAvailable;
    subject_id = map[StudentAttendanceFieldNames.subject_id] ?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        StudentAttendanceFieldNames.ent_no: ent_no,
        StudentAttendanceFieldNames.stud_no: stud_no,
        StudentAttendanceFieldNames.roll_no: roll_no,
        StudentAttendanceFieldNames.student_name: student_name,
        StudentAttendanceFieldNames.class_id: class_id,
        StudentAttendanceFieldNames.division_id: division_id,
        StudentAttendanceFieldNames.at_date:
            at_date == null ? null : at_date.toIso8601String(),
        StudentAttendanceFieldNames.at_status: at_status,
        StudentAttendanceFieldNames.subject_id: subject_id,
      };
}

class StudentAttendanceFieldNames {
  static const String ent_no = "ent_no";
  static const String stud_no = "stud_no";
  static const String roll_no = "roll_no";
  static const String student_name = "student_name";
  static const String class_id = "class_id";
  static const String division_id = "division_id";
  static const String at_date = "at_date";
  static const String at_status = "at_status";
  static const String subject_id = "subject_id";
  static const String yr_no = "yr_no";
}

class StudentAttendanceUrls {
  static const String GET_DIVISION_ATTENDANCE =
      "Attendance/GetDivisionAttendance";

  static const String PUT_STUDENT_ATTENDANCE =
      "Attendance/PutStudentAttendance";
}
