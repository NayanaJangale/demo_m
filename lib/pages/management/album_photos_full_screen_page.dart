import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/models/album.dart';
import 'package:teachers/models/album_photo.dart';

class AlbumPhotosFullScreenPage extends StatefulWidget {
  final List<AlbumPhoto> albumPhotos;
  final int photoIndex;

  const AlbumPhotosFullScreenPage({this.albumPhotos, this.photoIndex});

  @override
  _AlbumPhotosFullScreenPageState createState() =>
      _AlbumPhotosFullScreenPageState();
}

class _AlbumPhotosFullScreenPageState extends State<AlbumPhotosFullScreenPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper(
        itemBuilder: (c, i) {
          Uri uri;
          NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
            if (connectionServerMsg != "key_check_internet") {
              setState(() {
                uri = Uri.parse(
                  connectionServerMsg +
                      ProjectSettings.rootUrl +
                      AlbumUrls.GET_ALBUM_PHOTO,
                ).replace(queryParameters: {
                  AlbumPhotoFieldNames.album_id:
                      widget.albumPhotos[i].album_id.toString(),
                  AlbumPhotoFieldNames.photo_id:
                      widget.albumPhotos[i].photo_id.toString(),
                  "brcode": AppData.getCurrentInstance().user.brcode,
                  "clientCode": AppData.getCurrentInstance().user.client_code,
                });
              });
            }
          });

          return new Center(
            child: Container(
              color: Colors.white,
              child: PhotoView(
                imageProvider: new NetworkImage(uri.toString()),
              ),
            ),
          );
        },
        loop: widget.albumPhotos.length > 1 ? true : false,
        pagination: new SwiperPagination(
          margin: new EdgeInsets.all(5.0),
        ),
        itemCount: widget.albumPhotos.length,
        index: widget.photoIndex,
      ),
    );
  }
}
