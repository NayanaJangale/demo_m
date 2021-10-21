class EmployeeLeave {
  int emp_no;
  String emp_name, l_desc;
  double type_count, max_limit;
  bool isPrinted;

  EmployeeLeave({
    this.emp_no,
    this.emp_name,
    this.l_desc,
    this.type_count,
    this.max_limit,
  }) {
    isPrinted = false;
  }

  EmployeeLeave.fromJson(Map<String, dynamic> map) {
    emp_no = map[EmployeeLeaveFieldNames.emp_no];
    emp_name = map[EmployeeLeaveFieldNames.emp_name];
    l_desc = map[EmployeeLeaveFieldNames.l_desc];
    type_count = map[EmployeeLeaveFieldNames.type_count];
    max_limit = map[EmployeeLeaveFieldNames.max_limit];
    isPrinted = false;
  }

  EmployeeLeave.map(Map<String, dynamic> map) {
    emp_no = map[EmployeeLeaveFieldNames.emp_no];
    emp_name = map[EmployeeLeaveFieldNames.emp_name];
    l_desc = map[EmployeeLeaveFieldNames.l_desc];
    type_count = map[EmployeeLeaveFieldNames.type_count];
    max_limit = map[EmployeeLeaveFieldNames.max_limit];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        EmployeeLeaveFieldNames.emp_no: emp_no,
        EmployeeLeaveFieldNames.emp_name: emp_name,
        EmployeeLeaveFieldNames.l_desc: l_desc,
        EmployeeLeaveFieldNames.type_count: type_count,
        EmployeeLeaveFieldNames.max_limit: max_limit,
      };
}

class EmployeeLeaveFieldNames {
  static String emp_no = "emp_no";
  static String emp_name = "emp_name";
  static String l_desc = "l_desc";
  static String type_count = "type_count";
  static String max_limit = "max_limit";
}

class EmployeeLeaveUrls {
  static const String GET_EMPLOYEE_LEAVES = 'Management/GetEmployeeLeaves';
  static const String GET_LEAVES_APPLICATION =
      'EmployeeLeaves/GetLeaveApplications';
}
