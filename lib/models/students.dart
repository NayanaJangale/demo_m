import 'package:teachers/handlers/string_handlers.dart';

class Students {
  int stud_no;
  String student_name;

  Students({
    this.stud_no,
    this.student_name,
  });

  Students.fromMap(Map<String, dynamic> map) {
    stud_no = map[StudentFieldNames.stud_no] ?? 0;
    student_name =
        map[StudentFieldNames.stud_fullname] ?? StringHandlers.NotAvailable;
  }
  factory Students.fromJson(Map<String, dynamic> parsedJson) {
    return Students(
      stud_no: parsedJson[StudentFieldNames.stud_no],
      student_name: parsedJson[StudentFieldNames.stud_fullname] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        StudentFieldNames.stud_no: stud_no,
        StudentFieldNames.stud_fullname: student_name
      };
}

class StudentFieldNames {
  static String stud_no = "stud_no";
  static String stud_fullname = "student_name";
}

class StudentUrls {
  static const String GET_DIVISION_STUDENTS = 'Students/GetDivisionStudents';
  static const String GET_CLASS_STUDENTS =
      'Management/GetFeedbackSubmittedStudents';
}
