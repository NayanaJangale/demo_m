import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
import 'package:teachers/constants/menu_constants.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/circular.dart';
import 'package:teachers/models/class.dart';
import 'package:teachers/models/divison.dart';
import 'package:teachers/models/mng_section.dart';
import 'package:teachers/models/selected_classes.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/user.dart';
import 'mng_branchwise_circular.dart';


class CircularForConst {
  static const String ALL = 'All';
  static const String STUDENTS = 'Students';
  static const String TEACHERS = 'Teachers';
}

class MngAddInternalCircularPage extends StatefulWidget {
  String brcode;

  MngAddInternalCircularPage(this.brcode);

  @override
  _MngAddInternalCircularPageState createState() =>
      _MngAddInternalCircularPageState();
}

class _MngAddInternalCircularPageState
    extends State<MngAddInternalCircularPage> {
  List<Section> section = [];
  List<Class> classes = [];
  List<Division> divisions = [];
  Division selectedDivision;
  FileType _pickingType = FileType.any;
  List<String> menus = ['Camera', 'Gallery'];
  bool isLoading, _loadingPath = false,  _multiPick = true;
  String loadingText,_extension,_fileName;
  FocusNode titleFocusNode, descriptionFocusNode;
  TextEditingController titleController, descriptionController;
  File imgFile;
  List<String> circularFor = [
    CircularForConst.ALL,
    CircularForConst.STUDENTS,
    CircularForConst.TEACHERS
  ];
  String defaultCircular = CircularForConst.ALL;
  String selectedItem, selectedSection, selectedClasses,_directoryPath;
  Class Classes;
  TeacherClass selectedClass;
  int sectionId, fromClassID, toclassID;
  Class selectedDropDownClass;
  Division selectedDropDownDivision;
  bool isSelected = false;
  List<PlatformFile> _paths;
  List<SelectedClass> selectedClassesList = [];
  GlobalKey<ScaffoldState> _addCircularPageGK;


  @override
  void initState() {
    super.initState();
    _addCircularPageGK = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = "key_loading_circulars";
    titleFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();

    titleController = TextEditingController();
    descriptionController = TextEditingController();

    fetchSection().then((result) {
      setState(() {
        section = result;
        section.insert(0, new Section(Section_id: 0, Section_desc: "All"));
//        selectedDropDownClass=Class(class_id: 0, class_name: "All");
//        selectedDropDownDivision=Division(division_id: 0, division_name: "All");
      });
    });

    selectedSection = "Select Section";
    selectedClasses = "Select Classes";
//    selectedDropDownClass=classes[0].class_name;
//    selectedDropDownDivision=divisions[0].division_name;
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: AppTranslations.of(context).text(loadingText),
      child: Scaffold(
        key: _addCircularPageGK,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_add_circular"),
            subtitle: AppTranslations.of(context).text("key_select_section"),
          ),
          elevation: 0,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          left: 10.0,
                          right: 10.0,
                          bottom: 10.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _showCircularFor();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      5.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            AppTranslations.of(context)
                                                .text("key_circular_for"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          defaultCircular,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                selectedClasses = 'Select Classes';
                                _showSection();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.0,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
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
                                            .text("key_section"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          selectedSection,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
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
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: defaultCircular == "Students" || defaultCircular == "All",
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  if (!selectedSection.contains("Select Section"))
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            content: StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setState) {
                                              return Container(
                                                height: double.infinity,
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      AppTranslations.of(context)
                                                          .text("key_select_class"),
                                                      style: TextStyle(
                                                        fontFamily: 'Quicksand',
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                         new DropdownButton<Class>(
                                                          hint: Text("Class"),
                                                          value:
                                                          selectedDropDownClass,
                                                          autofocus: true,
                                                          onChanged:
                                                              (Class newVal) {
                                                            setState(() {
                                                              divisions.clear();
                                                              selectedDropDownClass
                                                              = newVal;
                                                              if(selectedDropDownClass.class_id != 0){
                                                                fetchDivision().then((result) {
                                                                  setState(() {
                                                                    divisions = result;
                                                                    divisions.insert(
                                                                        0, new Division(division_id: 0, division_name: "All"));
                                                                    selectedDropDownDivision = divisions[0];

                                                                  });
                                                                });
                                                              }else{

                                                              }

                                                            });
                                                          },
                                                          items: classes.map(
                                                                (Class className) {
                                                              return new DropdownMenuItem(
                                                                value: className,
                                                                child: new Text(
                                                                    className
                                                                        .class_name,
                                                                    style: new TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                    overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                              );
                                                            },
                                                          ).toList(),
                                                        ),
                                                         new DropdownButton<
                                                            Division>(
                                                          hint: Text("Division"),
                                                          value:
                                                          selectedDropDownDivision,
                                                          autofocus: true,
                                                          onChanged: (Division
                                                          newValue) {
                                                            setState(() {
                                                              selectedDropDownDivision =
                                                                  newValue;
                                                            });
                                                          },
                                                          items: divisions.map(
                                                                (Division division) {
                                                              return new DropdownMenuItem(
                                                                value: division,
                                                                child: new Text(
                                                                  division
                                                                      .division_name,
                                                                  style: new TextStyle(
                                                                      color: Colors
                                                                          .black,fontSize: 10),
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                ),
                                                              );
                                                            },
                                                          ).toList(),
                                                        ),
                                                        //          DropdownButton<String>(
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    Navigator.of(context).pop();
                                                    SelectedClass temp = SelectedClass(
                                                        class_id:
                                                        selectedDropDownClass
                                                            .class_id,
                                                        division_id:
                                                        selectedDropDownDivision
                                                            .division_id,
                                                        section_id: sectionId,
                                                        subject_id: 0);
                                                    bool isTempFound = false;
                                                    for (var t
                                                    in selectedClassesList) {
                                                      if (t.class_id ==
                                                          temp.class_id &&
                                                          t.division_id ==
                                                              temp.division_id) {
                                                        isTempFound = true;
                                                      }
                                                    }
                                                    if (!isTempFound) {
                                                      selectedClassesList
                                                          .add(temp);
                                                      if (selectedDropDownClass !=
                                                          null &&
                                                          selectedDropDownDivision !=
                                                              null) {
                                                        if (selectedClasses
                                                            .contains(
                                                            "Select Classes")) {
                                                          selectedClasses = "";
                                                        }
                                                        selectedClasses +=
                                                            selectedDropDownClass
                                                                .toString() +
                                                                " " +
                                                                selectedDropDownDivision
                                                                    .toString();
                                                        selectedClasses += ', ';
                                                      }
                                                    }
                                                  });

                                                },
                                                child: Text(
                                                  "OK ",
                                                  style: Theme.of(context).textTheme.caption.copyWith(
                                                      color: Theme.of(context).primaryColorDark,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color:
                                          Theme.of(context).secondaryHeaderColor,
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
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            selectedClasses,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
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
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 3.0,
                                    right: 3.0,
                                    top: 8.0,
                                  ),
                                  child: CustomTextBox(
                                    inputAction: TextInputAction.next,
                                    focusNode: titleFocusNode,
                                    onFieldSubmitted: (value) {
                                      this.titleFocusNode.unfocus();
                                      FocusScope.of(context).requestFocus(
                                          this.descriptionFocusNode);
                                    },
                                    labelText: AppTranslations.of(context)
                                        .text("key_album_title"),
                                    controller: titleController,
                                    icon: Icons.title,
                                    keyboardType: TextInputType.text,
                                    colour: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 3.0, right: 3.0),
                                  child: CustomTextBox(
                                    inputAction: TextInputAction.next,
                                    focusNode: descriptionFocusNode,
                                    onFieldSubmitted: (value) {
                                      this.descriptionFocusNode.unfocus();
                                    },
                                    labelText: AppTranslations.of(context)
                                        .text("key_description"),
                                    controller: descriptionController,
                                    icon: Icons.description,
                                    keyboardType: TextInputType.text,
                                    colour: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8, left: 20),
                                    child: Row(
                                      children: [
                                        Icon(Icons.attach_file_outlined, size: 20,color: Theme.of(context).primaryColorDark,),
                                        SizedBox(width: 10,),
                                        GestureDetector(
                                          onTap: (){
                                            _openFileExplorer();
                                          },
                                          child: Text(
                                            "Select Files / Images",
                                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                                color: Theme.of(context).primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                      ],
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (BuildContext context) => _loadingPath
                                      ? Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: const CircularProgressIndicator(),
                                  )
                                      : _directoryPath != null
                                      ? ListTile(
                                    title: const Text('Directory path'),
                                    subtitle: Text(_directoryPath),
                                  )
                                      : _paths != null
                                      ? Container(
                                    padding: const EdgeInsets.only(bottom: 10.0,top: 10,left: 20),
                                    height:
                                    MediaQuery.of(context).size.height * 0.50,
                                    child: Scrollbar(
                                        child: ListView.separated(
                                          itemCount:
                                          _paths != null && _paths.isNotEmpty
                                              ? _paths.length
                                              : 1,
                                          itemBuilder:
                                              (BuildContext context, int index) {
                                            final bool isMultiPath =
                                                _paths != null && _paths.isNotEmpty;
                                            final String name = 'File $index: ' + (isMultiPath
                                                ? _paths.map((e) => e.name).toList()[index] : _fileName ?? '...');
                                            final path = _paths.map((e) => e.path).toList()[index].toString();

                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    behavior: HitTestBehavior.translucent,
                                                    child: Icon(Icons.delete,color: Theme.of(context).primaryColor,),
                                                    onTap: (){
                                                      setState(() {
                                                        _paths.removeAt(index);
                                                      });
                                                    },
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context, int index) =>
                                          const Divider(),
                                        )),
                                  )
                                      : const SizedBox(),
                                ),
                               /* Padding(
                                  padding: const EdgeInsets.all(2.0),
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            imgFile,
                                            fit: BoxFit.cover,
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
                                    height: 0.0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 3.0,
                                    right: 3.0,
                                  ),
                                  child: Container(
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          leading: menus[index] == 'Camera'
                                              ? Icon(
                                                  Icons.camera_alt,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )
                                              : Icon(
                                                  Icons.photo,
                                                  color: Theme.of(context)
                                                      .primaryColor,
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
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 3.0,
                                    right: 3.0,
                                  ),
                                  child: Divider(
                                    height: 0.0,
                                  ),
                                ),*/
                              ],
                            ),
                          ],
                        ),
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
                    '',
                    valMsg,
                    MessageTypes.WARNING,
                  );
                } else {
                  postCircular();
                }
              },
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_post_circular"),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Colors.white,
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
  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      print(_paths.first.extension);
      _fileName =
      _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });
  }
  Future<void> postCircular() async {
    try {
      setState(() {
        isLoading = true;
        this.loadingText = "key_saving_text";
      });

      Circular circular = Circular(
          circular_title: titleController.text,
          circular_desc: descriptionController.text,
          emp_no: AppData.getCurrentInstance().user.emp_no,
          brcode: AppData.getCurrentInstance().user.brcode,
          divisions: json.encode(selectedClassesList));
          circular.circular_for = defaultCircular;

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          "user_id": user != null ? user.user_id : "",
          UserFieldNames.brcode : widget.brcode.toString()
        };

        Uri saveCircularUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                CircularUrls.POST_TEACHER_CIRCULAR,
            params);

        String jsonBody = json.encode(circular);

        http.Response response = await http.post(
          saveCircularUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          if (_paths != null) {
            String number = response.body.toString();
            await postCircularFile(int.parse(response.body.toString()));
          } else {
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
                          true);
                      clearData();// It worked for me instead of above line
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MngBrancwiseCircular(
                            menuName: MenuNameConst.Circulars,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          }
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
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
      this.loadingText = "key_loading";
    });
  }
  Future<void> postCircularImage(int circular_no) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Circular/PostCircularImage',
      ).replace(
        queryParameters: {
          // 'section_id': AppData.getCurrentInstance().user.section_id.toString(),
          'brcode': AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          'circular_no': circular_no.toString(),
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
        FlushbarMessage.show(
          context,
          '',
          response.body.toString(),
          MessageTypes.INFORMATION,
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
    if (titleController.text == '')
      return AppTranslations.of(context).text("key_title_instruction");

    if (descriptionController.text == '')
      return AppTranslations.of(context).text("key_description_instruction");
    if( defaultCircular == "Students" || defaultCircular == "All"){
      if (selectedClassesList.length == 0) {
        return AppTranslations.of(context).text("key_select_class_instruction");
      }
    }else{
      SelectedClass temp = SelectedClass(
          class_id: 0,
          division_id: 0,
          section_id: sectionId,
          subject_id: 0);
      selectedClassesList .add(temp);
    }
    return '';
  }
  void clearData(){
    titleController.text = "";
    descriptionController.text="";
    imgFile= null;
  }
  void _showCircularFor() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_send_circular_to"),
        ),
        actions: List<Widget>.generate(
          circularFor.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: circularFor[i] == CircularForConst.ALL
                ? AppTranslations.of(context).text("key_all")
                : circularFor[i] == CircularForConst.TEACHERS
                    ? AppTranslations.of(context).text("key_teacher")
                    : AppTranslations.of(context).text("key_student"),
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                defaultCircular = circularFor[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void _showSection() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_section"),
        ),
        actions: List<Widget>.generate(
          section.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: section[i].Section_desc,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedClassesList.clear();
                selectedDropDownDivision = null;
                selectedDropDownClass = null;
                selectedSection = section[i].Section_desc;
                sectionId = section[i].Section_id;
                if (selectedSection.contains("All")) {
                  classes.clear();
                  divisions.clear();
                  classes.insert(
                      0, new Class(class_id: 0, class_name: "All"));
                  divisions.insert(
                      0, new Division(division_id: 0, division_name: "All"));
                } else {
                  fetchClasses(section[i].Section_id).then((result) {
                    setState(() {
                      classes.clear();
                      classes = result;
                      classes.insert(
                          0, new Class(class_id: 0, class_name: "All"));
                      if (classes!= null && classes.length > 0 ){
                        fetchDivision().then((result) {
                          setState(() {
                            divisions.clear();
                            divisions = result;
                            divisions.insert(0,
                                new Division(division_id: 0, division_name: "All"));
                          });
                        });
                      }
                    });
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
  Future<List<Section>> fetchSection() async {
    List<Section> section = [];
    try {
      setState(() {
        isLoading = true;
        this.loadingText = "key_loading";
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {};

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                SectionUrls.GET_SECTIONS,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            section =
                responseData.map((item) => Section.fromJson(item)).toList();
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

    return section;
  }
  Future<List<Class>> fetchClasses(int sectionID) async {
    List<Class> classes = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "section_id": sectionID.toString()};
        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ClassUrls.GET_SECTION_CLASS,
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
            classes = responseData.map((item) => Class.fromJson(item)).toList();
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
  Future<List<Division>> fetchDivision() async {
    List<Division> divisions = [];
    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "class_id" : selectedDropDownClass != null  ? selectedDropDownClass.class_id.toString()  : "0"
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
  Future<void> postCircularFile(int circular_no) async {
    int saveHwCount = 0 ;
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      for(int i=0 ; i < _paths.length ; i++){
        final mimeTypeData =
        lookupMimeType(_paths[i].path).split('/');

        final file = await http.MultipartFile.fromPath(
          mimeTypeData[0],
          _paths[i].path,
          contentType: MediaType(
            mimeTypeData[0],
            mimeTypeData[1],
          ),
        );

        Uri postUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              "Circular/PostCircularFile?",
        ).replace(
          queryParameters: {
            'content_type': file.contentType.toString(),
            'brcode': AppData.getCurrentInstance().user.brcode,
            'clientCode': AppData.getCurrentInstance().user.client_code,
            'circular_no': circular_no.toString(),
            'file_name': file.filename.toString(),
            'file_ext': "." + mimeTypeData[1],
            'file_type': mimeTypeData[0],
            'yr_no': AppData.getCurrentInstance().user.yr_no.toString(),
          },
        );

        final imageUploadRequest =
        http.MultipartRequest(HttpRequestMethods.POST, postUri);

        imageUploadRequest.fields['ext'] = mimeTypeData[1];
        imageUploadRequest.files.add(file);

        final streamedResponse = await imageUploadRequest.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == HttpStatusCodes.CREATED){
          saveHwCount ++;
        }
        response.body ;
      }
      if (saveHwCount == _paths.length) {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              "Circular Save Successfully",
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  AppTranslations.of(context).text("key_ok"),
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(
                      context, true);
                  _paths = null ;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MngBrancwiseCircular(menuName: MenuNameConst.Circulars,)),
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
        null,
        'Please check your Internet Connection!',
        MessageTypes.ERROR,
      );
    }
  }
}
