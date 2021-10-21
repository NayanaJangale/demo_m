import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_list_divider.dart';
import 'package:teachers/components/custom_list_item.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/class.dart';
import 'package:teachers/models/students.dart';
import 'package:teachers/models/teacher.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/management/mng_feedback_summery_page.dart';

class MngFeedbackPage extends StatefulWidget {
  @override
  _MngFeedbackPage createState() => _MngFeedbackPage();
}

class _MngFeedbackPage extends State<MngFeedbackPage> {
  List<Class> teacherClasses = [];
  List<Students> students = [];
  List<Teacher> teachers = [];
  List<String> menus = ['Camera', 'Gallery'];
  bool isLoading;
  bool isVisible;
  String loadingText;
  List<String> FeedbackSummaryFor = ['Students', 'Teachers'];
  Class selectedClass;
  String _className = '';
  String _subtitle = "Students";
  String msgKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isVisible = true;
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    msgKey = "key_feedback_instruction";

    fetchClasses().then((result) {
      setState(() {
        teacherClasses = result;
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
    if (_subtitle == 'Teachers') {
      isVisible = false;
    } else {
      isVisible = true;
    }
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_select_student"),
            subtitle: AppTranslations.of(context).text("key_view_feedback_of") +
                ": ${_subtitle == 'Teachers' ? AppTranslations.of(context).text("key_teacher") : AppTranslations.of(context).text("key_student")}",
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                _showFeedbackFor();
              },
            ),
          ],
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Visibility(
              visible: isVisible,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      showClassesList();
                    },
                    child: Container(
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
                        child: Row(
                          children: <Widget>[
                            Text(
                              AppTranslations.of(context)
                                  .text("key_select_class"),
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                _className,
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.white,
                                        ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            isVisible
                ? Expanded(
                    child: students != null && students.length != 0
                        ? ListView.separated(
                            itemCount: students.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CustomListItem(
                                onItemTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MngFeedbackSummaryPage(
                                        stud_no:
                                            students[index].stud_no.toString(),
                                      ),
                                    ),
                                  );
                                },
                                itemText: StringHandlers.capitalizeWords(
                                    students[index].student_name),
                                itemIndex: index,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return CustomListSeparator();
                            },
                          )
                        : ListView.builder(
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  AppTranslations.of(context).text(msgKey),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              );
                            },
                          ),
                  )
                : Expanded(
                    child: teachers != null && teachers.length != 0
                        ? ListView.separated(
                            itemCount: teachers.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CustomListItem(
                                onItemTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MngFeedbackSummaryPage(
                                        stud_no:
                                            teachers[index].emp_no.toString(),
                                      ),
                                    ),
                                  );
                                },
                                itemText: StringHandlers.capitalizeWords(
                                    teachers[index].SName),
                                itemIndex: index,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return CustomListSeparator();
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return CustomDataNotFound(
                                  description: AppTranslations.of(context)
                                      .text("key_teacher_not_available"),
                                );
                              },
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackFor() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_feedback_summery_for"),
        ),
        actions: List<Widget>.generate(
          FeedbackSummaryFor.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: FeedbackSummaryFor[i] == 'Teachers'
                ? AppTranslations.of(context).text("key_teacher")
                : AppTranslations.of(context).text("key_student"),
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                _subtitle = FeedbackSummaryFor[i].toString();
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showClassesList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_class"),
        ),
        actions: List<Widget>.generate(
          teacherClasses.length,
          (index) => CustomCupertinoActionSheetAction(
            actionText: teacherClasses[index].class_name,
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                selectedClass = teacherClasses[index];
                _className = selectedClass.class_name;
                fetchStudents().then(
                  (result) {
                    setState(() {
                      students = result != null ? result : [];
                    });
                  },
                );
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<List<Class>> fetchClasses() async {
    List<Class> classes = [];
    try {
      setState(() {
        isLoading = true;
      });

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {};

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ClassUrls.GET_CLASSES,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            classes = responseData.map((item) => Class.fromJson(item)).toList();
          });
          bool feedbackOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('feedback_overlay') ??
              false;
          if (!feedbackOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("feedback_overlay", true);
            _showOverlay(context);
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

    return classes;
  }

  Future<List<Students>> fetchStudents() async {
    List<Students> students = [];
    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          "class_id": selectedClass.class_id.toString()
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                StudentUrls.GET_CLASS_STUDENTS,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
          setState(() {
            msgKey = "key_students_not_found";
          });
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            students =
                responseData.map((item) => Students.fromJson(item)).toList();
          });
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

    return students;
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

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_feedback_summary_from_here")),
    );
  }
}
