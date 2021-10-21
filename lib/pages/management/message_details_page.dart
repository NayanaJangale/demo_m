import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_message_bar.dart';
import 'package:teachers/components/custom_message_comment_item.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/message.dart';
import 'package:teachers/models/message_comment.dart';
import 'package:teachers/models/recipient.dart';
import 'package:teachers/models/user.dart';

class MessageDetailsPage extends StatefulWidget {
  String networkPath, message, messageNo, timeStamp, senderName;
  List<Recipient> recipients;

  MessageDetailsPage({
    this.senderName,
    this.networkPath,
    this.message,
    this.messageNo,
    this.timeStamp,
    this.recipients,
  });

  @override
  _MessageDetailsPageState createState() => _MessageDetailsPageState();
}

class _MessageDetailsPageState extends State<MessageDetailsPage> {
  GlobalKey<ScaffoldState> _messageDetailsPageGlobalKey;
  List<MessageComment> _comments = [];
  TextEditingController messageController;

  bool isLoading;
  String loadingText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _messageDetailsPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    this.messageController = TextEditingController();

    fetchComments().then((result) {
      setState(() {
        _comments = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");

    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _messageDetailsPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: widget.senderName != null && widget.senderName != ''
                ? widget.senderName
                : AppTranslations.of(context).text("key_messages"),
            subtitle: widget.timeStamp,
          ),
        ),
        backgroundColor: Colors.grey[200],
        body: RefreshIndicator(
          onRefresh: () async {
            fetchComments().then((result) {
              setState(() {
                this._comments = result;
              });
            });
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: widget.networkPath,
                          imageBuilder: (context, imageProvider) => Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: 8.0,
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                widget.networkPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              top: 4,
                            ),
                            child: LinearProgressIndicator(
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Wrap(
                            spacing: 3.0, // gap between adjacent chips,
                            runSpacing: 0.0,
                            children: List<Widget>.generate(
                              widget.recipients.length,
                              (i) => Chip(
                                backgroundColor: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(3),
                                    bottomRight: Radius.circular(3),
                                    topLeft: Radius.circular(3),
                                    bottomLeft: Radius.circular(3),
                                  ),
                                ),
                                avatar: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: 12,
                                  height: 12,
                                ),
                                label: Text(
                                  StringHandlers.capitalizeWords(
                                      widget.recipients[i].recipientName),
                                ),
                                labelStyle:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Text(
                            widget.message,
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        _comments.length > 0
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  top: 8.0,
                                ),
                                child: Divider(
                                  height: 0.0,
                                ),
                              )
                            : Container(),
                        ListView.separated(
                          primary: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: new EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            bottom: 4.0,
                            top: 4.0,
                          ),
                          itemCount: _comments.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CustomMessageCommentItem(
                              sender: _comments[index].ReplyFrom,
                              comment: _comments[index].Comment,
                              timestamp: DateFormat('dd MMM hh:mm aaa')
                                  .format(_comments[index].ReplySentOn),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4.0,
                                top: 4.0,
                              ),
                              child: Divider(
                                height: 0.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomMessageBar(
                isMediaOptionRequired: false,
                messageFieldController: this.messageController,
                msgHint: AppTranslations.of(context).text("key_type_message"),
                onSendButtonPressed: () {
                  if (this.messageController.text != '') {
                    MessageComment comment = MessageComment();
                    comment.MessageNo = int.parse(widget.messageNo);
                    comment.Comment = messageController.text;
                    comment.ReplyFrom = "Teacher";
                    comment.FromEmpNo =
                        AppData.getCurrentInstance().user.emp_no;
                    comment.FromStudentNo = 0;
                    postTeacherComment(comment);
                  } else {
                    FlushbarMessage.show(
                      context,
                      null,
                      AppTranslations.of(context).text("key_enter_message"),
                      MessageTypes.INFORMATION,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getInboxImageUrl() =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return widget.networkPath;
        }
      });

  Future<List<MessageComment>> fetchComments() async {
    List<MessageComment> comments = [];

    try {
      setState(() {
        isLoading = true;
      });

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchCircularsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              MessageUrls.GET_MESSAGE_COMMENTS,
          {
            MessageFieldNames.MessageNo: widget.messageNo,
          },
        );

        http.Response response = await http.get(fetchCircularsUri);
        if (response.statusCode == HttpStatusCodes.OK) {
          List responseData = json.decode(response.body);
          comments = responseData
              .map(
                (item) => MessageComment.fromJson(item),
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

    return comments;
  }

  Future<void> postTeacherComment(MessageComment comment) async {
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
          "user_id": user != null ? user.user_id : "",
        };

        Uri saveMessageCommentsUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                MessageUrls.POST_MESSAGE_COMMENTS,
            params);

        http.Response response = await http.post(
          saveMessageCommentsUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: json.encode(comment),
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          FlushbarMessage.show(
            context,
            null,
            AppTranslations.of(context).text("key_message_sent"),
            MessageTypes.INFORMATION,
          );

          _clearData();
          fetchComments().then((result) {
            setState(() {
              _comments = result;
            });
          });
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.INFORMATION,
          );

          setState(() {
            isLoading = false;
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
          isLoading = false;
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
        isLoading = false;
      });
    }
  }

  void _clearData() {
    this.messageController.text = '';
  }
}
