import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/album.dart';
import 'package:teachers/models/album_photo.dart';
import 'package:teachers/models/user.dart';

class FullScreenImagePage extends StatefulWidget {
  final List<dynamic> dynamicObjects;
  final String imageType;
  final int photoIndex;


  const FullScreenImagePage({this.dynamicObjects,this.imageType, this.photoIndex});

  @override
  _FullScreenImagePageState createState() =>
      _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Swiper(
        itemBuilder: (c, i) {
          return FutureBuilder<String>(
              future: getImageUrl(widget.dynamicObjects[i],widget.imageType),
              builder: (context, AsyncSnapshot<String> snapshot) {
                return Stack(
                  children: <Widget>[
                    Container(
                      color: Colors.black,
                      child: CachedNetworkImage(
                        imageUrl: snapshot.data.toString(),
                        imageBuilder: (context, imageProvider) => PhotoView(
                          imageProvider:
                          new NetworkImage(snapshot.data.toString()),
                        ),
                        placeholder: (context, url) => Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: 4.0,
                            ),
                            child: LinearProgressIndicator(
                              backgroundColor:
                              Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: new IconButton(
                            icon: Icon(
                              Icons.file_download,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              _downloadImage(
                                  snapshot.data.toString(),
                                  destination: AndroidDestinationType.directoryDownloads
                                    ..subDirectory("image.jpg")
                              );
                            }),
                      ),
                    )
                  ],
                );
              });
        },
        loop: widget.dynamicObjects.length > 1 ? true : false,
        pagination: new SwiperPagination(
          margin: new EdgeInsets.all(5.0),
        ),
        itemCount: widget.dynamicObjects.length,
        index: widget.photoIndex,
      ),
    );
  }

  Future<String> getImageUrl(dynamic dynamicObj,String imageType) => NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
    if (connectionServerMsg != "key_check_internet") {


      if(imageType == 'Album'){
        return Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              AlbumUrls.GET_ALBUM_PHOTO,
        ).replace(queryParameters: {
          AlbumPhotoFieldNames.album_id:
          dynamicObj.album_id.toString(),
          AlbumPhotoFieldNames.photo_id:
          dynamicObj.photo_id.toString(),
          "brcode": AppData.getCurrentInstance().user.brcode,
          "clientCode": AppData.getCurrentInstance().user.client_code,
        }).toString();
      }else if(imageType == 'HomeWork'){
        return Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              'Homework/GetHomeworkImage',
        ).replace(queryParameters: {
          "hw_no": dynamicObj.hw_no.toString(),
          "clientCode":
          AppData.getCurrentInstance().user.client_code,
          "brcode": AppData.getCurrentInstance().user.brcode,
        }).toString();
      }else if(imageType == 'Circular'){
        return Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              'Circular/GetCircularImage',
        ).replace(queryParameters: {
          "clientCode": AppData.getCurrentInstance().user.client_code,
          "brcode": AppData.getCurrentInstance().user.brcode,
          "circular_no": dynamicObj.circular_no.toString(),
        }).toString();
      }else if(imageType == 'Newsletter'){
        return Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              'Video/GetNewsFeedImage',
        ).replace(queryParameters: {
          UserFieldNames.brcode: AppData.getCurrentInstance().user.brcode,
          "clientCode": AppData.getCurrentInstance().user.client_code,
          "NewsId": dynamicObj.NewsId.toString(),
        }).toString();
      }

    }
  });
  Future<void> _downloadImage(String url, {AndroidDestinationType destination, bool whenError = false, String outputMimeType}) async {
    String fileName;
    String path;
    int size;
    String mimeType;
    try {
      String imageId;

      if (whenError) {
        imageId = await ImageDownloader.downloadImage(url, outputMimeType: outputMimeType).catchError((error) {
          if (error is PlatformException) {
            var path = "";
            if (error.code == "404") {
              print("Not Found Error.");
            } else if (error.code == "unsupported_file") {
              print("UnSupported FIle Error.");
              path = error.details["unsupported_file_path"];
            }
          }

          print(error);
        }).timeout(Duration(seconds: 10), onTimeout: () {
          print("timeout");
          return;
        });
      } else {
        if (destination == null) {
          imageId = await ImageDownloader.downloadImage(
            url,
            outputMimeType: outputMimeType,
          );
        } else {
          imageId = await ImageDownloader.downloadImage(
            url,
            destination: destination,
            outputMimeType: outputMimeType,
          );
        }
      }

      if (imageId == null) {
        return;
      }
      fileName = await ImageDownloader.findName(imageId);
      path = await ImageDownloader.findPath(imageId);
      size = await ImageDownloader.findByteSize(imageId);
      mimeType = await ImageDownloader.findMimeType(imageId);

      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_image_download_succesfully"),
        MessageTypes.INFORMATION,
      );

    } on PlatformException catch (error) {
      return;
    }

    if (!mounted) return;

  }
}
