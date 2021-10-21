class PaidFees {
  double AMT;
  double FEES_AMOUNT;
  String STUD_FULLNAME;
  int STUD_NO;
  DateTime TRDATE;

  PaidFees(
      {this.AMT,
      this.FEES_AMOUNT,
      this.STUD_FULLNAME,
      this.STUD_NO,
      this.TRDATE});

  PaidFees.fromMap(Map<String, dynamic> map) {
    AMT = map[PaidFeesConst.amtConst];
    STUD_FULLNAME = map[PaidFeesConst.studname_Const];
    FEES_AMOUNT = map[PaidFeesConst.fees_amountConst];
    STUD_NO = map[PaidFeesConst.stdnoConst] != null
        ? map[PaidFeesConst.stdnoConst]
        : 0;
    TRDATE = map[PaidFeesConst.trdateConst] != null
        ? DateTime.parse(map[PaidFeesConst.trdateConst])
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        PaidFeesConst.amtConst: AMT,
        PaidFeesConst.studname_Const: STUD_FULLNAME,
        PaidFeesConst.fees_amountConst: FEES_AMOUNT,
        PaidFeesConst.stdnoConst: STUD_NO,
        PaidFeesConst.trdateConst: TRDATE,
      };
}

class PaidFeesConst {
  static const String amtConst = "AMT";
  static const String studname_Const = "STUD_FULLNAME";
  static const String fees_amountConst = "FEES_AMOUNT";
  static const String stdnoConst = "STUD_NO";
  static const String trdateConst = "TRDATE";
}

class PaidFeesUrls {
  static const String GET_PAID_FEES =
      'Management/GetStudentwiseFeesPaidBetweenDate';
}
