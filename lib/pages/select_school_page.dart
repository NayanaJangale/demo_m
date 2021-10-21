import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_list_divider.dart';
import 'package:teachers/components/custom_list_item.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/list_filter_bar.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/school.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/management/bottom_nevigation_page.dart';
import 'package:teachers/themes/colors_old.dart';

import '../app_data.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';

class SelectSchoolPage extends StatefulWidget {
  final String userId, password, select_school_for;
  String clientCode;
  String clientName;
  bool isSelected;

  SelectSchoolPage({this.userId, this.password, this.select_school_for,this.isSelected});

  @override
  _SelectSchoolPageState createState() => _SelectSchoolPageState();
}

class _SelectSchoolPageState extends State<SelectSchoolPage> {
  bool isLoading = true;
  TextEditingController filterController;
  List<School> schools = List<School>();
  List<School> filteredList;
  String filter, loadingText;
  DBHandler _dbHandler;

  @override
  void initState() {
    super.initState();
    loadingText = 'Loading . . .';

    _dbHandler = DBHandler();
    fetchSchools().then((result) {
      schools = result;
    });

    filterController = new TextEditingController();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    filteredList = schools.where((item) {
      if (filter == null || filter == '')
        return true;
      else {
        return item.clientName.toLowerCase().contains(filter.toLowerCase());
      }
    }).toList();

    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeColors.primary,
          elevation: 0.0,
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_school"),
            subtitle: AppTranslations.of(context).text("key_school_subtitle"),

          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchSchools().then((result) {
              schools = result;
            });
          },
          child: schools != null && schools.length > 0
              ? Column(
                  children: <Widget>[
                    ListFilterBar(
                      searchFieldController: filterController,
                      onCloseButtonTap: () {
                        setState(() {
                          filterController.text = '';
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CustomListItem(
                            onItemTap: () {
                              widget.clientCode = filteredList[index].clientCode.toString();
                              widget.clientName = filteredList[index].clientName.toString();

                              if (widget.select_school_for == 'Login')
                                _login();
                              else
                                _forgetPassword();
                            },
                            itemText: StringHandlers.capitalizeWords(
                                filteredList[index].clientName),
                            itemIndex: index,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return CustomListSeparator();
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
                        AppTranslations.of(context).text("key_load_school"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                      ),
                    );
                  },
                ),
        ), //ModalProgressHUD(child: _createBody(), inAsyncCall: isLoading), //
        backgroundColor: Colors.white,
      ),
    );
  }

  void _forgetPassword() {
    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPassword(
          clientCode: widget.clientCode,
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      loadingText = 'Validating Online . . .';
    });

    try {
      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri getEmployeeDetailsUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.GET_EMPLOYEE_DETAILS,
        ).replace(
          queryParameters: {
            'userID': widget.userId,
            'userPassword': widget.password,
            'clientCode': widget.clientCode,
          },
        );

        http.Response response = await http.get(getEmployeeDetailsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
              context, null, response.body, MessageTypes.WARNING);
        } else {
          var data = json.decode(response.body);
          User user = User.fromJson(data);
          if (user == null) {
            FlushbarMessage.show(
              context,
              null,
              AppTranslations.of(context).text("key_invalid_user_id_password"),
              MessageTypes.ERROR,
            );
          } else {
            user.clientName = widget.clientName.toString();
            user.client_code = widget.clientCode.toString();
            int rememberMe =  widget.isSelected ? 1 : 0;
            setState(() {
              user.remember_me = rememberMe;
            });
            user = await _dbHandler.saveUser(user);
            if (user != null) {
              user = await _dbHandler.login(user);
              AppData.getCurrentInstance().user = await _dbHandler.login(user);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BottomNevigationPage(),
                  // builder: (_) => SubjectsPage(),
                ),
              );
            } else {
              FlushbarMessage.show(
                context,
                null,
                AppTranslations.of(context).text("key_unable_to_perform_local_login"),
                MessageTypes.ERROR,
              );
            }
          }
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.INFORMATION,
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
  }

  //Method to get schools list from api
  Future<List<School>> fetchSchools() async {
    List<School> schools = [];
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Loading . . .';
      });

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchSchoolsUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              SchoolUrls.GET_SCHOOLS,
        ).replace(
          queryParameters: {
            'ApplicationType': 'Teacher',
          },
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
              context, null, response.body, MessageTypes.WARNING);
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            schools = responseData
                .map(
                  (item) => School.fromJson(item),
                )
                .toList();
          });
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.INFORMATION,
        );
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_school_instuction") +
            e.toString(),
        MessageTypes.INFORMATION,
      );
    }
    setState(() {
      isLoading = false;
    });

    return schools;
  }
}
