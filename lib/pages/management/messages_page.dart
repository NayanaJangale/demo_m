import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_data_not_found.dart';
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
import 'package:teachers/models/configuration.dart';
import 'package:teachers/models/message.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/management/message_details_page.dart';
import 'package:teachers/pages/management/send_message_to_teacher.dart';
import 'package:teachers/pages/management/bottom_nevigation_page.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  GlobalKey<ScaffoldState> _messagePageGlobalKey;
  bool isLoading;
  String loadingText;
  List<Message> outboxMessages = [], inboxMessages = [];

  List<Configuration> _configurations = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchConfiguration(ConfigurationGroups.Message).then((result) {
      setState(() {
        _configurations = result;
      });
    });

    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    _messagePageGlobalKey = GlobalKey<ScaffoldState>();

    fetchMessages('Inbox').then((result) {
      setState(() {
        inboxMessages = result;
      });
    });

    fetchMessages('Outbox').then((result) {
      setState(() {
        outboxMessages = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: CustomProgressHandler(
        isLoading: this.isLoading,
        loadingText: this.loadingText,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: CustomAppBar(
                title: AppTranslations.of(context).text("key_messages"),
                subtitle:
                    AppTranslations.of(context).text("key_messages_subtitle"),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        message: CustomCupertinoActionMessage(
                          message: AppTranslations.of(context)
                              .text("key_send_message_to"),
                        ),
                        actions: List<Widget>.generate(
                          _configurations.length,
                          (i) => CustomCupertinoActionSheetAction(
                            actionIndex: i,
                            actionText: _configurations[i].confName,
                            onActionPressed: () {
                              setState(() {
                                if (_configurations[i].confName == "Teacher") {
                                  Navigator.pop(context,
                                      true); // It worked for me instead of above line
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SendMessageToTeacher("Teacher")),
                                  );
                                } else {
                                  Navigator.pop(context,
                                      true); // It worked for me instead of above line
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SendMessageToTeacher("Management")),
                                  );
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              bottom: TabBar(
                indicatorColor: Theme.of(context).secondaryHeaderColor,
                isScrollable: false,
                tabs: <Widget>[
                  Tab(
                    text: AppTranslations.of(context).text("key_inbox"),
                  ),
                  Tab(
                    text: AppTranslations.of(context).text("key_outbox"),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                getInboxMessages(),
                getOutboxMessages(),
              ],
            ),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget getInboxMessages() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchMessages('Inbox').then((result) {
          setState(() {
            inboxMessages = result;
          });
        });
      },
      child: inboxMessages != null && inboxMessages.length != 0
          ? ListView.separated(
              itemCount: inboxMessages.length,
              itemBuilder: (BuildContext context, int index) {
                int time = inboxMessages[index]
                    .MessageDate
                    .difference(DateTime.now())
                    .inHours;
                return FutureBuilder<String>(
                    future: getInboxImageUrl(inboxMessages[index]),
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      return CustomMessageItem(
                        onMessageItemTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MessageDetailsPage(
                                networkPath: snapshot.data.toString(),
                                message: inboxMessages[index].MessageContent,
                                messageNo:
                                    inboxMessages[index].MessageNo.toString(),
                                timeStamp: DateFormat('dd MMM hh:mm aaa')
                                    .format(inboxMessages[index].MessageDate),
                                recipients: inboxMessages[index].recipients,
                                senderName: inboxMessages[index].SenderName,
                              ),
                            ),
                          );
                        },
                        messageTimestamp: DateFormat('dd-MM-yyyy')
                                    .format(inboxMessages[index].MessageDate) ==
                                DateFormat('dd-MM-yyyy').format(DateTime.now())
                            ? DateFormat('hh:mm a')
                                .format(inboxMessages[index].MessageDate)
                            : DateFormat('dd-MMM')
                                .format(inboxMessages[index].MessageDate),
                        messageTitle: StringHandlers.capitalizeWords(
                            inboxMessages[index].SenderName),
                        messageBody: inboxMessages[index].MessageContent,
                        messageIndex: index,
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


  Widget getOutboxMessages() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchMessages('Outbox').then((result) {
          setState(() {
            outboxMessages = result;
          });
        });
      },
      child: outboxMessages != null && outboxMessages.length != 0
          ? ListView.separated(
              itemCount: outboxMessages.length,
              itemBuilder: (BuildContext context, int index) {
                int time = outboxMessages[index]
                    .MessageDate
                    .difference(DateTime.now())
                    .inHours;
                return FutureBuilder<String>(
                    future: getOutboxImageUrl(outboxMessages[index]),
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      return CustomMessageItem(
                        onMessageItemTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MessageDetailsPage(
                                networkPath: snapshot.data.toString(),
                                message: outboxMessages[index].MessageContent,
                                messageNo:
                                    outboxMessages[index].MessageNo.toString(),
                                timeStamp: DateFormat('dd MMM hh:mm aaa')
                                    .format(outboxMessages[index].MessageDate),
                                recipients: outboxMessages[index].recipients,
                              ),
                            ),
                          );
                        },
                        messageTimestamp: DateFormat('dd-MM-yyyy').format(
                                    outboxMessages[index].MessageDate) ==
                                DateFormat('dd-MM-yyyy').format(DateTime.now())
                            ? DateFormat('hh:mm a')
                                .format(outboxMessages[index].MessageDate)
                            : DateFormat('dd-MMM')
                                .format(outboxMessages[index].MessageDate),
                        messageTitle: StringHandlers.capitalizeWords(
                            outboxMessages[index].StudentNames),
                        messageBody: outboxMessages[index].MessageContent,
                        messageIndex: index,
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

  Future<String> getInboxImageUrl(Message message) {
    return NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
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
  }

  Future<List<Message>> fetchMessages(String messageType) async {
    List<Message> messages;
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
          "EmpNo": user.emp_no.toString(),
          "MessageType": messageType,
          UserFieldNames.yr_no:
              AppData.getCurrentInstance().user.yr_no.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                MessageUrls.GET_TEACHER_MESSAGES,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.INFORMATION,
          );
          messages = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            messages =
                responseData.map((item) => Message.fromMap(item)).toList();
          });
          bool messageOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('message_overlay') ??
              false;
          if (!messageOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("message_overlay", true);
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
        messages = null;
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      messages = null;
    }
    setState(() {
      isLoading = false;
    });

    return messages;
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
          AppTranslations.of(context).text("key_add_message_from_here")),
    );
  }

  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNevigationPage()),
    );
  }
}
