import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/models/period.dart';

class Homework {
  int hw_no;
  String hw_desc;
  String teacher_name;
  String hw_image;
  DateTime submission_dt;
  int emp_no;
  DateTime hw_date;
  String brcode;
  int yr_no;
  String divisions;
  bool docstatus;
  List<Period> periods;

  Homework({
    this.hw_no,
    this.hw_desc,
    this.teacher_name,
    this.hw_image,
    this.submission_dt,
    this.emp_no,
    this.hw_date,
    this.brcode,
    this.yr_no,
    this.divisions,
    this.periods,
    this.docstatus,
  });

  factory Homework.fromJson(Map<String, dynamic> parsedJson) {
    return Homework(
      hw_no: parsedJson['hw_no'] ?? 0,
      hw_desc: parsedJson['hw_desc'] ?? StringHandlers.NotAvailable,
      teacher_name: parsedJson['teacher_name'] ?? StringHandlers.NotAvailable,
      hw_image: parsedJson['hw_image'] ?? '',
      submission_dt:
          parsedJson[HomeworkFieldNames.Homework_submissionConst] != null
              ? DateTime.parse(
                  parsedJson[HomeworkFieldNames.Homework_submissionConst])
              : null,
      hw_date: parsedJson[HomeworkFieldNames.Hw_dateConst] != null
          ? DateTime.parse(parsedJson[HomeworkFieldNames.Hw_dateConst])
          : null,
      emp_no: parsedJson['emp_no'] ?? 0,
      brcode: parsedJson['brcode'] ?? StringHandlers.NotAvailable,
      yr_no: parsedJson['yr_no'] ?? 0,
      periods: (parsedJson[HomeworkFieldNames.periods] as List)
          .map((item) => Period.fromMap(item))
          .toList(),
      docstatus: parsedJson['docstatus'] ?? 0,
    );
  }

  /*Homework.fromMap(Map<String, dynamic> map) {
    hw_no = map[HomeworkFieldNames.Homework_noConst];
    hw_desc = map[HomeworkFieldNames.Homework_descConst];
    hw_image = map[HomeworkFieldNames.Homework_imageConst];
    submission_dt = DateTime.parse(map[HomeworkFieldNames.Homework_submissionConst]);
    class_id = map[HomeworkFieldNames.Class_idConst];
    division_id = map[HomeworkFieldNames.Division_idConst];
    subject_id = map[HomeworkFieldNames.Subject_idConst];
    emp_no = map[HomeworkFieldNames.Emp_noConst];
    hw_date = DateTime.parse(map[HomeworkFieldNames.Hw_dateConst]);
    brcode = map[HomeworkFieldNames.Brcodes_Const];
    yr_no = map[HomeworkFieldNames.Yrno_Const];
    class_name = map[HomeworkFieldNames.Class_nameConst];
    division_name = map[HomeworkFieldNames.Division_nameConst];
    subject_name = map[HomeworkFieldNames.Subject_nameConst];
  }*/

  Map<String, dynamic> toJson() => <String, dynamic>{
        HomeworkFieldNames.Homework_noConst: hw_no,
        HomeworkFieldNames.Homework_descConst: hw_desc,
        HomeworkFieldNames.Homework_teacherConst: teacher_name,
        HomeworkFieldNames.Homework_imageConst: hw_image,
        HomeworkFieldNames.Subject_idConst:
            submission_dt == null ? null : submission_dt.toIso8601String(),
        HomeworkFieldNames.Hw_dateConst:
            hw_date == null ? null : hw_date.toIso8601String(),
        HomeworkFieldNames.Emp_noConst: emp_no,
        HomeworkFieldNames.Brcodes_Const: brcode,
        HomeworkFieldNames.Yrno_Const: yr_no,
        HomeworkFieldNames.period_Const: divisions,
        HomeworkFieldNames.periods: periods,
        HomeworkFieldNames.docstatus: docstatus,
      };
}

class HomeworkFieldNames {
  static const String Homework_noConst = "hw_no";
  static const String Homework_descConst = "hw_desc";
  static const String Homework_teacherConst = "teacher_name";
  static const String Homework_imageConst = "hw_image";
  static const String Homework_stringConst = "hw_String";
  static const String Homework_submissionConst = "submission_dt";
  static const String Class_idConst = "class_id";
  static const String Division_idConst = "division_id";
  static const String Subject_idConst = "subject_id";
  static const String Emp_noConst = "emp_no";
  static const String Hw_dateConst = "hw_date";
  static const String Brcodes_Const = "brcode";
  static const String Yrno_Const = "yr_no";
  static const String Class_nameConst = "class_name";
  static const String Division_nameConst = "division_name";
  static const String Subject_nameConst = "subject_name";
  static const String period_Const = "divisions";
  static const String periods = "periods";
  static const String docstatus = "docstatus";
}

class HomeworkUrls {
  static const String GET_PENDING_HOMEWORK = "Homework/GetUnapprovedHomework";
  static const String GetHomeworkDocuments = 'Homework/GetHomeworkDocuments';
  static const String GetHomeworkDocument = 'Homework/GetHomeworkDocument';
  static const String UPDATE_HOMEWORK_STATUS = "Homework/UpdatePendingHomeworkStatus";
}
