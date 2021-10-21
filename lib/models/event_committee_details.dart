import 'package:teachers/handlers/string_handlers.dart';

class EventCommitteeDetails {
  int event_no;
  int seq_no;
  int member_code;
  String member_name;
  String incharge;
  String responsibilities;
  String contact_no;

  EventCommitteeDetails({
    this.event_no,
    this.seq_no,
    this.member_code,
    this.member_name,
    this.incharge,
    this.responsibilities,
    this.contact_no,
  });

  EventCommitteeDetails.fromJson(Map<String, dynamic> map) {
    event_no = map[EventCommitteeDetailsFieldNames.event_no] ?? 0;
    seq_no = map[EventCommitteeDetailsFieldNames.seq_no] ?? 0;
    member_code = map[EventCommitteeDetailsFieldNames.member_code] ?? 0;
    member_name = map[EventCommitteeDetailsFieldNames.member_name] ??
        StringHandlers.NotAvailable;
    incharge = map[EventCommitteeDetailsFieldNames.incharge] ??
        StringHandlers.NotAvailable;
    responsibilities = map[EventCommitteeDetailsFieldNames.responsibilities] ??
        StringHandlers.NotAvailable;
    contact_no = map[EventCommitteeDetailsFieldNames.contact_no] ??
        StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        EventCommitteeDetailsFieldNames.event_no: event_no,
        EventCommitteeDetailsFieldNames.seq_no: seq_no,
        EventCommitteeDetailsFieldNames.member_code: member_code,
        EventCommitteeDetailsFieldNames.member_name: member_name,
        EventCommitteeDetailsFieldNames.incharge: incharge,
        EventCommitteeDetailsFieldNames.responsibilities: responsibilities,
        EventCommitteeDetailsFieldNames.contact_no: contact_no,
      };
}

class EventCommitteeDetailsFieldNames {
  static const String event_no = 'event_no';
  static const String seq_no = 'seq_no';
  static const String member_code = 'member_code';
  static const String member_name = 'member_name';
  static const String incharge = 'incharge';
  static const String responsibilities = 'responsibilities';
  static const String contact_no = 'contact_no';
}

class EventCommitteeUrls {
  static const String GET_EVENT_COMMITTEES = 'Calendar/GetEventCommittees';
}
