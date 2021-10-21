import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_circular_management_item.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/circular.dart';
import 'package:teachers/models/user.dart';

class MngInternalCircularPage extends StatefulWidget {
  String brcode;

  MngInternalCircularPage({this.brcode});

  @override
  _MngInternalCircularPageState createState() =>
      _MngInternalCircularPageState();
}

class _MngInternalCircularPageState extends State<MngInternalCircularPage> {
  bool isLoading;
  String loadingText;
  List<Circular> _circulars = [];
  String msgKey;
  int index;
  GlobalKey<ScaffoldState> _circularPageGK;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_circulars";

    _circularPageGK = GlobalKey<ScaffoldState>();

    fetchCirculars(widget.brcode).then((result) {
      setState(() {
        _circulars = result;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchCirculars(widget.brcode).then((result) {
            setState(() {
              _circulars = result;
            });
          });
        },
        child: dataBody(),
      ),
    );
  }

  Widget dataBody() {
    return _circulars != null && _circulars.length != 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                itemCount: _circulars.length,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder<String>(
                      future: getImageUrl(_circulars[index]),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        return CustomCircularManagementItem(
                          title: _circulars[index].circular_title,
                          description: _circulars[index].circular_desc,
                          circularDate: DateFormat('dd MMM hh:mm aaa')
                              .format(_circulars[index].circular_date),
                          networkPath: snapshot.data.toString(),
                          circularFrom: _circulars[index].emp_name,
                          onItemTap: () {},
                          periods: _circulars[index].periods,
                          circular: _circulars[index],
                        );
                      });
                },
              )),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: AppTranslations.of(context)
                      .text("key_circulars_not_available"),
                );
              },
            ),
          );
  }

  Future<String> getImageUrl(Circular cirular) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return Uri.parse(connectionServerMsg +
                  ProjectSettings.rootUrl +
                  CircularUrls.GET_CIRCULAR_IMAGE)
              .replace(queryParameters: {
            "circular_no": cirular.circular_no.toString(),
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          }).toString();
        }
      });

  Future<List<Circular>> fetchCirculars(String brcode) async {
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
              CircularUrls.GET_MANAGEMENT_CIRCULARS,
          {
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.brcode: brcode
          },
        );

        http.Response response = await http.get(fetchCircularsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
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
          bool circularOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('circular_overlay') ??
              false;
          if (!circularOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("circular_overlay", true);
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

    return circulars;
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_add_circular_from_here")),
    );
  }
}
