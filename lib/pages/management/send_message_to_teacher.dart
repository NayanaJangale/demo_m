import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_message_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_select_item_message.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/list_filter_bar.dart';
import 'package:teachers/constants/http_request_methods.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/message.dart';
import 'package:teachers/models/student_attendance.dart';
import 'package:teachers/models/teacher.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/teacher_period.dart';
import 'package:teachers/models/user.dart';

import 'messages_page.dart';

class SendMessageToTeacher extends StatefulWidget {
  String MessageFor;
  SendMessageToTeacher(this.MessageFor);
  @override
  _SendMessageToTeacherState createState() => _SendMessageToTeacherState();
}

class _SendMessageToTeacherState extends State<SendMessageToTeacher> {
  GlobalKey<ScaffoldState> _sendMessageToTeacherPageGlobalKey;
  TeacherClass selectedClass;
  TeacherPeriod selectedPeriod;
  String subtitle, loadingText, selectedItem;
  bool isLoading ,isSelected =false;
  List<Teacher> teachers ;
  List<Teacher> filteredList;
  TextEditingController filterController, messageController;
  String filter;
  File imgFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    _sendMessageToTeacherPageGlobalKey = GlobalKey<ScaffoldState>();
    if(widget.MessageFor == "Teacher"){
      fetchManagementEmployee(widget.MessageFor).then((result) {
        setState(() {
          teachers = result;
        });
      });
    }else{
      fetchManagementEmployee(widget.MessageFor).then((result) {
        setState(() {
          teachers = result;
        });
      });
    }
    messageController = TextEditingController();
    filterController = TextEditingController();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    if (teachers!= null){
      filteredList = teachers.where((item) {
        if (filter == null || filter == '')
          return true;
        else {
          return item.SName.toLowerCase().contains(filter.toLowerCase());
        }
      }).toList();
    }
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _sendMessageToTeacherPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_send_message"),
            subtitle: '',
          ),
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListFilterBar(
                searchFieldController: this.filterController,
                onCloseButtonTap: () {
                  setState(() {
                    filterController.text = '';
                  });
                },
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){
                  setState(() {
                    isSelected = !isSelected;
                    for (Teacher teacher in teachers) {
                      teacher.isSelected = isSelected;
                    }
                  });
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
                          left: 5.0,
                          right: 10.0,
                          top: 3.0,
                          bottom: 3.0,
                        ),
                        child: Icon(
                          Icons.check_box,
                          color: this.isSelected
                              ? Theme.of(context).accentColor
                              : Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Select All",
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3.0,
                          bottom: 3.0,
                        ),
                        child: Icon(
                          Icons.navigate_next,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredList != null ? filteredList.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomSelectItemForMessage(
                      isSelected: filteredList[index].isSelected,
                      onItemTap: () {
                        setState(() {
                          filteredList[index].isSelected =
                              !filteredList[index].isSelected;
                        });
                      },
                      itemTitle: StringHandlers.capitalizeWords(
                          filteredList[index].SName),
                      itemIndex: index,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 40.0,
                        top: 0.0,
                        bottom: 0.0,
                      ),
                      child: Divider(
                        height: 0.0,
                      ),
                    );
                  },
                ),
              ),
              CustomMessageBar(
                messageFieldController: this.messageController,
                isMediaOptionRequired: true,
                msgHint: AppTranslations.of(context).text("key_type_message"),
                onSendButtonPressed: () {
                  String valMsg = getValidationMessage();
                  if (valMsg != '') {
                    FlushbarMessage.show(
                      context,
                      null,
                      valMsg,
                      MessageTypes.INFORMATION,
                    );
                  } else {
                    postMessage();
                  }
                },
                onMediaSelected: (result) {
                  imgFile = result;
                  messageController = messageController;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Teacher>> fetchManagementEmployee(String userType) async {
    List<Teacher> teachers = [];
    setState(() {
      isLoading = true;
    });

    try {


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no: user.emp_no.toString(),
          "empType": userType,
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              TeacherUrls.GET_MANAGEMENT_EMPLOYEE,
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
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.ERROR,
      );
    }
    setState(() {
      isLoading = false;
    });

    return teachers;
  }
  Future<void> postMessage() async {
    try {
      setState(() {
        isLoading = true;
      });

      String empNos = '';
      for (int i = 0; i < filteredList.length; i++) {
        if (filteredList[i].isSelected) {
          if (empNos != '') empNos += ',';
          empNos = empNos + filteredList[i].emp_no.toString();
        }
      }

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          UserFieldNames.user_id: user != null ? user.user_id : "",
          "MessageFor": 'Employee',
          UserFieldNames.emp_no: user.emp_no.toString(),
          "MessageContent": messageController.text,
          "RecipientNos": empNos,
          StudentAttendanceFieldNames.yr_no: user.yr_no.toString(),
        };

        Uri saveMessageUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                MessageUrls.POST_TEACHER_MESSAGE,
            params);

        http.Response response = await http.post(
          saveMessageUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: '',
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          // post Message Image
          if (imgFile != null) {
            await postMessageImage(
              int.parse(
                response.body.toString(),
              ),
            );
          } else {

            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                message: Text(
                  AppTranslations.of(context).text("key_save_message"),
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text(
                      AppTranslations.of(context).text("key_ok"),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context,
                          true); // It worked for me instead of above line
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MessagePage()),
                      );
                    },
                  )
                ],
              ),
            );
            setState(() {
              isLoading = false;
            });
          }

          _clearData();
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.ERROR,
          );
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
  }
  Future<void> postMessageImage(int MessageNo) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Message/PostMessageImage',
      ).replace(
        queryParameters: {
          UserFieldNames.brcode: AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          MessageFieldNames.MessageNo: MessageNo.toString(),
        },
      );

      final mimeTypeData =
          lookupMimeType(imgFile.path, headerBytes: [0xFF, 0xD8]).split('/');

      final imageUploadRequest =
          http.MultipartRequest(HttpRequestMethods.POST, postUri);

      final file = await http.MultipartFile.fromPath(
        'image',
        imgFile.path,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ),
      );

      imageUploadRequest.fields['ext'] = mimeTypeData[1];
      imageUploadRequest.files.add(file);

      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == HttpStatusCodes.CREATED) {
       /* FlushbarMessage.show(
          context,
          null,
          AppTranslations.of(context).text("key_save_message"),
          MessageTypes.ERROR,
        );
        Navigator.pop(context);*/
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              AppTranslations.of(context).text("key_save_message"),
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  AppTranslations.of(context).text("key_ok"),
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context,
                      true); // It worked for me instead of above line
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MessagePage()),
                  );
                },
              )
            ],
          ),
        );
      } else {
        FlushbarMessage.show(
          context,
          null,
          AppTranslations.of(context).text("key_image_not_saved"),
          MessageTypes.INFORMATION,
        );
      }
    } else {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_no_internet"),
        AppTranslations.of(context).text("key_check_internet"),
        MessageTypes.WARNING,
      );
    }
  }
  String getValidationMessage() {
    if (messageController.text == '')
      return AppTranslations.of(context).text("key_message_mandatory");

    if (selectedItem == 'Teacher Class') {
      if (filteredList.where((item) => item.isSelected == true).length == 0) {
        return AppTranslations.of(context).text("key_select_class_instruction");
      }
    } else {
      if (filteredList.where((item) => item.isSelected == true).length == 0) {
        return AppTranslations.of(context)
            .text("key_select_period_instruction");
      }
    }

    return '';
  }

  void _clearData() {
    setState(() {
      messageController.text = '';
      imgFile = null;
      for (Teacher teacher in teachers) {
        teacher.isSelected = false;
      }
    });
  }
}
