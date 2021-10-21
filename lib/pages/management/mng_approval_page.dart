import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_alert_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_circular_item.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_homework_item.dart';
import 'package:teachers/components/custom_leaves_application_item.dart';
import 'package:teachers/components/custom_list_divider.dart';
import 'package:teachers/components/custom_message_item.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/circular.dart';
import 'package:teachers/models/class.dart';
import 'package:teachers/models/configuration.dart';
import 'package:teachers/models/employee_leaves.dart';
import 'package:teachers/models/homework.dart';
import 'package:teachers/models/leave_aplication.dart';
import 'package:teachers/models/message.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/management/message_details_page.dart';

class MngApprovalPage extends StatefulWidget {
  @override
  _MngApprovalPage createState() => _MngApprovalPage();
}

class _MngApprovalPage extends State<MngApprovalPage> {
  List<Homework> _homeworks = [];
  List<Circular> _circulars = [];
  bool isLoading;
  String loadingText;
  Class selectedClass;
  String _subtitle = "";
  String msgKey;
  List<Configuration> _configurations = [];
  GlobalKey<ScaffoldState> _newslatterPageGK;
  String selectedAttendaceType = "";
  List<LeaveApplication> _LeavesApplication = [];
  List<Message> _messages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _newslatterPageGK = GlobalKey<ScaffoldState>();
    fetchConfiguration(ConfigurationGroups.ApprovedByManagement).then((result) {
      setState(() {
        _configurations = result;
        if(_configurations!= null && _configurations.length>0){
          _subtitle = _configurations[0].confName;
          if(_subtitle== 'Circular'){
            fetchCirculars().then((result) {
              setState(() {
                _circulars = result;
              });
            });
          }else if (_subtitle== 'Homework'){
            fetchHomework().then((result) {
              setState(() {
                _homeworks = result;
              });
            });
          }else{
            fetchmessages().then((result) {
              setState(() {
                _messages = result;
              });
            });
          }
        }
      });
    });
    this.loadingText = 'Loading . . .';
    msgKey = "";
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _newslatterPageGK,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_approval"),
            subtitle: (AppTranslations.of(context).text("key_approval_for")+
                " : "+_subtitle),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                _showApprovalFor();
              },
            ),
          ],
          elevation: 0,
        ),
        body: _subtitle == 'Homework'
            ? RefreshIndicator(
                onRefresh: () async {
                  fetchHomework().then((result) {
                    setState(() {
                      _homeworks = result;
                    });
                  });
                },
                child: _homeworks != null && _homeworks.length > 0
                    ? ListView.builder(
                        itemCount: _homeworks.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CustomHomeworkItem(
                            networkPath: '',
                            onItemTap: () {
                              _UpdateHomeworkStatus(
                                  _homeworks[index].hw_no);
                            },
                            periods: _homeworks[index].periods,
                            homework: _homeworks[index],
                          );
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return CustomDataNotFound(
                              description: AppTranslations.of(context)
                                  .text("key_homework_not_available"),
                            );
                          },
                        ),
                      ),
              )
            : _subtitle == 'Circular'
            ? RefreshIndicator(
                    onRefresh: () async {
                      fetchCirculars().then((result) {
                        setState(() {
                          _circulars = result;
                        });
                      });
                    },
                    child: _circulars != null && _circulars.length != 0
                        ? ListView.builder(
                            itemCount: _circulars.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CustomCircularItem(
                                networkPath: '',
                                onItemTap: () {
                                  _UpdateCircularStatus(
                                      _circulars[index].circular_no);
                                },
                                periods: _circulars[index].periods,
                                circular: _circulars[index],
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return CustomDataNotFound(
                                  description: AppTranslations.of(context)
                                      .text("key_circular_not_available"),
                                );
                              },
                            ),
                          ),
                  )
            : getmessages(),
      ),
    );
  }
  Widget getmessages() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchmessages().then((result) {
          setState(() {
            _messages = result;
          });
        });
      },
      child: _messages != null && _messages.length != 0
          ? ListView.separated(
        itemCount: _messages.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder<String>(
              future: getOutboxImageUrl(_messages[index]),
              builder: (context, AsyncSnapshot<String> snapshot) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageDetailsPage(
                          networkPath: snapshot.data.toString(),
                          message: _messages[index].MessageContent,
                          messageNo:
                          _messages[index].MessageNo.toString(),
                          timeStamp: DateFormat('dd MMM hh:mm aaa')
                              .format(_messages[index].MessageDate),
                          recipients: _messages[index].recipients,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 15.0,
                            top: 3.0,
                            bottom: 3.0,
                          ),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                              ),
                              child: Text(''),
                            ),
                            width: 3.0,
                            color: Colors.transparent,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          "Message :",
                                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(
                                        _messages[index].MessageDate) ==
                                        DateFormat('dd-MM-yyyy').format(DateTime.now())
                                        ? DateFormat('hh:mm a')
                                        .format(_messages[index].MessageDate)
                                        : DateFormat('dd-MMM')
                                        .format(_messages[index].MessageDate),
                                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.navigate_next,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: Text(
                                  _messages[index].MessageContent,
                                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8.0,
                                  bottom: 10.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      _messages[index].SenderName,
                                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap:(){
                                        _UpdatemessageStatus(_messages[index].MessageNo);
                                      },
                                      child: Text(
                                        AppTranslations.of(context).text("key_Approve"),
                                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
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
                  .text("key_messages_not_available"),
            );
          },
        ),
      ),
    );
  }
  void _UpdatemessageStatus(int messageNo) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          Navigator.pop(context);
          UpdateMessageStatus(messageNo);
        },
        actionColor: Colors.red,
        message: AppTranslations.of(context).text("key_approve_message"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  Future<String> getOutboxImageUrl(Message message) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Message/GetMessageImage',
          ).replace(queryParameters: {
            MessageFieldNames.MessageNo: message.MessageNo.toString(),
            "clientCode":
            AppData.getCurrentInstance().user.client_code.toString(),
            UserFieldNames.brcode:
            AppData.getCurrentInstance().user.brcode.toString(),
          }).toString();
        }
      });
  void _UpdateHomeworkStatus(int hw_no) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          Navigator.pop(context);
          UpdateHomeworkStatus(hw_no);
        },
        actionColor: Colors.red,
        message: AppTranslations.of(context).text("key_approve_homework"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget getEmployeeAppliedLeaves() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchEmpAppliedLeaves().then((result) {
          setState(() {
            _LeavesApplication = result;
          });
        });
      },
      child: _LeavesApplication != null && _LeavesApplication.length != 0
          ? ListView.builder(
              itemCount: _LeavesApplication.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomLeaveApplicationItem(
                  leave_type: _LeavesApplication[index].l_desc,
                  start_date: DateFormat('dd MMM ')
                      .format(_LeavesApplication[index].sdate),
                  end_date: DateFormat('dd MMM ')
                      .format(_LeavesApplication[index].edate),
                  apply_date: DateFormat('dd MMM ')
                      .format(_LeavesApplication[index].adate),
                  status: _LeavesApplication[index].status,
                );
              },
            )
          : Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return CustomDataNotFound(
                    description: AppTranslations.of(context)
                        .text("key_applied_leave_not_found"),
                  );
                },
              ),
            ),
    );
  }

  void _showApprovalFor() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_approval_for"),
        ),
        actions: List<Widget>.generate(
          _configurations.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: _configurations[i].confName,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                _subtitle = _configurations[i].confName;
                if(_subtitle== 'Circular'){
                  fetchCirculars().then((result) {
                    setState(() {
                      _circulars = result;
                    });
                  });
                }else if (_subtitle== 'Homework'){
                  fetchHomework().then((result) {
                    setState(() {
                      _homeworks = result;
                    });
                  });
                }else if (_subtitle =='Message'){
                  fetchmessages().then((result) {
                    setState(() {
                      _messages = result;
                    });
                  });
                }
              });

              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<List<Circular>> fetchCirculars() async {
    List<Circular> circulars = [];

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchCircularsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              CircularUrls.GET_PRNDING_CIRCULARS,
          {
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.yr_no:
                AppData.getCurrentInstance().user.yr_no.toString(),
          },
        );

        http.Response response = await http.get(fetchCircularsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
          setState(() {
            msgKey = "key_circulars_not_available";
          });
        } else {
          List responseData = json.decode(response.body);
          circulars = responseData
              .map(
                (item) => Circular.fromJson(item),
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

    return circulars;
  }

  Future<List<Homework>> fetchHomework() async {
    List<Homework> homework = [];

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchHomeworksUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              HomeworkUrls.GET_PENDING_HOMEWORK,
          {
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.yr_no:
                AppData.getCurrentInstance().user.yr_no.toString(),
          },
        );

        http.Response response = await http.get(fetchHomeworksUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          homework = responseData
              .map(
                (item) => Homework.fromJson(item),
              )
              .toList();
          bool approvalOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('approval_overlay') ??
              false;
          if (!approvalOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("approval_overlay", true);
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

    return homework;
  }

  Future<String> getHomeworkImageUrl(Homework homework) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Homework/GetHomeworkImage',
          ).replace(queryParameters: {
            "hw_no": homework.hw_no.toString(),
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          }).toString();
        }
      });
  Future<String> getCircularImageUrl(Circular circular) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Circular/GetCircularImage',
          ).replace(queryParameters: {
            "circular_no": circular.circular_no.toString(),
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          }).toString();
        }
      });
  Future<void> UpdateHomeworkStatus(int hw_no) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing . .';
      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postChangePasswordUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              HomeworkUrls.UPDATE_HOMEWORK_STATUS,
          {
            'hw_no': hw_no.toString(),
            'approvestatus': "A",
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.brcode:
                AppData.getCurrentInstance().user.brcode.toString(),
          },
        );
        http.Response response = await http.post(postChangePasswordUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        if (response.statusCode == HttpStatusCodes.CREATED) {
          //TODO: Call login
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                AppTranslations.of(context).text("key_homework_status_updated"),
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(
                      AppTranslations.of(context).text("key_ok"),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                      // It worked for me instead of above line
                      fetchHomework().then((result) {
                        setState(() {
                          _homeworks = result;
                        });
                      });
                    })
              ],
            ),
          );
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.ERROR,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }
  Future<void> UpdateMessageStatus(int messageNo) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing . .';
      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postChangePasswordUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              MessageUrls.UPDATE_MESSAGE_STATUS,
          {
            'MessageNo': messageNo.toString(),
            'approvestatus': "A",
            UserFieldNames.emp_no:
            AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.brcode:
            AppData.getCurrentInstance().user.brcode.toString(),
          },
        );
        http.Response response = await http.post(postChangePasswordUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });
        if (response.statusCode == HttpStatusCodes.CREATED) {
          //TODO: Call login
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
          fetchmessages().then((result) {
            setState(() {
              _messages = result;
            });
          });
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.ERROR,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }
  Future<void> UpdateCircularStatus(int circularNo) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing . .';
      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postChangePasswordUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              CircularUrls.UPDATE_CIRCULAR_STATUS,
          {
            'circular_no': circularNo.toString(),
            'approvestatus': "A",
            UserFieldNames.emp_no:
            AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.brcode:
            AppData.getCurrentInstance().user.brcode.toString(),
          },
        );
        http.Response response = await http.post(postChangePasswordUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        if (response.statusCode == HttpStatusCodes.CREATED) {
          //TODO: Call login
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                AppTranslations.of(context).text("key_circular_status_updated"),
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(
                      AppTranslations.of(context).text("key_ok"),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                      // It worked for me instead of above line
                      fetchCirculars().then(
                            (result) {
                          setState(() {
                            _circulars = result;
                          });
                        },
                      );
                    })
              ],
            ),
          );
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.ERROR,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }
  void _UpdateCircularStatus(int circular_no) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          Navigator.pop(context);
          UpdateCircularStatus(circular_no);
        },
        actionColor: Colors.red,
        message: AppTranslations.of(context).text("key_approve_circular"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  void _UpdateEmployeeLeave(int application_no) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          Navigator.pop(context);
          //UpdateEmployeeLeave(application_no);
        },
        actionColor: Colors.red,
        message: AppTranslations.of(context).text("key_approve_employee_leave"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  Future<List<Configuration>> fetchConfiguration(String confGroup) async {
    List<Configuration> configurations = [];
    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          ConfigurationFieldNames.ConfigurationGroup: confGroup,
          "stud_no": "1",
          "yr_no": "1",
          "brcode": AppData.getCurrentInstance().user.brcode,
        };

        Uri fetchSchoolsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              ConfigurationUrls.GET_CONFIGURATION_BY_VALUE,
          params,
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
              context, null, response.body, MessageTypes.WARNING);
        } else {
          List responseData = json.decode(response.body);
          configurations = responseData
              .map(
                (item) => Configuration.fromJson(item),
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

    return configurations;
  }
  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_approval_topic")),
    );
  }
  Future<List<Message>> fetchmessages() async {
    List<Message> _messages;
    try {
      setState(() {
        this.isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no:
          AppData.getCurrentInstance().user.emp_no.toString(),
          UserFieldNames.yr_no:
          AppData.getCurrentInstance().user.yr_no.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                MessageUrls.POST_PENDING_MESSAGE,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.INFORMATION,
          );
          _messages = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            _messages =
                responseData.map((item) => Message.fromMap(item)).toList();
          });
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
        _messages = null;
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      _messages = null;
    }
    setState(() {
      isLoading = false;
    });

    return _messages;
  }
  Future<List<LeaveApplication>> fetchEmpAppliedLeaves() async {
    List<LeaveApplication> employeeLeave = [];

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              EmployeeLeaveUrls.GET_LEAVES_APPLICATION,
          {
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString()
            //  "report_date": "2017-12-24",
          },
        );

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          employeeLeave = responseData
              .map(
                (item) => LeaveApplication.fromJson(item),
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

    return employeeLeave;
  }
}
