import 'package:dio/dio.dart';
import 'package:trtc_scenes_demo/debug/GenerateTestUserSig.dart';

class YunApiHelper {
  static String _url =
      'https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest';
  static Dio _dio = new Dio();

  static Future<bool> createRoom(String roomId,
      {String roomType = "voiceRoom"}) async {
    Response<dynamic> resp = await _dio.get(
      _url,
      queryParameters: {
        "method": "createRoom",
        "appId": GenerateTestUserSig.sdkAppId,
        "type": roomType,
        "roomId": roomId
      },
    );
    var data = resp.data;
    return Future.value(data["errorCode"] == 0 ? true : false);
  }

  static Future<bool> destroyRoom(String roomId,
      {String roomType = "voiceRoom"}) async {
    Response<dynamic> resp = await _dio.get(
      _url,
      queryParameters: {
        "method": "destroyRoom",
        "appId": GenerateTestUserSig.sdkAppId,
        "type": roomType,
        "roomId": roomId
      },
    );
    var data = resp.data;
    return Future.value(data["errorCode"] == 0 ? true : false);
  }

  static Future<List<String>> getRoomList(
      {String roomType = "voiceRoom"}) async {
    Response<dynamic> resp = await _dio.get(
      _url,
      queryParameters: {
        "method": "getRoomList",
        "appId": GenerateTestUserSig.sdkAppId,
        "type": roomType
      },
    );
    var data = resp.data;
    List<String> roomIdls = [];
    if (data["errorCode"] == 0) {
      List<dynamic> resList = data["data"] as List<dynamic>;
      for (int i = 0; i < resList.length; i++) {
        dynamic item = resList[i];
        roomIdls.add(item["roomId"]);
      }
    }
    return Future.value(roomIdls);
  }
}
