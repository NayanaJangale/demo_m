import 'package:teachers/handlers/string_handlers.dart';

class StaffAttendace {
  int at_no;
  int emp_no;
  String emp_name;
  String designation;
  int desig_no;
  String at_date;
  String at_status;
  String leave_type;

  StaffAttendace({
    this.at_no,
    this.emp_no,
    this.emp_name,
    this.designation,
    this.desig_no,
    this.at_date,
    this.at_status,
    this.leave_type,
  });

  factory StaffAttendace.fromJson(Map<String, dynamic> parsedJson) {
    return StaffAttendace(
      at_no: parsedJson['at_no'] ?? 0,
      emp_no: parsedJson['emp_no'] ?? 0,
      emp_name: parsedJson['emp_name'] ?? '',
      designation: parsedJson['designation'] ?? '',
      desig_no: parsedJson['desig_no'] ?? '',
      at_date: parsedJson['at_date'] ?? '',
      at_status: parsedJson['at_status'] ?? '',
      leave_type: parsedJson['leave_type'] ?? StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        StaffAttendaceConst.at_noConst: at_no,
        StaffAttendaceConst.emp_noConst: emp_no,
        StaffAttendaceConst.emp_nameConst: emp_name,
        StaffAttendaceConst.designationConst: designation,
        StaffAttendaceConst.desig_noConst: desig_no,
        StaffAttendaceConst.at_dateConst: at_date,
        StaffAttendaceConst.at_statusConst: at_status,
        StaffAttendaceConst.leave_typeConst: leave_type,
      };
}

class StaffAttendaceUrls {
  static const String GET_EMPLOYEE_ATTENDACE =
      "Management/GetEmployeeAttendance";
}

class StaffAttendaceConst {
  static const String at_noConst = "at_no";
  static const String emp_noConst = "emp_no";
  static const String emp_nameConst = "emp_name";
  static const String designationConst = "designation";
  static const String desig_noConst = "desig_no";
  static const String at_dateConst = "at_date";
  static const String at_statusConst = "at_status";
  static const String leave_typeConst = "leave_type";
}
