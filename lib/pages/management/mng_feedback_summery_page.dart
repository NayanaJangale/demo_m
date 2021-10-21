import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_feedback_item.dart';
import 'package:teachers/components/custom_list_divider.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/feedback_query.dart';
import 'package:teachers/models/user.dart';

class MngFeedbackSummaryPage extends StatefulWidget {
  String stud_no;

  MngFeedbackSummaryPage({this.stud_no});

  @override
  _MngFeedbackSummaryPage createState() => _MngFeedbackSummaryPage();
}

class _MngFeedbackSummaryPage extends State<MngFeedbackSummaryPage> {
  GlobalKey<ScaffoldState> _addFeedbackSummaryPageGlobalKey;
  bool isLoading;
  String loadingText;
  List<FeedbackQuery> _feedbackQuery = [];
  String msgKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_feedback";
    _addFeedbackSummaryPageGlobalKey = GlobalKey<ScaffoldState>();
    fetchFeedbackSummary().then((result) {
      setState(() {
        _feedbackQuery = result;
      });
    });
  }

  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addFeedbackSummaryPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_feedback_summery_for"),
            subtitle: '',
          ),
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchFeedbackSummary().then((result) {
              setState(() {
                _feedbackQuery = result;
              });
            });
          },
          child: Column(
            children: <Widget>[
              Expanded(
                  child: _feedbackQuery != null && _feedbackQuery.length != 0
                      ? ListView.separated(
                          itemCount: _feedbackQuery.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CustomFeedbackItem(
                              query: StringHandlers.capitalizeWords(
                                  _feedbackQuery[index].Query),
                              option: _feedbackQuery[index].OptionDesc,
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
                                    .text("key_feedback_summery_not_available"),
                              );
                            },
                          ),
                        )),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<FeedbackQuery>> fetchFeedbackSummary() async {
    List<FeedbackQuery> feedbackQuery = [];

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
              FeedbackQueryUrls.GET_FEEDBACK_SUMMARY,
          {
            UserFieldNames.emp_no: widget.stud_no.toString(),
            "yr_no": AppData.getCurrentInstance().user.yr_no.toString(),
            "stud_no": widget.stud_no.toString()
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
            msgKey = "key_feedback_summery_not_available";
          });
        } else {
          List responseData = json.decode(response.body);
          feedbackQuery = responseData
              .map(
                (item) => FeedbackQuery.fromJson(item),
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

    return feedbackQuery;
  }
}
