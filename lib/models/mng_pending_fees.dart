class PendingFees {
  String brcode;
  int class_id;
  String class_name;
  double concession;
  int division_id;
  String division_name;
  double paid_bus_fees;
  double paid_fees;
  double pending_bus_fees;
  double pending_fees;
  DateTime report_date;
  double today_paid;
  double total_bus_fees;
  double total_fees;

  PendingFees(
      {this.brcode,
      this.class_id,
      this.class_name,
      this.concession,
      this.division_id,
      this.division_name,
      this.paid_bus_fees,
      this.paid_fees,
      this.pending_bus_fees,
      this.pending_fees,
      this.report_date,
      this.today_paid,
      this.total_bus_fees,
      this.total_fees});

  PendingFees.fromMap(Map<String, dynamic> map) {
    brcode = map[PendingFeesConst.brcodeConst];
    class_id = map[PendingFeesConst.class_idConst];
    class_name = map[PendingFeesConst.class_nameConst];
    concession = map[PendingFeesConst.concessionConst] != null
        ? map[PendingFeesConst.concessionConst]
        : 0.0;
    division_id = map[PendingFeesConst.division_idConst];
    division_name = map[PendingFeesConst.division_nameConst];
    paid_bus_fees = map[PendingFeesConst.paid_bus_feesConst] != null
        ? map[PendingFeesConst.paid_bus_feesConst]
        : 0.0;
    paid_fees = map[PendingFeesConst.paid_feesConst] != null
        ? map[PendingFeesConst.paid_feesConst]
        : 0.0;
    pending_bus_fees = map[PendingFeesConst.pending_bus_feesConst] != null
        ? map[PendingFeesConst.pending_bus_feesConst]
        : 0.0;
    pending_fees = map[PendingFeesConst.pending_feesConst] != null
        ? map[PendingFeesConst.pending_feesConst]
        : 0.0;
    report_date = map[PendingFeesConst.report_dateConst] != null
        ? DateTime.parse(map[PendingFeesConst.report_dateConst])
        : null;
    today_paid = map[PendingFeesConst.today_paidConst] != null
        ? map[PendingFeesConst.today_paidConst]
        : 0.0;
    total_bus_fees = map[PendingFeesConst.total_bus_feesConst] != null
        ? map[PendingFeesConst.total_bus_feesConst]
        : 0.0;
    total_fees = map[PendingFeesConst.total_feesConst] != null
        ? map[PendingFeesConst.total_feesConst]
        : 0.0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        PendingFeesConst.brcodeConst: brcode,
        PendingFeesConst.class_idConst: class_id,
        PendingFeesConst.class_nameConst: class_name,
        PendingFeesConst.concessionConst: concession,
        PendingFeesConst.division_idConst: division_id,
        PendingFeesConst.division_nameConst: division_name,
        PendingFeesConst.paid_bus_feesConst: paid_bus_fees,
        PendingFeesConst.paid_feesConst: paid_fees,
        PendingFeesConst.pending_bus_feesConst: pending_bus_fees,
        PendingFeesConst.pending_feesConst: pending_fees,
        PendingFeesConst.report_dateConst:
            report_date == null ? null : report_date.toIso8601String(),
        PendingFeesConst.today_paidConst: today_paid,
        PendingFeesConst.total_bus_feesConst: total_bus_fees,
        PendingFeesConst.total_feesConst: total_fees,
      };
}

class PendingFeesConst {
  static const String brcodeConst = "brcode";
  static const String class_idConst = "class_id";
  static const String class_nameConst = "class_name";
  static const String concessionConst = "concession";
  static const String division_idConst = "division_id";
  static const String division_nameConst = "division_name";
  static const String paid_bus_feesConst = "paid_bus_fees";
  static const String paid_feesConst = "paid_fees";
  static const String pending_bus_feesConst = "pending_bus_fees";
  static const String pending_feesConst = "pending_fees";
  static const String report_dateConst = "report_date";
  static const String today_paidConst = "today_paid";
  static const String total_bus_feesConst = "total_bus_fees";
  static const String total_feesConst = "total_fees";
}

class PendingFeesUrls {
  static const String GET_PENDING_FEES = 'Management/GetPendingFees';
  static const String GetTodaysFeesCollection = 'Management/GetTodaysFeesCollection';
}
