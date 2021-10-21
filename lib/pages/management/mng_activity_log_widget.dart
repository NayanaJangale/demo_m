import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/mng_activity_log.dart';

class MngActivityLogWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  MngActivityLogWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngActivityLogWidgetState createState() => _MngActivityLogWidgetState();
}

class _MngActivityLogWidgetState extends State<MngActivityLogWidget> {
  bool isLoading;
  String loadingText;
  bool isLoaded;
  String dateInState;
  List<ActivityLog> _activitylog = [];
  String msgKey;

  @override
  void initState() {
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchActivityLog().then((result) {
      setState(() {
        _activitylog = result;
      });
    });

    msgKey = "key_loading_activity_log";
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchActivityLog().then((result) {
            setState(() {
              _activitylog = result;
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
      fetchActivityLog().then((result) {
        setState(() {
          _activitylog = result;
          dateInState = widget.selected_date;
        });
      });
    }

    return _activitylog != null && _activitylog.length != 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text("key_activity"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      AppTranslations.of(context).text("key_usage"),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        top: 0.0,
                        bottom: 0.0,
                        right: 8.0,
                      ),
                      child: Divider(
                        color: Colors.black12,
                        height: 0.0,
                      ),
                    );
                  },
                  itemCount: _activitylog.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          bottom: 12.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _activitylog[index].activity,
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _activitylog[index].usage.toString(),
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  AppTranslations.of(context).text(msgKey),
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                ),
              );
            },
          );
  }

  Future<List<ActivityLog>> fetchActivityLog() async {
    List<ActivityLog> activityLog = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*  String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchActivityLogUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              ActivityLogUrls.GET_ACTIVITY_LOG,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchActivityLogUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_activity_log_instuction";
          });
        } else {
          List responseData = json.decode(response.body);
          activityLog = responseData
              .map(
                (item) => ActivityLog.fromJson(item),
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

    return activityLog;
  }
}
