import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
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
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/newsletter.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/management/bottom_nevigation_page.dart';
import 'package:teachers/pages/management/newsletter_page.dart';

class AddNewslwtterPage extends StatefulWidget {
  String brcode;

  AddNewslwtterPage({this.brcode});

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController videoController = TextEditingController();

  @override
  _AddNewslwtterPage createState() => _AddNewslwtterPage();
}

class _AddNewslwtterPage extends State<AddNewslwtterPage> {
  GlobalKey<ScaffoldState> _addNewsletterPageGlobalKey;
  DateTime _selectedDate = DateTime.now();
  bool isLoading;
  String loadingText;
  List<String> menus = ['Camera', 'Gallery'];
  List<String> newsType = ['Image', 'Video'];
  FocusNode titleFocusNode, descriptionFocusNode,videoFocusNode;
  String selectedItem = 'Image';
  File imgFile;
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            disabledColor: Colors.orange,
            accentColor: Theme.of(context).primaryColor,
            dialogBackgroundColor: Colors.grey[200],
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _addNewsletterPageGlobalKey = GlobalKey<ScaffoldState>();

    titleFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();
    videoFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
  //  selectedItem = AppTranslations.of(context).text("key_Image");
    return WillPopScope(
      onWillPop:_onBackPressed ,
      child: CustomProgressHandler(
        isLoading: this.isLoading,
        loadingText: this.loadingText,
        child: Scaffold(
          key: _addNewsletterPageGlobalKey,
          appBar: AppBar(
            title: CustomAppBar(
              title: AppTranslations.of(context).text("key_add_Newsfeed"),
              subtitle:
              AppTranslations.of(context).text("key_add_newsfeed_subtitle"),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  _showNewstype();
                },
              ),
            ],
            elevation: 0,
          ),
          body: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    bottom: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).secondaryHeaderColor,
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
                                AppTranslations.of(context).text("key_date"),
                                style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Theme.of(context)
                                      .secondaryHeaderColor,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: Text(
                                    DateFormat('dd-MMM-yyyy')
                                        .format(_selectedDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  child: Icon(
                                    Icons.date_range,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
                          top: 8.0,
                        ),
                        child: CustomTextBox(
                          inputAction: TextInputAction.next,
                          focusNode: titleFocusNode,
                          onFieldSubmitted: (value) {
                            this.titleFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(this.descriptionFocusNode);
                          },
                          labelText: StringHandlers.capitalizeWords(
                            AppTranslations.of(context).text("key_title"),
                          ),
                          controller: widget.titleController,
                          icon: Icons.title,
                          keyboardType: TextInputType.text,
                          colour: Theme.of(context).primaryColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: CustomTextBox(
                          inputAction: TextInputAction.done,
                          focusNode: descriptionFocusNode,
                          onFieldSubmitted: (value) {
                            this.descriptionFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(this.videoFocusNode);
                          },
                          labelText: StringHandlers.capitalizeWords(
                            AppTranslations.of(context).text("key_description"),
                          ),
                          controller: widget.descriptionController,
                          icon: Icons.description,
                          keyboardType: TextInputType.text,
                          colour: Theme.of(context).primaryColor,
                        ),
                      ),
                      selectedItem == 'Image'
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: imgFile == null
                              ? Container(
                            color: Theme.of(context)
                                .secondaryHeaderColor,
                            child: Center(
                              child: Text(
                                AppTranslations.of(context)
                                    .text("key_image"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                  color: Theme.of(context)
                                      .primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                              : Image.file(
                            imgFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : Container(),
                      selectedItem == 'Image'
                          ? Padding(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          bottom: 0.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Divider(
                          height: 0.0,
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: CustomTextBox(
                          inputAction: TextInputAction.done,
                          focusNode: videoFocusNode,
                          onFieldSubmitted: (value) {
                            this.videoFocusNode.unfocus();
                          },
                          labelText: StringHandlers.capitalizeWords(
                            AppTranslations.of(context).text("key_enter_video_url"),
                          ),
                          controller: widget.videoController,
                          icon: Icons.video_library,
                          keyboardType: TextInputType.text,
                          colour: Theme.of(context).primaryColor,
                        ),
                      ),
                      selectedItem == 'Image'
                          ? Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Container(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: menus[index] == 'Camera'
                                    ? Icon(
                                  Icons.camera_alt,
                                  color:
                                  Theme.of(context).primaryColor,
                                )
                                    : Icon(
                                  Icons.photo,
                                  color:
                                  Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  menus[index] == 'Camera'
                                      ? AppTranslations.of(context)
                                      .text("key_camera")
                                      : AppTranslations.of(context)
                                      .text("key_gallery"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                    color:
                                    Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  if (menus[index] == 'Camera') {
                                    _pickImage(ImageSource.camera)
                                        .then((result) {});
                                  } else {
                                    _pickImage(ImageSource.gallery)
                                        .then((result) {});
                                  }
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(
                                  0.0,
                                ),
                                child: Divider(
                                  height: 0.0,
                                ),
                              );
                            },
                            itemCount: menus.length,
                          ),
                        ),
                      )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          bottom: 0.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Divider(
                          height: 0.0,
                        ),
                      ),
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
                      MessageTypes.INFORMATION,
                    );
                  } else {
                    postNewsfeed();
                  }
                },
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        AppTranslations.of(context).text("key_post_Newsfeed"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewstype() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_newsfeed_type"),
        ),
        actions: List<Widget>.generate(
          newsType.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: newsType[i]== 'Video'? AppTranslations.of(context).text("key_Video"): AppTranslations.of(context).text("key_Image"),
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedItem=newsType[i]=='Video'?'Video':'Image';
                _clearData();
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  Future _pickImage(ImageSource iSource) async {
    var imageFile =
    await ImagePicker.pickImage(source: iSource, imageQuality: 60);
    /*imageFile = await compressAndGetFile(imageFile);*/
    setState(() {
      widget.titleController = widget.titleController;
      widget.descriptionController = widget.descriptionController;
      this.imgFile = File(imageFile.path);
    });

  }


  Future<File> compressAndGetFile(File file) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path,
      quality: 10,
      rotate: 0,
    );

    return result;
  }

  String getValidationMessage() {
    if (widget.titleController.text == '')
      return AppTranslations.of(context).text("key_title_instruction");

    if (widget.descriptionController.text == '')
      return AppTranslations.of(context).text("key_description_instruction");


    if(selectedItem=='Video'){
      if (widget.videoController.text == '')
        return AppTranslations.of(context).text("key_newsfeed_instruction");

      if(!widget.videoController.text.toString().startsWith("http"))

        return AppTranslations.of(context).text("key_url_not_proper_format");

  }

    return '';
  }

  void _clearData() {
    widget.titleController.text = '';
    widget.descriptionController.text = '';
    widget.videoController.text = '';
    imgFile = null;
  }
  Future<bool> _onBackPressed() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNevigationPage()),
    );
  }
  Future<void> postNewsfeed() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = AppTranslations.of(context).text("key_saving");
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          "user_id": user != null ? user.user_id : "",
          "NewsDate": DateFormat("yyyy-MMM-dd").format(_selectedDate),
          "NewsTitle": widget.titleController.text,
          "NewsDesc": widget.descriptionController.text,
          "news_type": selectedItem,
          "Yr_NO":  AppData.getCurrentInstance().user.yr_no.toString(),
          "video_url": widget.videoController.text!=null? widget.videoController.text:"",
        };

        Uri saveNewsfeedUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                NewsletterUrls.POSTNEWSFEED,
            params);

        http.Response response = await http.post(
          saveNewsfeedUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: '',
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          // post Circular Image
          if (imgFile != null) {
            await postNewsfeedImage(int.parse(response.body.toString()));
          } else {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                message: Text(
                  AppTranslations.of(context).text("key_save_newsfeed"),
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text(
                      AppTranslations.of(context).text("key_ok"),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context,
                          true); // It worked for me instead of above line
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNevigationPage()),
                      );
                    },
                  )
                ],
              ),
            );
          }

          _clearData();
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.ERROR,
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

  Future<void> postNewsfeedImage(int newsid) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Video/PostNewsfeedImage',
      ).replace(
        queryParameters: {
          'brcode': widget.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          'NewsId': newsid.toString(),
        },
      );

      final mimeTypeData =
      lookupMimeType(imgFile.path, headerBytes: [0xFF, 0xD8]).split('/');

      final imageUploadRequest =
      http.MultipartRequest(HttpRequestMethods.POST, postUri);

      final file = await http.MultipartFile.fromPath(
        'image',
        imgFile.path,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ),
      );

      imageUploadRequest.fields['ext'] = mimeTypeData[1];
      imageUploadRequest.files.add(file);

      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == HttpStatusCodes.CREATED) {

        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              AppTranslations.of(context).text("key_save_circular"),
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  AppTranslations.of(context).text("key_ok"),
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context,
                      true); // It worked for me instead of above line
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => NewsletterPage()),
                  );
                },
              )
            ],
          ),
        );
      } else {
        FlushbarMessage.show(
          context,
          null,
          AppTranslations.of(context).text("key_image_not_saved"),
          MessageTypes.ERROR,
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
}
