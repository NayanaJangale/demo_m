import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/album.dart';
import 'package:teachers/pages/management/add_album_page.dart';
import 'package:teachers/themes/colors_old.dart';

import 'album_photos_page.dart';

class AlbumsPage extends StatefulWidget {
  String brcode;

  AlbumsPage({this.brcode});

  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  GlobalKey<ScaffoldState> _albumsPageGK;
  bool isLoading;
  String loadingText;
  List<Album> _albums = [];
  String msgKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _albumsPageGK = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    msgKey = "key_loading_gallery";

    fetchTeacherAlbums().then((result) {
      setState(() {
        this._albums = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchTeacherAlbums().then((result) {
            setState(() {
              _albums = result != null ? result : [];
            });
          });
        },
        child: _albums != null && _albums.length != 0
            ? GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(3.0),
          children: List<Widget>.generate(
            _albums.length,
                (index) => getAlbumCard(_albums[index]),
          ),
        )
            : Padding(
          padding: const EdgeInsets.only(top: 30),
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return CustomDataNotFound(
                description: AppTranslations.of(context)
                    .text("key_album_not_found"),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget getAlbumCard(Album albumItem) {
    return FutureBuilder<String>(
        future: getImageUrl(albumItem),
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Card(
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
                        builder: (_) => AlbumPhotosPage(
                          albumID: albumItem.album_id,
                          albumDesc: albumItem.album_desc,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                  bottom: 4.0,
                  left: 3.0,
                  right: 3.0,
                  child: Column(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.zero,
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                            color: ThemeColors.primary.withOpacity(0.8),
                          ),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                                albumItem.album_desc != null
                                    ? StringHandlers.capitalizeWords(
                                    albumItem.album_desc)
                                    : "",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.white,
                                )),
                          )),
                    ],
                  )),
            ],
          );
        });
  }

  Future<String> getImageUrl(Album albumItem) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                "Gallery/GetAlbumPhoto",
          ).replace(queryParameters: {
            "album_id": albumItem.album_id.toString(),
            "photo_id": "-1",
            "brcode": AppData.getCurrentInstance().user.brcode,
            "clientCode": AppData.getCurrentInstance().user.client_code,
          }).toString();
        }
      });


  Future<List<Album>> fetchTeacherAlbums() async {
    List<Album> albums = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              AlbumUrls.GET_TEACHER_ALBUMS,
          Map<String, dynamic>(),
        );

        Response response = await get(fetchteacherAlbumsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_album_not_found";
          });
        } else {
          List responseData = json.decode(response.body);
          albums = responseData
              .map(
                (item) => Album.fromJson(item),
              )
              .toList();
          bool AddalbumOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('addAlbum_overlay') ??
              false;
          if (!AddalbumOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("addAlbum_overlay", true);
            _showOverlay(context);
          }
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

    return albums;
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_add_album_from_here")),
    );
  }
}
