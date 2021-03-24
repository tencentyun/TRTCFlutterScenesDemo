class CallModel {
  static final int VALUE_PROTOCOL_VERSION = 1;

  /*
  * 系统错误
  */
  static final int VIDEO_CALL_ACTION_ERROR = -1;
  /*
  * 未知信令
  */
  static final int VIDEO_CALL_ACTION_UNKNOWN = 0;
  /*
  * 正在呼叫
  */
  static final int VIDEO_CALL_ACTION_DIALING = 1;
  /*
  * 发起人取消
  */
  static final int VIDEO_CALL_ACTION_SPONSOR_CANCEL = 2;
  /*
  * 拒接电话
  */
  static final int VIDEO_CALL_ACTION_REJECT = 3;
  /*
  * 无人接听
  */
  static final int VIDEO_CALL_ACTION_SPONSOR_TIMEOUT = 4;
  /*
  * 挂断
  */
  static final int VIDEO_CALL_ACTION_HANGUP = 5;
  /*
  * 电话占线
  */
  static final int VIDEO_CALL_ACTION_LINE_BUSY = 6;
  /*
  * 接听电话
  */
  static final int VIDEO_CALL_ACTION_ACCEPT = 7;

  static int version = 0;
  //表示一次通话的唯一ID
  static String callId;
  //TRTC的房间号
  static int roomId = 0;
  //IM的群组id，在群组内发起通话时使用
  static String groupId = "";
  //信令动作
  static int action = VIDEO_CALL_ACTION_UNKNOWN;
  /*
  * 通话类型
  * 0-未知
  * 1-语音通话
  * 2-视频通话
  */
  static int callType = 0;
  //正在邀请的列表
  static List<String> invitedList;

  static int duration = 0;

  static int code = 0;
  static int timestamp = 0;
  static String sender;
  // 超时时间，单位秒
  static int timeout;

  static String data;
}
