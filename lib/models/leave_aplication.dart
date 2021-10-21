class LeaveApplication {
  DateTime adate;
  DateTime edate;
  int ano;
  String l_desc;
  DateTime sdate;
  String status;

  LeaveApplication({
    this.adate,
    this.edate,
    this.ano,
    this.l_desc,
    this.sdate,
    this.status,
  });

  LeaveApplication.fromMap(Map<String, dynamic> map) {
    adate = map[LeaveApplicationConst.adateConst];
    edate = map[LeaveApplicationConst.edateConst];
    ano = map[LeaveApplicationConst.anoConst];
    l_desc = map[LeaveApplicationConst.l_descConst];
    sdate = map[LeaveApplicationConst.sdateConst];
    status = map[LeaveApplicationConst.statusConst];
  }
  factory LeaveApplication.fromJson(Map<String, dynamic> parsedJson) {
    return LeaveApplication(
        adate: DateTime.parse(parsedJson[LeaveApplicationConst.adateConst]) !=
                    null &&
                parsedJson[LeaveApplicationConst.adateConst]
                        .toString()
                        .trim() !=
                    ''
            ? DateTime.parse(parsedJson[LeaveApplicationConst.adateConst])
            : null,
        edate: DateTime.parse(parsedJson[LeaveApplicationConst.edateConst]) !=
                    null &&
                parsedJson[LeaveApplicationConst.edateConst]
                        .toString()
                        .trim() !=
                    ''
            ? DateTime.parse(parsedJson[LeaveApplicationConst.edateConst])
            : null,
        ano: parsedJson['ano'],
        l_desc: parsedJson['l_desc'],
        sdate: DateTime.parse(parsedJson[LeaveApplicationConst.sdateConst]) !=
                    null &&
                parsedJson[LeaveApplicationConst.sdateConst]
                        .toString()
                        .trim() !=
                    ''
            ? DateTime.parse(parsedJson[LeaveApplicationConst.sdateConst])
            : null,
        status: parsedJson['status']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        LeaveApplicationConst.adateConst: adate,
        LeaveApplicationConst.edateConst: edate,
        LeaveApplicationConst.anoConst: ano,
        LeaveApplicationConst.l_descConst: l_desc,
        LeaveApplicationConst.sdateConst: sdate,
        LeaveApplicationConst.statusConst: status,
      };
}

class LeaveApplicationConst {
  static const String adateConst = "adate";
  static const String edateConst = "edate";
  static const String anoConst = "ano";
  static const String l_descConst = "l_desc";
  static const String sdateConst = "sdate";
  static const String statusConst = "status";
}
