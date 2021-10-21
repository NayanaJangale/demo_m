import 'package:teachers/handlers/string_handlers.dart';

class Student {
  int stud_no;
  int Roll_no;
  String stud_fullname;
  bool isSelected;

  Student({
    this.stud_no,
    this.Roll_no,
    this.stud_fullname,
    this.isSelected,
  });

  Student.fromMap(Map<String, dynamic> map) {
    stud_no = map[StudentFieldNames.stud_no] ?? 0;
    Roll_no = map[StudentFieldNames.Roll_no] ?? 0;
    stud_fullname =
        map[StudentFieldNames.stud_fullname] ?? StringHandlers.NotAvailable;
    isSelected = false;
  }
  factory Student.fromJson(Map<String, dynamic> parsedJson) {
    return Student(
        stud_no: parsedJson[StudentFieldNames.stud_no],
        Roll_no: parsedJson[StudentFieldNames.Roll_no],
        stud_fullname: parsedJson[StudentFieldNames.stud_fullname] as String,
        isSelected: false);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        StudentFieldNames.stud_no: stud_no,
        StudentFieldNames.Roll_no: Roll_no,
        StudentFieldNames.stud_fullname: stud_fullname,
        StudentFieldNames.isSelected: isSelected = false,
      };
}

class StudentFieldNames {
  static String stud_no = "stud_no";
  static String Roll_no = "Roll_no";
  static String stud_fullname = "stud_fullname";
  static String isSelected = "isSelected";
}

class StudentUrls {
  static const String GET_DIVISION_STUDENTS = 'Students/GetDivisionStudents';
}
