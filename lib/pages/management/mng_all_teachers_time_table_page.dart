import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_all_timetable_tab.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/branch.dart';
import 'package:teachers/models/teacher.dart';
import 'package:teachers/models/teacher_time_table.dart';
import 'package:teachers/models/user.dart';

class MngAllTeachersTimeTables extends StatefulWidget {
  @override
  _MngAllTeachersTimeTablesState createState() =>
      _MngAllTeachersTimeTablesState();
}

class _MngAllTeachersTimeTablesState extends State<MngAllTeachersTimeTables> {
  bool isLoading;
  String loadingText;
  String msgKey;
  List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  List<TeacherTimeTable> teacherTimeTable = [];
  List<Branch> branches = [];
  List<Teacher> teachers = [];
  Teacher selectedTeacher;

  List<Color> freePeriodCOlors;

  List<Color> busyPeriodCOlors;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_frequent_absentee";

    fetchBranches().then((result) {
      setState(() {
        this.branches = result;
      });
    });
    fetchTeachers().then((result) {
      setState(() {
        teachers = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: DefaultTabController(
        length: branches.length,
        child: Scaffold(
          appBar: AppBar(
            title: CustomAppBar(
              title: AppTranslations.of(context).text("TimeTable"),
              subtitle: AppTranslations.of(context).text("key_teacher_timetable"),
            ),
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Theme.of(context).secondaryHeaderColor,
              tabs: List<Widget>.generate(
                branches.length,
                (i) => Tab(
                  text: branches.length == 0 ? "" : branches[i].brname,
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: List.generate(
              branches.length,
              (i) => getBranchReport(),
            ),
          ),
        ),
      ),
    );
  }

  Widget getBranchReport() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getInputWidgets(context),
        Expanded(
          child: NestedTabBar(
            list: teacherTimeTable,
          ),
        ),
      ],
    );
  }

  Widget getInputWidgets(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 8.0,
          right: 8.0,
          bottom: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (teachers != null && teachers.length > 0) {
                            showTeachersList();
                          } else {
                            fetchTeachers().then((result) {
                              setState(() {
                                teachers = result;
                              });

                              if (teachers != null && teachers.length > 0) {
                                showTeachersList();
                              }
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              selectedTeacher != null
                                  ? selectedTeacher.SName
                                  : 'Select Teacher',
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8.0,
                              ),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTimeTableTabViewWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: TabBar(
        isScrollable: true,
        indicatorColor: Theme.of(context).secondaryHeaderColor,
        tabs: List<Widget>.generate(
          days.length == 0 ? 1 : days.length,
          (i) => Tab(
            text: days.length == 0 ? "" : days[i],
          ),
        ),
      ),
    );
  }

  void showTeachersList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: 'Teachers',
        ),
        actions: List<Widget>.generate(
          teachers.length,
          (index) => CustomCupertinoActionSheetAction(
            actionText: teachers[index].SName,
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                selectedTeacher = teachers[index];
                fetchTimeTable().then((result) {
                  setState(() {
                    teacherTimeTable = result;
                  });
                });
              });
              Navigator.pop(context);
            },
          ),
        ),
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            AppTranslations.of(context).text("key_cancel"),
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<List<Branch>> fetchBranches() async {
    List<Branch> branches = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchBranchUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              BranchUrls.GET_BRANCHES,
          {},
        );

        http.Response response = await http.get(fetchBranchUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          branches = responseData
              .map(
                (item) => Branch.fromJson(item),
              )
              .toList();
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

    return branches;
  }

  Future<List<Teacher>> fetchTeachers() async {
    List<Teacher> teachers = [];
    setState(() {
      isLoading = true;
    });

    try {
      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {};

        Uri fetchClassesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              TeacherUrls.GET_TEACHER,
          params,
        );

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.ERROR,
          );
          setState(() {
            msgKey = "key_teacher_not_available";
          });
        } else {
          List responseData = json.decode(response.body);
          teachers =
              responseData.map((item) => Teacher.fromJson(item)).toList();
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

    return teachers;
  }

  Future<List<TeacherTimeTable>> fetchTimeTable() async {
    List<TeacherTimeTable> timeTable = [];
    try {
      setState(() {
        this.isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no: selectedTeacher.emp_no.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              TeacherTimeTableUrls.GET_TEACHER_TIMETABLE,
          params,
        );

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          timeTable = responseData
              .map((item) => TeacherTimeTable.fromJson(item))
              .toList();
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }
    setState(() {
      isLoading = false;
    });

    return timeTable;
  }
}
