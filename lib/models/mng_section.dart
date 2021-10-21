class Section {
  String Section_desc;
  int Section_id;
  bool isSelected = false;

  Section({
    this.Section_desc,
    this.Section_id,
  });

  Section.fromMap(Map<String, dynamic> map) {
    Section_desc = map[SectionConst.Section_descConst];
    Section_id = map[SectionConst.Section_idConst];
  }
  factory Section.fromJson(Map<String, dynamic> parsedJson) {
    return Section(
      Section_desc: parsedJson['Section_desc'] as String,
      Section_id: parsedJson['Section_id'],
    );
  }
  @override
  String toString() {
    // TODO: implement toString
    return Section_desc;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        SectionConst.Section_descConst: Section_desc,
        SectionConst.Section_idConst: Section_id,
      };
}

class SectionUrls {
  static const String GET_SECTIONS = "Sections/GetSchoolSections";
}

class SectionConst {
  static const String Section_descConst = "Section_desc";
  static const String Section_idConst = "Section_id";
}
