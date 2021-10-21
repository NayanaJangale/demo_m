import 'package:teachers/handlers/string_handlers.dart';

class TeacherPeriod {
  String subject_name;
  String subject_abbr;
  String class_name;
  String division_name;
  int subject_id;
  int class_id;
  int division_id;
  int Section_id;
  String Section_desc;
  bool isSelected = false;

  TeacherPeriod({
    this.subject_name,
    this.subject_abbr,
    this.class_name,
    this.division_name,
    this.subject_id,
    this.class_id,
    this.division_id,
    this.Section_id,
    this.Section_desc,
  });

  TeacherPeriod.fromMap(Map<dynamic, dynamic> map)
      : subject_name = map["subject_name"] ?? StringHandlers.NotAvailable,
        subject_abbr = map["subject_abbr"] ?? StringHandlers.NotAvailable,
        class_name = map["class_name"] ?? StringHandlers.NotAvailable,
        division_name = map["division_name"] ?? StringHandlers.NotAvailable,
        subject_id = map["subject_id"] ?? 0,
        class_id = map["class_id"] ?? 0,
        division_id = map["division_id"] ?? 0,
        Section_id = map["Section_id"] ?? 0,
        Section_desc = map["Section_desc"] ?? 0;

  factory TeacherPeriod.fromJson(Map<String, dynamic> map) {
    return TeacherPeriod(
      subject_name: map["subject_name"] ?? StringHandlers.NotAvailable,
      subject_abbr: map["subject_abbr"] ?? StringHandlers.NotAvailable,
      class_name: map["class_name"] ?? StringHandlers.NotAvailable,
      division_name: map["division_name"] ?? StringHandlers.NotAvailable,
      subject_id: map["subject_id"] ?? 0,
      class_id: map["class_id"] ?? 0,
      division_id: map["division_id"] ?? 0,
      Section_id: map["Section_id"] ?? 0,
      Section_desc: map["Section_desc"] ?? 0,
    );
  }

  Map<dynamic, dynamic> toJson() => <String, dynamic>{
        'subject_name': subject_name,
        'subject_abbr': subject_abbr,
        'class_name': class_name,
        'division_name': division_name,
        'subject_id': subject_id,
        'class_id': class_id,
        'division_id': division_id,
        'Section_id': Section_id,
        'Section_desc': Section_desc,
      };

  @override
  String toString() {
    // TODO: implement toString
    return class_name + ' ' + division_name + ': ' + subject_name;
  }
}

class TeacherPeriodUrls {
  static const String GET_TEACHER_PERIODS = 'Teacher/GetTeacherPeriods';
}
