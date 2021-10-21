class LeavesType {
  String l_desc;
  int l_tpcode;

  LeavesType({
    this.l_desc,
    this.l_tpcode,
  });

  LeavesType.fromMap(Map<String, dynamic> map) {
    l_desc = map[LeavesTypeConst.l_descConst];
    l_tpcode = map[LeavesTypeConst.l_tpcodeConst];
  }
  factory LeavesType.fromJson(Map<String, dynamic> parsedJson) {
    return LeavesType(
      l_desc: parsedJson['l_desc'],
      l_tpcode: parsedJson['l_tpcode'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        LeavesTypeConst.l_descConst: l_desc,
        LeavesTypeConst.l_tpcodeConst: l_tpcode,
      };
}

class LeavesTypeConst {
  static const String l_descConst = "l_desc";
  static const String l_tpcodeConst = "l_tpcode";
}

class LeaveTypeUrls {
  static const String GET_LEAVES_TYPE = "EmployeeLeaves/GetLeaveTypes";
  static const String POST_EMPLOYEE_LEAVES =
      "EmployeeLeaves/PostLeaveApplication";
}
