class FrequentAbsentStudent {
  String class_name;
  String division_name;
  int month;
  int no_of_days;
  int stud_no;
  String student_name;

  FrequentAbsentStudent({
    this.class_name,
    this.division_name,
    this.month,
    this.no_of_days,
    this.stud_no,
    this.student_name,
  });
  factory FrequentAbsentStudent.fromJson(Map<String, dynamic> parsedJson) {
    return FrequentAbsentStudent(
      class_name: parsedJson['class_name'] ?? '',
      division_name: parsedJson['division_name'] ?? '',
      month: parsedJson['month'] ?? 0,
      no_of_days: parsedJson['no_of_days'] ?? 0,
      stud_no: parsedJson['stud_no'] ?? 0,
      student_name: parsedJson['student_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        FrequentAbsentStudentConst.class_nameConst: class_name,
        FrequentAbsentStudentConst.division_nameConst: division_name,
        FrequentAbsentStudentConst.monthConst: month,
        FrequentAbsentStudentConst.no_of_daysConst: no_of_days,
        FrequentAbsentStudentConst.stud_noConst: stud_no,
        FrequentAbsentStudentConst.student_nameConst: student_name,
      };
}

class FrequentAbsentStudentConst {
  static const String brcodeConst = "brcode";
  static const String class_nameConst = "class_name";
  static const String division_nameConst = "division_name";
  static const String monthConst = "month";
  static const String no_of_daysConst = "no_of_days";
  static const String stud_noConst = "stud_no";
  static const String student_nameConst = "student_name";
}

class FrequentAbsentStudentUrls {
  static const String GET_FREQUENT_ABSENT_STUDENT =
      "Management/GetMonthlyAbsentStudents";
}
