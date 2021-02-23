class Config {
  /// 应用Id
  static int sdkAppId = 1400188366;

  /// 应用secretKey
  static String secretKey =
      '217a9b4a174649a8a41ea7166faa8666e0973a3312ef9b20ad1ad52e9bbb5e94';

  /// 如何获取License? 请参考官网指引 https://cloud.tencent.com/document/product/454/34750
  /// url必须为https，否则在ios下会因为安全策略下载失败
  /// 美颜特效Url
  static String licenceUrl =
      "https://license.vod2.myqcloud.com/license/v1/f693ec0c5c96eed9f67b59942ec7c756/TXLiveSDK.licence";

  /// 美颜特效licenseKey
  static String licenseKey = "85557451152efb616ac69afcac20c5fb";
  // static int sdkAppId = 1400188366;
  // static String secretKey = '217a9b4a174649a8a41ea7166faa8666e0973a3312ef9b20ad1ad52e9bbb5e94';
}
