import 'package:flutter/material.dart';
import 'package:my_app/model/ChannelDetails.dart';
import 'package:my_app/pages/videoPage.dart';
import 'package:my_app/services/api_Service.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:my_app/model/videoModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChannelDetails _channelDetails;
  VideoModel _videoModel;
  Item _item;
  bool _loading;
  String _playListId;
  String _nextPageToken;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _nextPageToken = '';
    _videoModel = VideoModel();
    _scrollController = ScrollController();
    _videoModel.videoItems = List();
    _loading = true;
    _getChannelDetails();
  }

  _getChannelDetails() async {
    _channelDetails = await APIService.getChannelDetails();
    _item = _channelDetails.items[0];
    _playListId = _item.contentDetails.relatedPlaylists.uploads;
    print("_playListId : $_playListId");
    await _loadVideos();
    setState(() {
      _loading = false;
    });
  }

  _loadVideos() async {
    VideoModel tempVideoList = await APIService.getVideosList(
      playListId: _playListId,
      pageToken: _nextPageToken,
    );
    _nextPageToken = tempVideoList.nextPageToken;
    _videoModel.videoItems.addAll(tempVideoList.videoItems);
    print("videos: ${tempVideoList.videoItems.length}");
    print("next page token : $_nextPageToken");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: "Youtube Flutter".text.red600.makeCentered(),
          backgroundColor: Colors.blueAccent,
          titleSpacing: 1,
          elevation: 2,
        ),
        body: DoubleBackToCloseApp(
          snackBar: SnackBar(
            content: "press again to close Youtube Flutter".text.make(),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
          ),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                _infoView(),
                Expanded(
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (_videoModel.videoItems.length >=
                          int.parse(_item.statistics.videoCount)) {
                        return true;
                      }
                      if (notification.metrics.pixels ==
                          notification.metrics.maxScrollExtent) {
                        _loadVideos();
                      }
                      return true;
                    },
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _videoModel.videoItems.length,
                        itemBuilder: (context, index) {
                          VideoItem videoItem = _videoModel.videoItems[index];
                          return InkWell(
                            onTap: () async {
                              Navigator.push(
                                  context,
                                  (MaterialPageRoute(builder: (contexr) {
                                    return VideoPage(
                                      videoItem: videoItem,
                                    );
                                  })));
                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: HStack(
                                [
                                  CachedNetworkImage(
                                    imageUrl: videoItem.videoSnippet.thumbnails
                                        .thumbnailsDefault.url,
                                  ),
                                  Flexible(
                                    child: VStack([
                                      "${videoItem.videoSnippet.title}"
                                          .text
                                          .semiBold
                                          .black
                                          .make()
                                          .p8()
                                          .box
                                          .make(),
                                      "${videoItem.videoSnippet.publishedAt}"
                                          .text
                                          .semiBold
                                          .gray500
                                          .size(10)
                                          .make()
                                          .p4()
                                          .box
                                          .make(),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _infoView() {
    return _loading
        ? CircularProgressIndicator()
        : Container(
            child: Card(
              child: Flexible(
                child: VStack([
                  Padding(padding: EdgeInsets.only(right: 20)),
                  Flexible(
                    child: HStack([
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            _item.snippet.thumbnails.medium.url),
                      ),
                      "${_item.snippet.title}"
                          .text
                          .semiBold
                          .letterSpacing(1)
                          .size(20)
                          .fontWeight(FontWeight.w400)
                          .make()
                          .p8(),
                      "${_item.statistics.subscriberCount}"
                          .text
                          .size(10)
                          .fontWeight(FontWeight.w400)
                          .make()
                          .p8()
                          .card
                          .make(),
                    ]),
                  ),
                  "Custom Url :   ${_item.snippet.customUrl}"
                      .text
                      .size(10)
                      .fontWeight(FontWeight.w400)
                      .make()
                      .p8(),
                  ("Total video Count :   ${_item.statistics.videoCount}")
                      .text
                      .size(10)
                      .fontWeight(FontWeight.w400)
                      .make()
                      .p8(),
                  Padding(padding: EdgeInsets.only(right: 10)),
                ]),
              ),
            ).box.make(),
          );
  }
}
