import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_tab_view.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/menu_constants.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/branch.dart';
import 'package:teachers/pages/management/add_newsletter_page.dart';
import 'package:teachers/pages/management/newsletter_page.dart';

class MngBrancwiseNewsfeed extends StatefulWidget {
  String menuName;

  MngBrancwiseNewsfeed({
    this.menuName,
  });

  @override
  _MngBrancwiseNewsfeedState createState() => _MngBrancwiseNewsfeedState();
}

class _MngBrancwiseNewsfeedState extends State<MngBrancwiseNewsfeed> with SingleTickerProviderStateMixin{
  bool isLoading;
  String loadingText;
  GlobalKey<ScaffoldState> _branchwiseReportPageGK;
  DateTime reportDate;
  int flag = 0;
  List<Branch> _branches = [];
  TabController tabController;
  Uri uri;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
      if (connectionServerMsg != "key_check_internet") {
        setState(() {
          uri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Users/GetClientPhoto',
          ).replace(queryParameters: {
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          });
        });
      }
    });
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    this.reportDate = DateTime.now();
    _branchwiseReportPageGK = GlobalKey<ScaffoldState>();

    fetchBranches().then((result) {
      setState(() {
        this._branches = result;
       tabController = TabController(length: _branches.length, vsync: this);
        flag = 1;
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
        length: _branches.length,
        child: Scaffold(
          key: _branchwiseReportPageGK,
          backgroundColor: Colors.white,
          appBar: AppBar(
              leading: Row(
                children: <Widget>[
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 50,
                    height: 40,
                    child: Image.network(
                      uri == null ? "" : uri.toString(),
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            title: CustomAppBar(
              title: AppTranslations.of(context).text("key_hi") +
                  ' ' +
                  StringHandlers.capitalizeWords(
                      AppData.getCurrentInstance().user.emp_name),
              subtitle: AppTranslations.of(context).text("key_welcometo")+ " " + AppData.getCurrentInstance().user.clientName ?? "",
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddNewslwtterPage(brcode: _branches[tabController.index].brcode),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              isScrollable: true,
              indicatorColor: Theme.of(context).secondaryHeaderColor,
              tabs: List<Widget>.generate(
                _branches.length,
                    (i) => Tab(
                  text: _branches[i].brname,
                ),
              ),
            ),
            elevation: 0,
          ),
          body: TabBarView(
            children:List<Widget>.generate(
              _branches.length,
                  (i) => selectPage(widget.menuName, _branches[i].brcode),
            ),
          ),
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

    return branches;
  }

  Widget selectPage(String menuName, String sbrcode) {
    return NewsletterPage(
      brcode : sbrcode,
    );
  }
}
