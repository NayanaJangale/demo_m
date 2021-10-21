class Branch {
  String brcode;
  String brname;

  Branch({
    this.brcode,
    this.brname,
  });

  Branch.fromMap(Map<String, dynamic> map) {
    brcode = map[BranchConst.brcodeConst];
    brname = map[BranchConst.brnameConst];
  }
  factory Branch.fromJson(Map<String, dynamic> parsedJson) {
    return Branch(
      brcode: parsedJson['brcode'],
      brname: parsedJson['brname'],
    );
  }
  @override
  String toString() {
    return brname;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        BranchConst.brcodeConst: brcode,
        BranchConst.brnameConst: brname,
      };
}

class BranchConst {
  static const String brcodeConst = "brcode";
  static const String brnameConst = " brname";
}

class BranchUrls {
  static const String GET_BRANCHES = "Management/GetBranches";
}
