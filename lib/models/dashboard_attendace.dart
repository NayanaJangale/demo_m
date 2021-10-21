class DashboardAttendace {
  int class_id;
  String class_name;
  int division_id;
  String division_name;
  int tot_stud;
  int presents;
  int absent;
  int at_type;
  String att_desc;
  int frequent;

  DashboardAttendace({
    this.class_id,
    this.class_name,
    this.division_id,
    this.division_name,
    this.tot_stud,
    this.presents,
    this.absent,
    this.at_type,
    this.att_desc,
    this.frequent,
  });

  /*DashboardAttendace.fromMap(Map<String, dynamic> map) {
    class_id = map[dashboard_attendaceConst.class_idConst];
    class_name = map[dashboard_attendaceConst.class_nameConst];
    division_id = map[dashboard_attendaceConst.division_idConst];
    division_name = map[dashboard_attendaceConst.division_nameConst] == null
        ? ""
        : map[dashboard_attendaceConst.division_nameConst];
    tot_stud = map[dashboard_attendaceConst.tot_studConst];
    presents = map[dashboard_attendaceConst.presentsConst];
    absent = map[dashboard_attendaceConst.absentConst];
    at_type = map[dashboard_attendaceConst.at_typeConst];
    att_desc = map[dashboard_attendaceConst.att_descConst];
    frequent = map[dashboard_attendaceConst.frequentConst];
  }*/

  factory DashboardAttendace.fromJson(Map<String, dynamic> parsedJson) {
    return DashboardAttendace(
      class_id: parsedJson['class_id'] ?? 0,
      class_name: parsedJson['class_name'] ?? '',
      division_id: parsedJson['division_id'] ?? 0,
      division_name: parsedJson['division_name'] ?? '',
      tot_stud: parsedJson['tot_stud'] ?? 0,
      presents: parsedJson['presents'] ?? 0,
      absent: parsedJson['absent'] ?? 0,
      at_type: parsedJson['at_type'] ?? 0,
      att_desc: parsedJson['att_desc'] ?? '',
      frequent: parsedJson['frequent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        dashboard_attendaceConst.class_idConst: class_id,
        dashboard_attendaceConst.class_nameConst: class_name,
        dashboard_attendaceConst.division_idConst: division_id,
        dashboard_attendaceConst.division_nameConst: division_name,
        dashboard_attendaceConst.tot_studConst: tot_stud,
        dashboard_attendaceConst.presentsConst: presents,
        dashboard_attendaceConst.absentConst: absent,
        dashboard_attendaceConst.at_typeConst: at_type,
        dashboard_attendaceConst.att_descConst: att_desc,
        dashboard_attendaceConst.frequentConst: frequent,
      };
}

class DashboardAttendaceUrls {
  static const String GET_DASHBOARD_ATTENDACE =
      "Management/GetDashboardAttendance";
}

class dashboard_attendaceConst {
  static const String class_idConst = "class_id";
  static const String class_nameConst = "class_name";
  static const String division_idConst = "division_id";
  static const String division_nameConst = "division_name";
  static const String tot_studConst = "tot_stud";
  static const String presentsConst = "presents";
  static const String absentConst = "absent";
  static const String at_typeConst = "at_type";
  static const String att_descConst = "att_desc";
  static const String frequentConst = "frequent";
}
