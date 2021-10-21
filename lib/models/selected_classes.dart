

class SelectedClass
{
  int section_id;
  int class_id;
  int division_id;
  int subject_id;

  SelectedClass({this.section_id, this.class_id, this.division_id,this.subject_id});



  Map<String, dynamic> toJson() => <String, dynamic>{
    ClassFieldNames.class_id: class_id ,
    ClassFieldNames.division_id: division_id,
    ClassFieldNames.section_id: section_id,
    ClassFieldNames.subject_id: subject_id,

  };


}
class ClassFieldNames {
  static const String class_id = "class_id";
  static const String division_id = "division_id";
  static const String section_id = "section_id";
  static const String subject_id = "subject_id";


}