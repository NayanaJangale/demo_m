import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/mng_attendance_entry_status.dart';

class MngAttendanceEntryStatusWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  MngAttendanceEntryStatusWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngAttendanceEntryStatusWidgetState createState() =>
      _MngAttendanceEntryStatusWidgetState();
}

class _MngAttendanceEntryStatusWidgetState
    extends State<MngAttendanceEntryStatusWidget> {
  List<AttendanceEntryStatus> attendance = [];
  String loadingText;
  bool isLoading;
  bool isLoaded;
  String dateInState;
  String msgKey;

  @override
  void initState() {
    isLoading = false;
    loadingText = 'Loading . . .';

    msgKey = "key_loading_entry_status";

    fetchAttendanceEntryStatus().then((result) {
      setState(() {
        attendance = result;
      });
    });
    super.initState();
  }

  Widget dataBody() {
    if (widget.selected_date == dateInState) {
      setState(() {
        isLoaded = false;
      });
    } else {
      setState(() {
        isLoaded = true;
      });
    }
    if (isLoaded) {
      fetchAttendanceEntryStatus().then((result) {
        setState(() {
          attendance = result;
          dateInState = widget.selected_date;
        });
      });
    }
    return attendance != null && attendance.length != 0
        ? ListView(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowHeight: 40,
                  columns: [
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_division"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_teacher_name"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_entry"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_entry_time"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                  rows: new List<DataRow>.generate(
                    attendance.length,
                    (int index) {
                      if (attendance[index].emp_name == '') {
                        return DataRow(
                          selected: true,
                          cells: [
                            DataCell(
                              Text(
                                '${AppTranslations.of(context).text("key_class")} ${attendance[index].class_name}',
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text(''),
                            ),
                          ],
                        );
                      } else {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                attendance[index].division_name,
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    attendance[index].emp_name),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    attendance[index].at_status),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                attendance[index].ent_date_time != null
                                    ? attendance[index]
                                        .ent_date_time
                                        .toIso8601String()
                                    : 'Not Available',
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: AppTranslations.of(context)
                      .text("key_Attendance_Entry_instruction"),
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchAttendanceEntryStatus().then((result) {
            setState(() {
              attendance = result;
            });
          });
        },
        child: dataBody(),
      ),
    );
  }

  Future<List<AttendanceEntryStatus>> fetchAttendanceEntryStatus() async {
    List<AttendanceEntryStatus> attStatus = [];

    List<AttendanceEntryStatus> att_all = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchAttendanceEntryStatusUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              AttendanceEntryStatusUrls.GET_ATTENDANCE_ENTRY_STATUS,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchAttendanceEntryStatusUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );

          setState(() {
            msgKey = "key_Attendance_Entry_instruction";
          });
        } else {
          List responseData = json.decode(response.body);
          att_all = responseData
              .map(
                (item) => AttendanceEntryStatus.fromMap(item),
              )
              .toList();

          String lClass = '';
          for (int i = 0; i < att_all.length; i++) {
            if (lClass == '') {
              setState(() {
                lClass = att_all[i].class_name;

                attStatus.add(
                  AttendanceEntryStatus(
                    class_name: att_all[i].class_name,
                    emp_name: '',
                  ),
                );
              });
            } else {
              setState(() {
                lClass = att_all[i - 1].class_name;
              });
            }

            if (lClass == att_all[i].class_name) {
              setState(() {
                attStatus.add(att_all[i]);
              });
            } else {
              setState(() {
                attStatus.add(
                  AttendanceEntryStatus(
                    class_name: att_all[i].class_name,
                    emp_name: '',
                  ),
                );
                attStatus.add(att_all[i]);
              });
            }
          }
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
        setState(() {
          msgKey = "key_check_internet";
        });
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      setState(() {
        msgKey = "key_api_error";
      });
    }

    setState(() {
      isLoading = false;
    });

    return attStatus;
  }
}
