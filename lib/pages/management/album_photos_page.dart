import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/album.dart';
import 'package:teachers/models/album_photo.dart';
import 'package:teachers/pages/management/album_photos_full_screen_page.dart';
import 'package:teachers/pages/management/full_screen_image_page.dart';

class AlbumPhotosPage extends StatefulWidget {
  final int albumID;
  final String albumDesc;

  const AlbumPhotosPage({this.albumID, this.albumDesc});

  @override
  _AlbumPhotosPageState createState() => _AlbumPhotosPageState();
}

class _AlbumPhotosPageState extends State<AlbumPhotosPage> {
  GlobalKey<ScaffoldState> _albumPhotosPageGK;
  bool isLoading;
  String loadingText;
  List<AlbumPhoto> _albumPhotos = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _albumPhotosPageGK = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchAlbumPhotos().then((result) {
      setState(() {
        _albumPhotos = result;
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
        key: _albumPhotosPageGK,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_album"),
            subtitle: widget.albumDesc,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchAlbumPhotos().then((result) {
              setState(() {
                _albumPhotos = result != null ? result : [];
              });
            });
          },
          child: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(3.0),
            children: List<Widget>.generate(
              _albumPhotos.length,
              (index) => getAlbumPhotoCard(_albumPhotos[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAlbumPhotoCard(AlbumPhoto photoItem, int index) {

    return FutureBuilder<String>(
        future: getImageUrl(photoItem),
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: CachedNetworkImage(
                imageUrl: snapshot.data.toString(),
                imageBuilder: (context, imageProvider) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      snapshot.data.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.only(
                      left: 50.0, right: 60.0, top: 60.0, bottom: 60.0),
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                errorWidget: (context, url, error) => Container(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImagePage(
                      dynamicObjects:  _albumPhotos,
                      imageType: 'Album',
                      photoIndex: index,
                    ),
                  ),
                );
              },
            ),
          );
        });


  }
  Future<String> getImageUrl(AlbumPhoto photoItem) => NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
    if (connectionServerMsg != "key_check_internet") {
      return Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            "Gallery/GetAlbumPhoto",
      ).replace(queryParameters: {
        "album_id": photoItem.album_id.toString(),
        "photo_id": photoItem.photo_id.toString(),
        "brcode": AppData.getCurrentInstance().user.brcode,
        "clientCode": AppData.getCurrentInstance().user.client_code,
      }).toString();
    }
  });
  Future<List<AlbumPhoto>> fetchAlbumPhotos() async {
    List<AlbumPhoto> albumPhotos = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              AlbumPhotoUrls.GET_ALBUM_PHOTOS,
          {
            AlbumFieldNames.album_id: widget.albumID.toString(),
          },
        );

        Response response = await get(fetchteacherAlbumsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          _albumPhotosPageGK.currentState.showSnackBar(
            SnackBar(
              content: Text(
                response.body,
              ),
            ),
          );
        } else {
          List responseData = json.decode(response.body);
          albumPhotos = responseData
              .map(
                (item) => AlbumPhoto.fromJson(item),
              )
              .toList();
        }
      } else {
        FlushbarMessage.show(
          context,
          null,
          'Please check your Internet Connection!',
          MessageTypes.ERROR,
        );
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        'Not able to fetch Album Photos, please check whether Albums has been added!',
        MessageTypes.ERROR,
      );
    }

    setState(() {
      isLoading = false;
    });

    return albumPhotos;
  }
}
