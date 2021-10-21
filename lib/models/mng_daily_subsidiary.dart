class DailySubsidiary {
  String CreditHeader;
  double CashCredit;
  double TransferCredit;
  double TotalCredit;
  int CreditScrollNo;
  int DebitScrollNo;
  String DebitHeader;
  double CashDebit;
  double TransferDebit;
  double TotalDebit;

  DailySubsidiary({
    this.CreditHeader,
    this.CashCredit,
    this.TransferCredit,
    this.TotalCredit,
    this.CreditScrollNo,
    this.DebitScrollNo,
    this.DebitHeader,
    this.CashDebit,
    this.TransferDebit,
    this.TotalDebit,
  });

  factory DailySubsidiary.fromJson(Map<String, dynamic> parsedJson) {
    return DailySubsidiary(
      CreditHeader: parsedJson['CHDNM'] ?? '',
      CashCredit: parsedJson['CRAMT_C'] ?? 0,
      TransferCredit: parsedJson['CRAMT_T'] ?? 0,
      TotalCredit: parsedJson['TOTCR'] ?? 0,
      CreditScrollNo: parsedJson['SCROLLNO_C'] ?? 0,
      DebitScrollNo: parsedJson['SCROLLNO_D'] ?? 0,
      DebitHeader: parsedJson['DHDNM'] ?? '',
      CashDebit: parsedJson['DRAMT_C'] ?? 0,
      TransferDebit: parsedJson['DRAMT_T'] ?? 0,
      TotalDebit: parsedJson['TOTDR'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        DailySubsidiaryConst.CreditHeaderConst: CreditHeader,
        DailySubsidiaryConst.CashCreditConst: CashCredit,
        DailySubsidiaryConst.TransferCreditConst: TransferCredit,
        DailySubsidiaryConst.TotalCreditConst: TotalCredit,
        DailySubsidiaryConst.CreditScrollNoConst: CreditScrollNo,
        DailySubsidiaryConst.DebitScrollNoConst: DebitScrollNo,
        DailySubsidiaryConst.DebitHeaderConst: DebitHeader,
        DailySubsidiaryConst.CashDebitConst: CashDebit,
        DailySubsidiaryConst.TransferDebitConst: TransferDebit,
        DailySubsidiaryConst.TotalDebitConst: TotalDebit,
      };
}

class DailySubsidiaryConst {
  static const String CreditHeaderConst = "CHDNM";
  static const String CashCreditConst = "CRAMT_C";
  static const String TransferCreditConst = "CRAMT_T";
  static const String TotalCreditConst = "TOTCR";
  static const String CreditScrollNoConst = "SCROLLNO_C";
  static const String DebitScrollNoConst = "SCROLLNO_D";
  static const String DebitHeaderConst = "DHDNM";
  static const String CashDebitConst = "DRAMT_C";
  static const String TransferDebitConst = "DRAMT_T";
  static const String TotalDebitConst = "TOTDR";
}

class BalanceUrls {
  static const String GET_BALANCES = "Management/GetDailySubsidiary";
}
