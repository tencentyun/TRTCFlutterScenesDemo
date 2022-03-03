import 'dart:ui';
import './TRTCMeetingRoom.dart';

class MeetingTool {
  // 每4个一屏，得到一个二维数组
  static int screenLen = 4;
  static List<List<UserInfo>> getScreenList(List<UserInfo> list) {
    int len = screenLen; //4个一屏
    int index = 1;
    List<List<UserInfo>> result = [];

    while (index * len < list.length) {
      List<UserInfo> temp = list.skip((index - 1) * len).take(len).toList();
      result.add(temp);
      index++;
    }

    List<UserInfo> temp = list.skip((index - 1) * len).toList();
    result.add(temp);

    return result;
  }

  static Size getViewSize(
      Size screenSize, int totalListLength, int screenListLength) {
    if (totalListLength < 5) {
      if (screenListLength == 1) {
        return screenSize;
      }

      if (screenListLength == 2) {
        return Size(screenSize.width, screenSize.height / 2);
      }
    }

    return Size(screenSize.width / 2, screenSize.height / 2);
  }
}
