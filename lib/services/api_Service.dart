import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_app/model/ChannelDetails.dart';
import 'package:my_app/model/videoModel.dart';
import 'package:my_app/utilities/keys.dart';

class APIService {
  static const ChannelId = 'UCAxW0ZP3Gcfxe8ggCJLaHRQ';

  static const _baseUrl = 'youtube.googleapis.com';

  static Future<ChannelDetails> getChannelDetails() async {
    Map<String, String> parameters = {
      'part': 'snippet,contentDetails,statistics',
      'id': ChannelId,
      'key': Keys.API_Key,
    };

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );

    var response = await http.get(uri, headers: headers);
    print(response.body);
    ChannelDetails channelDetails = channelDetailsFromJson(response.body);
    return channelDetails;
  }

  static Future<VideoModel> getVideosList(
      {String playListId, String pageToken}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playListId,
      'maxResults': "10",
      'pageToken': pageToken,
      'key': Keys.API_Key,
    };

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );

    var response = await http.get(uri, headers: headers);
    print(response.body);
    VideoModel videoModel = videoModelFromJson(response.body);
    return videoModel;
  }
}
