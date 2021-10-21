import 'package:teachers/handlers/string_handlers.dart';

class Division {
  int division_id;
  String division_name;
  bool isSelected = false;

  Division({
    this.division_id,
    this.division_name,
  });

  Division.fromMap(Map<String, dynamic> map) {
    division_id = map[DivisionConst.division_idConst];
    division_name = map[DivisionConst.division_nameConst];
  }

  Division.fromJson(Map<dynamic, dynamic> map)
      : division_id = map[DivisionConst.division_idConst] ?? 0,
        division_name =
            map[DivisionConst.division_nameConst] ?? StringHandlers.NotAvailable;


  Map<String, dynamic> toJson() => <String, dynamic>{
    DivisionConst.division_idConst: division_id,
    DivisionConst.division_nameConst: division_name
  };
  @override
  String toString() {
    // TODO: implement toString
    return division_name;
  }
}

class DivisionConst {
  static const String division_idConst = "division_id";
  static const String division_nameConst = "division_name";
  static const String class_noConst = "class_no";
}

class DivisionUrls {
  static const String GET_CLASSES = "Management/GetClasses";
  static const String GET_BRANCHWISEDIVISIONS = "Management/GetBranchwiseDivisions";
}
