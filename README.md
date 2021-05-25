本文档主要介绍如何快速集成实时音视频（TRTC）SDK，运行TRTC场景化Demo，实现多人视频会议、语音聊天室、视频连麦互动直播等。

## 目录结构

```
├─ app                   // 主面板，各种场景入口
├─ audioeffectsettingkit // 音效面板，包含BGM播放，变声，混响，变调等效果
├─ beautysettingkit      // 美颜面板，包含美颜，滤镜，动效等效果
├─ debug                 // 调试相关
├─ login                 // 登录相关
├─ trtcmeetingdemo       // 多人视频会议，多人开会场景，包含屏幕分享、聊天等特性
├─ trtcvoiceroomdemo     // 语聊房，多人音频聊天场景，注重高音质
├─ trtcliveroomdemo      // 视频互动直播，美女主播秀场场景，包含连麦、PK、聊天、点赞等特性
├─ trtcaudiocalldemo     // 音频通话，展示双人音频通话
├─ trtcvideocalldemo     // 视频通话，展示双人视频通话
```

## 功能简介

在这个示例项目中包含了以下功能：

- 多人视频会议；
- 语音聊天室
- 视频互动直播；
- 语音通话；
- 视频通话；