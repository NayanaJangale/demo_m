import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/mng_balance_sheet.dart';

class MngBalanceSheetWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  MngBalanceSheetWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngBalanceSheetWidgetState createState() => _MngBalanceSheetWidgetState();
}

class _MngBalanceSheetWidgetState extends State<MngBalanceSheetWidget> {
  bool isLoading;
  String loadingText;
  bool isLoaded;
  String dateInState;
  List<BalanceSheet> _balancesheet = [];
  String msgKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . .';

    msgKey = "key_loading_balance_sheet";

    fetchBalanceSheet().then((result) {
      setState(() {
        _balancesheet = result;
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
          fetchBalanceSheet().then((result) {
            setState(() {
              _balancesheet = result;
            });
          });
        },
        child: getHomeWorkTable(),
      ),
    );
  }

  Widget getHomeWorkTable() {
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
      fetchBalanceSheet().then((result) {
        setState(() {
          _balancesheet = result;
          dateInState = widget.selected_date;
        });
      });
    }

    return _balancesheet != null && _balancesheet.length != 0
        ? ListView(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    headingRowHeight: 40,
                    dataRowHeight: 40,
                    columns: [
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_liablities"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(""),
                      ),
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_assets"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(""),
                      ),
                    ],
                    rows: getDataRow()),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: AppTranslations.of(context)
                      .text("key_balance_sheet_instruction"),
                );
              },
            ),
          );
  }

  List<DataRow> getDataRow() {
    List<DataRow> dataRow = new List();

    bool isFinalRow = false;

    for (int i = 0; i < _balancesheet.length; i++) {
      setState(() {
        isFinalRow = _balancesheet[i].BSNAME_1.contains('TOTAL') ? true : false;
      });

      //if (!(status.getClass_name() + " " + status.getDivision_name()).equals(class_name)) {
      dataRow.add(
        DataRow(
          selected: isFinalRow,
          cells: [
            DataCell(
              Text(
                StringHandlers.capitalizeWords(_balancesheet[i].BSNAME_1),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: isFinalRow
                          ? Theme.of(context).primaryColor
                          : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            DataCell(
              Text(
                StringHandlers.capitalizeWords(
                  _balancesheet[i].LBAL_2.toString(),
                ),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: isFinalRow
                          ? Theme.of(context).primaryColor
                          : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            DataCell(
              Text(
                StringHandlers.capitalizeWords(
                  _balancesheet[i].BSNAME_2.toString(),
                ),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: isFinalRow
                          ? Theme.of(context).primaryColor
                          : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            DataCell(
              Text(
                StringHandlers.capitalizeWords(
                  _balancesheet[i].ABAL_2.toString(),
                ),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: isFinalRow
                          ? Theme.of(context).primaryColor
                          : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return dataRow;
  }

  Future<List<BalanceSheet>> fetchBalanceSheet() async {
    List<BalanceSheet> balaceSheet = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchBalanceSheetUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              BalanceSheetUrls.GET_BALANCE_SHEET,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
          },
        );

        Response response = await get(fetchBalanceSheetUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_balance_sheet_instruction";
          });
        } else {
          List responseData = json.decode(response.body);
          balaceSheet = responseData
              .map(
                (item) => BalanceSheet.fromJson(item),
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

    return balaceSheet;
  }
}
