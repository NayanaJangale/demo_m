class StudentFees {
  String stud_fullname;
  int class_id;
  int division_id;
  double totsch_fees;
  double paidsch_fees;
  double pendingSch_fees;
  double totbus_fees;
  double paidbus_fees;
  double pendingbus_fees;

  StudentFees({
    this.stud_fullname,
    this.class_id,
    this.division_id,
    this.totsch_fees,
    this.paidsch_fees,
    this.pendingSch_fees,
    this.totbus_fees,
    this.paidbus_fees,
    this.pendingbus_fees,
  });

  StudentFees.fromMap(Map<String, dynamic> map) {
    stud_fullname = map[StudentFeesFieldNames.stud_fullname] ?? '';
    class_id = map[StudentFeesFieldNames.class_id] ?? 0;
    division_id = map[StudentFeesFieldNames.division_id] ?? 0;
    totsch_fees = map[StudentFeesFieldNames.totsch_fees] != null
        ? map[StudentFeesFieldNames.totsch_fees]
        : 0.0;
    paidsch_fees = map[StudentFeesFieldNames.paidsch_fees] != null
        ? map[StudentFeesFieldNames.paidsch_fees]
        : 0.0;
    pendingSch_fees = map[StudentFeesFieldNames.pendingSch_fees] != null
        ? map[StudentFeesFieldNames.pendingSch_fees]
        : 0.0;
    totbus_fees = map[StudentFeesFieldNames.totbus_fees] != null
        ? map[StudentFeesFieldNames.totbus_fees]
        : 0.0;
    paidbus_fees = map[StudentFeesFieldNames.paidbus_fees] != null
        ? map[StudentFeesFieldNames.paidbus_fees]
        : 0.0;
    pendingbus_fees = map[StudentFeesFieldNames.pendingbus_fees] != null
        ? map[StudentFeesFieldNames.pendingbus_fees]
        : 0.0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        StudentFeesFieldNames.stud_fullname: stud_fullname,
        StudentFeesFieldNames.class_id: class_id,
        StudentFeesFieldNames.division_id: division_id,
        StudentFeesFieldNames.totsch_fees: totsch_fees,
        StudentFeesFieldNames.paidsch_fees: paidsch_fees,
        StudentFeesFieldNames.pendingSch_fees: pendingSch_fees,
        StudentFeesFieldNames.totbus_fees: totbus_fees,
        StudentFeesFieldNames.paidbus_fees: paidbus_fees,
        StudentFeesFieldNames.pendingbus_fees: pendingbus_fees,
      };
}

class StudentFeesFieldNames {
  static const String stud_fullname = "stud_fullname";
  static const String class_id = "class_id";
  static const String division_id = "division_id";
  static const String totsch_fees = "totsch_fees";
  static const String paidsch_fees = "paidsch_fees";
  static const String pendingSch_fees = "balance";
  static const String totbus_fees = "totbus_fees";
  static const String paidbus_fees = "paidbus_fees";
  static const String pendingbus_fees = "pendingbus_fees";
}

class StudentFeesUrls {
  static const String GET_STUDENT_FEES_REPORT = 'Fees/GetStudentFeesReport';
}
