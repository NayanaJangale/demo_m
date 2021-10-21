class HomeWorkStatus {
  int period_no;
  String class_name,
      division_name,
      subject_name,
      teacher_name,
      hw_desc,
      hw_status,
      period_desc;
  DateTime hw_date, submission_dt;

  HomeWorkStatus({
    this.period_no,
    this.class_name,
    this.division_name,
    this.hw_date,
    this.subject_name,
    this.teacher_name,
    this.hw_desc,
    this.hw_status,
    this.period_desc,
    this.submission_dt,
  });

  HomeWorkStatus.fromJson(Map<String, dynamic> map) {
    period_no = map[HomeWorkStatusFieldNames.period_no];
    class_name = map[HomeWorkStatusFieldNames.class_name];
    division_name = map[HomeWorkStatusFieldNames.division_name];
    hw_date = DateTime.parse(map[HomeWorkStatusFieldNames.hw_date]);
    subject_name = map[HomeWorkStatusFieldNames.subject_name];
    teacher_name = map[HomeWorkStatusFieldNames.teacher_name];
    hw_desc = map[HomeWorkStatusFieldNames.hw_desc];
    hw_status = map[HomeWorkStatusFieldNames.hw_status];
    period_desc = map[HomeWorkStatusFieldNames.period_desc];
    submission_dt = map[HomeWorkStatusFieldNames.submission_dt] == null
        ? null
        : DateTime.parse(map[HomeWorkStatusFieldNames.submission_dt]);
  }

  HomeWorkStatus.map(Map<String, dynamic> map) {
    period_no = map[HomeWorkStatusFieldNames.period_no];
    class_name = map[HomeWorkStatusFieldNames.class_name];
    division_name = map[HomeWorkStatusFieldNames.division_name];
    hw_date = DateTime.parse(map[HomeWorkStatusFieldNames.hw_date]);
    subject_name = map[HomeWorkStatusFieldNames.subject_name];
    teacher_name = map[HomeWorkStatusFieldNames.teacher_name];
    hw_desc = map[HomeWorkStatusFieldNames.hw_desc];
    hw_status = map[HomeWorkStatusFieldNames.hw_status];
    period_desc = map[HomeWorkStatusFieldNames.period_desc];
    submission_dt = DateTime.parse(map[HomeWorkStatusFieldNames.submission_dt]);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    HomeWorkStatusFieldNames.period_no: period_no,
    HomeWorkStatusFieldNames.class_name: class_name,
    HomeWorkStatusFieldNames.hw_date:
    hw_date == null ? null : hw_date.toIso8601String(),
    HomeWorkStatusFieldNames.subject_name: subject_name,
    HomeWorkStatusFieldNames.teacher_name: teacher_name,
    HomeWorkStatusFieldNames.hw_desc: hw_desc,
    HomeWorkStatusFieldNames.hw_status: hw_status,
    HomeWorkStatusFieldNames.period_desc: period_desc,
    HomeWorkStatusFieldNames.submission_dt:
    submission_dt == null ? null : submission_dt.toIso8601String()
  };
}

class HomeWorkStatusFieldNames {
  static String period_no = "period_no";
  static String class_name = "class_name";
  static String division_name = "division_name";
  static String hw_date = "hw_date";
  static String subject_name = "subject_name";
  static String teacher_name = "teacher_name";
  static String hw_desc = "hw_desc";
  static String hw_status = "hw_status";
  static String period_desc = "period_desc";
  static String submission_dt = "submission_dt";
}

class HomeWorkStatusUrls {
  static const String GET_HOMEWORK_STATUS = 'Management/GetHomeworkStatus';
}