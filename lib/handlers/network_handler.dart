import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/internet_connection.dart';
import 'package:teachers/models/live_server_urls.dart';
import 'package:teachers/models/user.dart';

class NetworkHandler {
  static Uri getUri(String url, Map<String, dynamic> params) {
    try {
      params.addAll({
        "clientCode": AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.client_code.toString()
            : "",
        UserFieldNames.user_no: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.user_no.toString()
            : "",
        UserFieldNames.UserNo: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.user_no.toString()
            : "",
        UserFieldNames.user_id: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.user_id
            : "",
        "UserType": "Management",
        "ApplicationType": "Management",
        "AppVersion": "1",
        "MacAddress": "xxxxxx",
      });

      if(!params.containsKey(UserFieldNames.brcode)) {
        params.addAll({
          UserFieldNames.brcode: AppData
              .getCurrentInstance()
              .user != null
              ? AppData
              .getCurrentInstance()
              .user
              .brcode
              : "",
        });
      }

      Uri uri = Uri.parse(url);
      return uri.replace(queryParameters: params);
    } catch (e) {
      return null;
    }
  }

  static Uri getUri1(String url, Map<String, dynamic> params) {
    try {
      params.addAll({
        UserFieldNames.client_code: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.client_code
            : "",
       // "clientCode": "1001",
        UserFieldNames.brcode: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.brcode
            : "",
        UserFieldNames.UserNo: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.user_no.toString()
            : "",
        UserFieldNames.user_no: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.user_no.toString()
            : "",
        UserFieldNames.user_id: AppData.getCurrentInstance().user != null
            ? AppData.getCurrentInstance().user.user_id
            : "",
        "UserType": "Teacher",
        "ApplicationType": "Teacher",
        "AppVersion": "1",
        "MacAddress": "xxxxxx",
      });
      Uri uri = Uri.parse(url);
      return uri.replace(queryParameters: params);
    } catch (e) {
      return null;
    }
  }

  static Future<String> checkInternetConnection() async {
    String status;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        status = InternetConnection.CONNECTED;
      } else {
        status = InternetConnection.NOT_CONNECTED;
      }
    } catch (e) {
      status = InternetConnection.NOT_CONNECTED;
    }
    return status;
  }

  static Future<String> getServerWorkingUrl() async {
    List<LiveServer> liveServers = [];

    String connectionStatus = await NetworkHandler.checkInternetConnection();
    if (connectionStatus == InternetConnection.CONNECTED) {

      //Code to get live working api url
      Uri getLiveUrlsUri = Uri.parse(
        LiveServerUrls.serviceUrl,
      );

      Response response = await get(getLiveUrlsUri);

      if (response.statusCode == HttpStatusCodes.OK) {
        var data = json.decode(response.body);

        var parsedJson = data["Data"];

        List responseData = parsedJson;
        liveServers =
            responseData.map((item) => LiveServer.fromMap(item)).toList();

        if (liveServers.length != 0 && liveServers.isNotEmpty) {
          for (var server in liveServers) {
            Uri checkUrl = Uri.parse(
              server.ipurl,
            );
            Response checkResponse = await get(checkUrl);
            if (checkResponse.statusCode == HttpStatusCodes.OK) {
             return "http://103.19.18.101:81/";
               //return server.ipurl;
            }
          }
        }
      } else {
        return "key_check_internet";
      }
    } else {
      return "key_check_internet";
    }
  }
}
