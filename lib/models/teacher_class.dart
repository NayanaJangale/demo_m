import 'package:teachers/handlers/string_handlers.dart';

class TeacherClass {
  String class_name;
  String division_name;
  int class_id;
  int division_id;
  int Section_id;
  String section_name;
  bool isSelected = false;

  TeacherClass({
    this.class_name,
    this.division_name,
    this.class_id,
    this.division_id,
    this.Section_id,
    this.section_name,
  });

  factory TeacherClass.fromJson(Map<String, dynamic> parsedJson) {
    return TeacherClass(
      class_name: parsedJson['class_name'] ?? '',
      division_name: parsedJson['division_name'] ?? '',
      class_id: parsedJson['class_id'] ?? 0,
      division_id: parsedJson['division_id'] ?? 0,
      Section_id: parsedJson['Section_id'] ?? 0,
      section_name: parsedJson['section_name'] ?? StringHandlers.NotAvailable,
    );
  }

  Map<dynamic, dynamic> toJson() => <String, dynamic>{
        'class_name': class_name,
        'division_name': division_name,
        'class_id': class_id,
        'division_id': division_id,
        'Section_id': Section_id,
        'section_name': section_name,
      };

  @override
  String toString() {
    // TODO: implement toString
    return class_name + ' ' + division_name;
  }
}

class TeacherClassUrls {
  static const String GET_TEACHER_CLASSES = "Teacher/GetTeacherWiseClasses";
  static const String GET_SECTION_CLASSES = "Management/GetSectionwiseClasses";
}
