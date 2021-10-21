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
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/dashboard_attendace.dart';

class StudentAttendanceWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  StudentAttendanceWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _StudentAttendanceWidgetState createState() =>
      _StudentAttendanceWidgetState();
}

class _StudentAttendanceWidgetState extends State<StudentAttendanceWidget> {
  bool isLoading;
  String loadingText;
  bool isLoaded;
  String dateInState;
  String msgKey;

  List<DashboardAttendace> _dashboradAttendace = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_student_attendance";

    fetchStudentAttendace().then((result) {
      setState(() {
        _dashboradAttendace = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchStudentAttendace().then((result) {
            setState(() {
              _dashboradAttendace = result;
            });
          });
        },
        child: dataBody(),
      ),
    );
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
      fetchStudentAttendace().then((result) {
        setState(() {
          _dashboradAttendace = result;
          dateInState = widget.selected_date;
        });
      });
    }
    return _dashboradAttendace != null && _dashboradAttendace.length != 0
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
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_present"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_absent"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    /*DataColumn(
                      label: Text(
                        "F",
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),*/
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_total"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                  rows: new List<DataRow>.generate(
                    _dashboradAttendace.length,
                    (int index) {
                      return _dashboradAttendace[index].class_name == 'TOTAL'
                          ? DataRow(
                              selected: true,
                              cells: [
                                DataCell(
                                  Text(
                                    _dashboradAttendace[index].class_name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _dashboradAttendace[index]
                                        .presents
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _dashboradAttendace[index]
                                        .absent
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                /*DataCell(
                                  Text(
                                    _dashboradAttendace[index]
                                        .frequent
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                      fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),*/
                                DataCell(
                                  Text(
                                    _dashboradAttendace[index]
                                        .tot_stud
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            )
                          : _dashboradAttendace[index].division_name == ''
                              ? DataRow(
                                  selected: true,
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${AppTranslations.of(context).text("key_class")}  ${_dashboradAttendace[index].class_name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    /*DataCell(
                                      Text(''),
                                    ),*/
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
                                )
                              : DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        _dashboradAttendace[index]
                                            .division_name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _dashboradAttendace[index]
                                            .presents
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _dashboradAttendace[index]
                                            .absent
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    /* DataCell(
                                      Text(
                                        _dashboradAttendace[index]
                                            .frequent
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),*/
                                    DataCell(
                                      Text(
                                        _dashboradAttendace[index]
                                            .tot_stud
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                );
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
                      .text("key_student_attendance_instruction"),
                );
              },
            ),
          );
  }

  Future<List<DashboardAttendace>> fetchStudentAttendace() async {
    List<DashboardAttendace> dashboardAttendace = [];
    List<DashboardAttendace> _dashbord = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchAttendaceUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              DashboardAttendaceUrls.GET_DASHBOARD_ATTENDACE,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
            //"report_date": "2019-12-21",
          },
        );

        http.Response response = await http.get(fetchAttendaceUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_student_attendance_instruction";
          });
        } else {
          List responseData = json.decode(response.body);
          dashboardAttendace = responseData
              .map(
                (item) => DashboardAttendace.fromJson(item),
              )
              .toList();

          String lClass = '';
          for (int i = 0; i < dashboardAttendace.length; i++) {
            if (dashboardAttendace[i].class_name == 'TOTAL') {
              _dashbord.add(dashboardAttendace[i]);
            } else {
              if (lClass == '') {
                setState(() {
                  lClass = dashboardAttendace[i].class_name;

                  _dashbord.add(
                    DashboardAttendace(
                      class_name: dashboardAttendace[i].class_name,
                      division_name: '',
                      absent: dashboardAttendace[i].absent,
                      frequent: dashboardAttendace[i].frequent,
                      presents: dashboardAttendace[i].presents,
                      tot_stud: dashboardAttendace[i].tot_stud,
                    ),
                  );
                });
              } else {
                setState(() {
                  lClass = dashboardAttendace[i - 1].class_name;
                });
              }

              if (lClass == dashboardAttendace[i].class_name) {
                setState(() {
                  _dashbord.add(dashboardAttendace[i]);
                });
              } else {
                setState(() {
                  _dashbord.add(
                    DashboardAttendace(
                      class_name: dashboardAttendace[i].class_name,
                      division_name: '',
                      absent: dashboardAttendace[i].absent,
                      frequent: dashboardAttendace[i].frequent,
                      presents: dashboardAttendace[i].presents,
                      tot_stud: dashboardAttendace[i].tot_stud,
                    ),
                  );
                  _dashbord.add(dashboardAttendace[i]);
                });
              }
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

    return _dashbord;
  }
}
