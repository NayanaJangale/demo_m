class Teacher {
  String SName;
  int emp_no;
  bool isSelected;

  Teacher({
    this.SName,
    this.emp_no,
    this.isSelected,
  });

  Teacher.fromMap(Map<String, dynamic> map) {
    SName = map[TeacherConst.SNameConst];
    emp_no = map[TeacherConst.emp_noConst];
    isSelected = false;
  }

  factory Teacher.fromJson(Map<String, dynamic> parsedJson) {
    return Teacher(
        SName: parsedJson['SName'] as String,
        emp_no: parsedJson['emp_no'],
        isSelected: false);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        TeacherConst.SNameConst: SName,
        TeacherConst.emp_noConst: emp_no,
        TeacherConst.isSelectedConst: isSelected = false,
      };
}

class TeacherUrls {
  static const String GET_TEACHER = 'Teacher/GetTeachers';
  static const String GET_MANAGEMENT_EMPLOYEE = 'Management/GetEmployeeByUsertype';
}

class TeacherConst {
  static const String SNameConst = "SName";
  static const String emp_noConst = "emp_no";
  static const String isSelectedConst = "isSelected";
}
