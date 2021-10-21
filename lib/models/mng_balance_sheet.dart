class BalanceSheet {
  int RNO_1;
  String BSNAME_1;
  double LBAL_2;
  int RNO_2;
  String BSNAME_2;
  double ABAL_2;

  BalanceSheet({
    this.RNO_1,
    this.BSNAME_1,
    this.LBAL_2,
    this.RNO_2,
    this.BSNAME_2,
    this.ABAL_2,
  });

  factory BalanceSheet.fromJson(Map<String, dynamic> map) {
    return BalanceSheet(
      RNO_1: map[BalanceSheetConst.RNO_1Const] ?? 0,
      BSNAME_1: map[BalanceSheetConst.BSNAME_1Const] ?? '',
      LBAL_2: map[BalanceSheetConst.LBAL_2Const] ?? '',
      RNO_2: map[BalanceSheetConst.RNO_2Const] ?? 0,
      BSNAME_2: map[BalanceSheetConst.BSNAME_2Const] ?? '',
      ABAL_2: map[BalanceSheetConst.ABAL_2Const] ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        BalanceSheetConst.RNO_1Const: RNO_1,
        BalanceSheetConst.BSNAME_1Const: BSNAME_1,
        BalanceSheetConst.LBAL_2Const: LBAL_2,
        BalanceSheetConst.RNO_2Const: RNO_2,
        BalanceSheetConst.BSNAME_2Const: BSNAME_2,
        BalanceSheetConst.ABAL_2Const: ABAL_2,
      };
}

class BalanceSheetUrls {
  static const String GET_BALANCE_SHEET = "Management/GetBalanceSheet";
}

class BalanceSheetConst {
  static const String RNO_1Const = "RNO_1";
  static const String BSNAME_1Const = "BSNAME_1";
  static const String LBAL_2Const = "LBAL_2";
  static const String RNO_2Const = "RNO_2";
  static const String BSNAME_2Const = "BSNAME_2";
  static const String ABAL_2Const = "ABAL_2";
}
