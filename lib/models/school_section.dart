import 'package:teachers/handlers/string_handlers.dart';

class SchoolSection {
  int section_id;
  String section_name;

  SchoolSection({
    this.section_id,
    this.section_name,
  });

  SchoolSection.fromJson(Map<String, dynamic> map) {
    section_id = map[SchoolSectionFieldNames.section_id] ?? 0;
    section_name = map[SchoolSectionFieldNames.section_name] ??
        StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        SchoolSectionFieldNames.section_id: section_id,
        SchoolSectionFieldNames.section_name: section_name,
      };
}

class SchoolSectionFieldNames {
  static const String section_id = 'Section_id';
  static const String section_name = 'Section_desc';
}

class SchoolSectionUrls {
  static const String GET_SCHOOL_SECTIONS = 'Sections/GetSchoolSections';
}
