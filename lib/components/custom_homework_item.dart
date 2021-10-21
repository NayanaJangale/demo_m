import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/homework.dart';
import 'package:teachers/models/period.dart';
import 'package:teachers/pages/management/full_screen_image_page.dart';
import 'package:teachers/pages/management/homework_documents_page.dart';

class CustomHomeworkItem extends StatefulWidget {
  final String networkPath;
  final List<Period> periods;
  final Function onItemTap;
  final Homework homework;

  CustomHomeworkItem(
      {this.networkPath, this.periods, this.onItemTap, this.homework});

  @override
  _CustomHomeworkItemState createState() => _CustomHomeworkItemState();
}

class _CustomHomeworkItemState extends State<CustomHomeworkItem> {
  String hwDate, submissionDate;
  List<Homework> _homeworks = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _homeworks.add(widget.homework);
    hwDate = widget.homework.hw_date != null
        ? DateFormat('dd MMM').format(widget.homework.hw_date)
        : "";
    submissionDate = widget.homework.submission_dt != null
        ? DateFormat('dd MMM').format(widget.homework.submission_dt)
        : "";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
        /*  GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImagePage(
                    dynamicObjects: _homeworks,
                    imageType: 'HomeWork',
                    photoIndex: 0,
                  ),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: widget.networkPath,
              imageBuilder: (context, imageProvider) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.networkPath,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) => Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  top: 8.0,
                ),
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              errorWidget: (context, url, error) => Container(),
            ),
          ),*/
          widget.periods != null && widget.periods.length > 0
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Wrap(
                    spacing: 5.0, // gap between adjacent chips,
                    runSpacing: 0.0,
                    children: List<Widget>.generate(
                      widget.periods.length,
                      (i) => Chip(
                        backgroundColor: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                            topLeft: Radius.circular(3),
                            bottomLeft: Radius.circular(3),
                          ),
                        ),
                        avatar: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 12,
                          height: 12,
                        ),
                        label: Text(
                          widget.periods[i].subject_name +
                              ' - ' +
                              widget.periods[i].class_name +
                              ' ' +
                              widget.periods[i].division_name,
                        ),
                        labelStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppTranslations.of(context).text("key_date") + ':' + hwDate,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  AppTranslations.of(context).text("key_submission_date") +
                      ':' +
                      submissionDate,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            child: Text(
              widget.homework.hw_desc,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.homework.teacher_name,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Visibility(
                  visible: widget.homework.docstatus,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeworkDocumentsPage(
                          hw_no: widget.homework.hw_no,
                        )),
                      );
                    },
                    child: Text(
                      'View Document',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                          fontSize: 14
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 10.0,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onItemTap,
                child: Text(
                  AppTranslations.of(context).text("key_Approve"),
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
