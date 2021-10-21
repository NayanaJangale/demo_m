import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_tab_view.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/branch.dart';
import 'package:teachers/models/mng_daily_subsidiary.dart';

class MngBalancesWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  MngBalancesWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngBalancesWidgetState createState() => _MngBalancesWidgetState();
}

class _MngBalancesWidgetState extends State<MngBalancesWidget> {
  bool isLoading;
  String loadingText;
  bool isLoaded;
  String dateInState;
  List<DailySubsidiary> _dailySubsidiary = [];
  List<Branch> branches = [];
  String msgKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_balances";

    fetchBalances().then((result) {
      setState(() {
        _dailySubsidiary = result;
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
        length: branches.length == 0 ? 1 : branches.length,
        child: CustomTabBarView(
          List<Widget>.generate(
            branches.length == 0 ? 1 : branches.length,
            (i) => RefreshIndicator(
                onRefresh: () async {
                  fetchBalances().then((result) {
                    setState(() {
                      _dailySubsidiary = result;
                    });
                  });
                },
                child: getBalanceTable()),
          ),
        ),
      ),
    );
  }

  Widget getBalanceTable() {
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
      fetchBalances().then((result) {
        setState(() {
          _dailySubsidiary = result;
          dateInState = widget.selected_date;
        });
      });
    }
    return _dailySubsidiary != null && _dailySubsidiary.length != 0
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
                        AppTranslations.of(context).text("key_credit"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_debit"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        "",
                      ),
                      numeric: true,
                    ),
                  ],
                  rows: getDataRow(),
                ),
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
                      .text("key_balance_instruction"),
                );
              },
            ),
          );
  }

  List<DataRow> getDataRow() {
    List<DataRow> dataRow = new List();

    dataRow.add(
      DataRow(
        cells: [
          DataCell(
            Text(
              AppTranslations.of(context).text("key_scroll"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_account"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_cash"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_transfer"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_total"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_scroll"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_account"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_cash"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_transfer"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          DataCell(
            Text(
              AppTranslations.of(context).text("key_total"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );

    List.generate(
      _dailySubsidiary.length,
      (index) {
        {
          bool isTotalRow = false;

          if (_dailySubsidiary[index].CreditHeader.contains('TOTAL') ||
              _dailySubsidiary[index].DebitHeader.contains('TOTAL')) {
            setState(() {
              isTotalRow = true;
            });
          } else {
            setState(() {
              isTotalRow = false;
            });
          }
          dataRow.add(
            DataRow(
              selected: isTotalRow,
              cells: [
                DataCell(
                  Text(
                    _dailySubsidiary[index].CreditScrollNo.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].CreditHeader.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].CashCredit.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].TransferCredit.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].TotalCredit.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].DebitScrollNo.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].DebitHeader.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].CashDebit.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].TransferDebit.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataCell(
                  Text(
                    _dailySubsidiary[index].TotalDebit.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );

    return dataRow;
  }

  Future<List<DailySubsidiary>> fetchBalances() async {
    List<DailySubsidiary> balances = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchBalancesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              BalanceUrls.GET_BALANCES,
          {
            "report_date": widget.selected_date,
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchBalancesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_balance_instruction";
          });
        } else {
          List responseData = json.decode(response.body);
          balances = responseData
              .map(
                (item) => DailySubsidiary.fromJson(item),
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

    return balances;
  }
}
