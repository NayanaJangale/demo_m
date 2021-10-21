import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_text_box.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_request_methods.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/album.dart';
import 'package:teachers/models/divison.dart';
import 'package:teachers/models/school_section.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/management/albums_page.dart';
import 'package:teachers/pages/management/mng_branchwise_album.dart';
import 'package:teachers/themes/colors.dart';
import 'package:teachers/themes/theme_constants.dart';

class AddAlbumPage extends StatefulWidget {
  String brcode;

  AddAlbumPage({this.brcode});

  @override
  _AddAlbumPageState createState() => _AddAlbumPageState();
}

class _AddAlbumPageState extends State<AddAlbumPage> {
  GlobalKey<ScaffoldState> _addAlbumPageGK;
  bool isLoading;
  String loadingText;
  TextEditingController titleController;
  List<Asset> images = [] ;
  SchoolSection selectedSection;
  TeacherClass fromClass, toClass;
  List<TeacherClass> classes = [];
  List<SchoolSection> sections = [];
  List<Division> divisions = [];
  Division selectedDivision;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _addAlbumPageGK = GlobalKey<ScaffoldState>();
    titleController = TextEditingController();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    this.selectedDivision = Division(division_id: 0, division_name: "All");
    fetchSectionwiseClasses(1).then((result) {
      setState(() {
        this.classes = result;
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
        key: _addAlbumPageGK,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_add_album"),
            subtitle: selectedSection == null
                ? AppTranslations.of(context).text("key_select_section")
                : selectedSection.section_name,
          ),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                if (sections != null && sections.length > 0) {
                  showSections();
                } else {
                  fetchSections().then((result) {
                    setState(() {
                      sections = result;
                      sections.insert(0, new SchoolSection(section_id:  0, section_name:  "All"));
                    });

                    if (sections != null && sections.length > 0)
                    showSections();
                  });
                }
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                ),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (classes != null && classes.length > 0) {
                          showClasses('From');
                        } else {
                          fetchSectionwiseClasses(selectedSection.section_id)
                              .then((result) {
                            setState(() {
                              classes = result;
                            });

                            if (classes != null && classes.length > 0)
                              showClasses('From');
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text("key_from_class"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  fromClass == null
                                      ? AppTranslations.of(context)
                                          .text("key_select_from_class")
                                      : fromClass.class_name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (classes != null && classes.length > 0) {
                          showClasses('To');
                        } else {
                          fetchSectionwiseClasses(selectedSection.section_id)
                              .then((result) {
                            setState(() {
                              classes = result;
                            });

                            if (classes != null && classes.length > 0)
                              showClasses('To');
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text("key_to_class"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  toClass == null
                                      ? AppTranslations.of(context)
                                          .text("key_select_to_class")
                                      : toClass.class_name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        showDivisions();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text("key_division"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                  color:
                                  Theme.of(context).primaryColorLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  selectedDivision.division_name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign:  TextAlign.end,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: CustomTextBox(
                        inputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {},
                        labelText:
                            AppTranslations.of(context).text("key_album_title"),
                        controller: titleController,
                        icon: Icons.title,
                        keyboardType: TextInputType.text,
                        colour: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: Container(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            loadAssets();
                          },
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15.0,
                                  top: 15.0,
                                  right: 15.0,
                                  bottom: 15.0,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                AppTranslations.of(context)
                                    .text("key_add_change_photos"),
                                style:
                                    Theme.of(context).textTheme.bodyText1.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).primaryColor,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 0.0,
                        bottom: 0.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: Divider(
                        color: Colors.black54,
                        height: 0.0,
                      ),
                    ),
                    buildGridView(),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                String valMsg = getValidationMessage();
                if (valMsg != '') {
                  FlushbarMessage.show(
                    context,
                    null,
                    valMsg,
                    MessageTypes.ERROR,
                  );
                } else {
                  postAlbum();
                }
              },
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_post_album"),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        children: List.generate(
          images.length,
          (index) => AssetThumb(
            asset: images[index],
            width: 300,
            height: 300,
            quality: 100,
            spinner: Padding(
              padding: const EdgeInsets.all(18.0),
              child: LiquidCircularProgressIndicator(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                direction: Axis.horizontal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = AppTranslations.of(context).text("key_no_error_found");

    String theme = AppData.getCurrentInstance().preferences.getString('theme');
    String actionBarColor, selectCircleStrokeColor, statusBarColor;

    switch (theme) {
      case ThemeNames.Purple:
        setState(() {
          actionBarColor = PurpleThemeColorStrings.primary;
          selectCircleStrokeColor = PurpleThemeColorStrings.primaryExtraLight1;
          statusBarColor = PurpleThemeColorStrings.primary;
        });
        break;
      case ThemeNames.Blue:
        setState(() {
          actionBarColor = BlueThemeColorStrings.primary;
          selectCircleStrokeColor = BlueThemeColorStrings.primaryExtraLight1;
          statusBarColor = BlueThemeColorStrings.primary;
        });
        break;
      case ThemeNames.Teal:
        setState(() {
          actionBarColor = TealThemeColorStrings.primary;
          selectCircleStrokeColor = TealThemeColorStrings.primaryExtraLight1;
          statusBarColor = TealThemeColorStrings.primary;
        });
        break;
      case ThemeNames.Amber:
        setState(() {
          actionBarColor = AmberThemeColorStrings.primary;
          selectCircleStrokeColor = AmberThemeColorStrings.primaryExtraLight1;
          statusBarColor = AmberThemeColorStrings.primary;
        });
        break;
    }

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: actionBarColor,
          //  actionBarColor: Theme.of(context).primaryColor.toString(),
          actionBarTitle: AppTranslations.of(context).text("key_pick_image"),
          allViewTitle: AppTranslations.of(context).text("key_all_photos"),
          useDetailsView: false,
          selectCircleStrokeColor: selectCircleStrokeColor,
          //   selectCircleStrokeColor:
          //    Theme.of(context).primaryColorLight.toString(),
          //statusBarColor: Theme.of(context).primaryColor.toString(),
          statusBarColor: statusBarColor,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      FlushbarMessage.show(
        context,
        null,
        error,
        MessageTypes.ERROR,
      );
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  String getValidationMessage() {
    if (titleController.text == '') {
      return AppTranslations.of(context).text("key_enter_album_title");
    }

    if (images.length == 0) {
      return AppTranslations.of(context).text("key_add_one_or_more_image");
    }

    return "";
  }

  Future<void> postAlbum() async {
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          "user_id": user != null ? user.user_id : "",
          "album_desc": titleController.text,
          "section_id": selectedSection.section_id.toString(),
          "class_id": fromClass.class_id.toString(),
          "classid_upto": toClass.class_id.toString(),
          "division_id": selectedDivision.division_id.toString(),
          "brcode":widget.brcode
        };

        Uri saveAlbumUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AlbumUrls.ADD_NEW_ALBUM,
            params);

        http.Response response = await http.post(
          saveAlbumUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: '',
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          // post Album Photos
          if (images != null && images.length > 0) {
            await postAlbumImage(int.parse(response.body.toString()));
          }

          setState(() {
            titleController.text = '';
            images = [];
            fromClass =
                classes != null && classes.length > 0 ? classes[0] : null;
            toClass = classes != null && classes.length > 0 ? classes[0] : null;
          });
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.INFORMATION,
          );
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
  }

  Future<void> postAlbumImage(int album_id) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Gallery/PostAlbumPhoto',
      ).replace(
        queryParameters: {
          'brcode': AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          'album_id': album_id.toString(),
          'user_no': AppData.getCurrentInstance().user.user_no.toString(),
        },
      );

      int i = 0;
      for (; i < images.length; i++) {
        setState(() {
          loadingText = 'Uploading ${i + 1} of ${images.length} image(s).';
        });

        final imageUploadRequest =
            http.MultipartRequest(HttpRequestMethods.POST, postUri);

        ByteData data = await images[i].getByteData(quality: 60);
        final file = await http.MultipartFile.fromBytes(
          'image',
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          filename: 'Photo_$i.jpg',
          contentType: MediaType(
            'image',
            'jpeg',
          ),
        );

        imageUploadRequest.fields['ext'] = 'jpeg';
        imageUploadRequest.files.add(file);

        final streamedResponse = await imageUploadRequest.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode != HttpStatusCodes.CREATED) {
          break;
        }
      }

      if (i == images.length) {
        FlushbarMessage.show(
          context,
          null,
          'Album successfully saved.',
          MessageTypes.INFORMATION,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MngBrancwiseAlbum()),
        );
      } else {
        FlushbarMessage.show(
          context,
          null,
          'Album saving failed.',
          MessageTypes.WARNING,
        );
      }
    } else {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_no_internet"),
        AppTranslations.of(context).text("key_check_internet"),
        MessageTypes.WARNING,
      );
    }
  }

  Future<List<SchoolSection>> fetchSections() async {
    List<TeacherClass> classes = [];
    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no: user != null ? user.emp_no.toString() : "",
          "brcode": widget.brcode

        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                SchoolSectionUrls.GET_SCHOOL_SECTIONS,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            sections = responseData
                .map((item) => SchoolSection.fromJson(item))
                .toList();
          });
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

    return sections;
  }

  Future<List<TeacherClass>> fetchSectionwiseClasses(int section_id) async {
    List<TeacherClass> classes = [];
    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no: user != null ? user.emp_no.toString() : "",
          "section_id": section_id.toString(),
          "brcode":widget.brcode
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                TeacherClassUrls.GET_SECTION_CLASSES,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            classes = responseData
                .map((item) => TeacherClass.fromJson(item))
                .toList();
          });
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

    return classes;
  }

  void showClasses(String selectClassFor) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: selectClassFor == 'From'
              ? AppTranslations.of(context).text("key_select_from_class")
              : AppTranslations.of(context).text("key_select_to_class"),
        ),
        actions: List<Widget>.generate(
          classes.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: classes[i].class_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                if (selectClassFor == 'From') {
                  setState(() {
                    fromClass = classes[i];
                  });
                } else {
                  setState(() {
                    toClass = classes[i];
                    if(fromClass.class_id ==toClass.class_id){
                      fetchDivision(fromClass.class_id).then((result) {
                        setState(() {
                          divisions.clear();
                          divisions = result;
                          divisions.insert(0,
                              new Division(division_id: 0, division_name: "All"));
                        });
                      });
                    }
                  });
                }
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void showSections() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_school_section"),
        ),
        actions: List<Widget>.generate(
          sections.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: sections[i].section_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                setState(() {
                  selectedSection = sections[i];
                });
              });
              if(selectedSection.section_id == 0){
                classes.clear();
                divisions.clear();
                classes.add(TeacherClass(class_id: 0, class_name: "All"));
                divisions.add(Division(division_id: 0, division_name: "All"));
                this.selectedDivision = Division(division_id: 0, division_name: "All");
                this.toClass = TeacherClass(class_id: 0, class_name: "All");
                this.fromClass = TeacherClass(class_id: 0, class_name: "All");
              }else{
                fetchSectionwiseClasses(selectedSection.section_id)
                    .then((result) {
                  setState(() {
                    classes = result;
                    if (classes != null && classes.length > 0) {
                      fromClass = classes[0];
                      toClass = classes[0];
                      classes.insert(
                          0, new TeacherClass(class_id: 0, class_name: "All"));
                      if (classes!= null && classes.length > 0 ){
                        fetchDivision(0).then((result) {
                          setState(() {
                            divisions.clear();
                            divisions = result;
                            divisions.insert(0,
                                new Division(division_id: 0, division_name: "All"));
                          });
                        });
                      }
                    } else {
                      //generateEmptyClasses();
                    }
                  });
                });
              }
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void showDivisions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
            message: AppTranslations.of(context).text("key_division")),
        actions: List<Widget>.generate(
          divisions.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: divisions[i].division_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                setState(() {
                  selectedDivision = divisions[i];
                });
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  Future<List<Division>> fetchDivision(int class_id) async {
    List<Division> divisions = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "class_id" : class_id.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                DivisionUrls.GET_BRANCHWISEDIVISIONS,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            divisions =
                responseData.map((item) => Division.fromJson(item)).toList();
          });
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
    return divisions;
  }

}
