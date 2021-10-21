import 'package:teachers/handlers/string_handlers.dart';

class EventScheduleDetails {
  int event_no;
  int seq_no;
  String title;
  String description;
  DateTime event_date_time;

  EventScheduleDetails({
    this.event_no,
    this.seq_no,
    this.title,
    this.description,
    this.event_date_time,
  });

  EventScheduleDetails.fromJson(Map<String, dynamic> map) {
    event_no = map[EventScheduleDetailsFieldNames.event_no] ?? 0;
    seq_no = map[EventScheduleDetailsFieldNames.seq_no] ?? 0;
    title = map[EventScheduleDetailsFieldNames.title] ??
        StringHandlers.NotAvailable;
    description = map[EventScheduleDetailsFieldNames.description] ??
        StringHandlers.NotAvailable;
    event_date_time = map[EventScheduleDetailsFieldNames.event_date_time] !=
                null &&
            map[EventScheduleDetailsFieldNames.event_date_time]
                    .toString()
                    .trim() !=
                ''
        ? DateTime.parse(map[EventScheduleDetailsFieldNames.event_date_time])
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        EventScheduleDetailsFieldNames.event_no: event_no,
        EventScheduleDetailsFieldNames.seq_no: seq_no,
        EventScheduleDetailsFieldNames.title: title,
        EventScheduleDetailsFieldNames.description: description,
        EventScheduleDetailsFieldNames.event_date_time:
            event_date_time.toIso8601String(),
      };
}

class EventScheduleDetailsFieldNames {
  static const String event_no = 'event_no';
  static const String seq_no = 'seq_no';
  static const String title = 'title';
  static const String description = 'description';
  static const String event_date_time = 'event_date_time';
}

class EventScheduleUrls {
  static const String GET_EVENT_SCHEDULE = 'Calendar/GetEventSchedule';
}
