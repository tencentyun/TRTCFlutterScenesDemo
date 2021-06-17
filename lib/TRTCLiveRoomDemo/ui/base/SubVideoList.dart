import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';

class SubVideoList extends StatefulWidget {
  const SubVideoList(
      {Key? key,
      required this.userList,
      required this.onViewCreate,
      required this.onClose,
      this.isShowClose = false})
      : super(key: key);
  final List<String> userList;
  final bool isShowClose;
  final Function(String, int) onViewCreate;
  final Function(String) onClose;
  @override
  _SubVideoListState createState() => _SubVideoListState();
}

class _SubVideoListState extends State<SubVideoList> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: 0,
        bottom: 80,
        child: Container(
          constraints: BoxConstraints(
              minHeight: 395, minWidth: 210, maxHeight: 395, maxWidth: 210),
          child: Stack(
            children: widget.userList.map((e) {
              int index = widget.userList.indexOf(e);
              int totalCout = widget.userList.length;
              double containerWidth = 100;
              double containerHeight = 120;
              double containerRight = 0;
              double containerBottom = (containerHeight + 5.0) * index + 5;
              if (totalCout <= 2) {
                containerWidth = 160;
                containerHeight = 190;
                containerBottom = (containerHeight + 5.0) * index + 5;
              } else if (totalCout > 3 && index >= 3 && index < 6) {
                containerRight = 110;
                containerBottom = (containerHeight + 5.0) * (index - 3) + 5;
              } else if (index > 6) {
                //多于六个不显示
                // return Positioned(
                //   right: containerRight,
                //   bottom: containerBottom,
                //   width: containerWidth,
                //   height: containerHeight,
                //   child: Text(e),
                // );
              }

              return Positioned(
                right: containerRight,
                bottom: containerBottom,
                width: containerWidth,
                height: containerHeight,
                child: SizedBox(
                  height: containerHeight,
                  width: containerWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(e),
                            ),
                            widget.isShowClose
                                ? IconButton(
                                    onPressed: () {
                                      widget.onClose(e);
                                    },
                                    iconSize: 16,
                                    icon: Icon(Icons.close_sharp),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: containerHeight - 25, //95,
                        // child: Container(
                        //   color: Colors.red,
                        // ),
                        child: TRTCCloudVideoView(
                          key: ValueKey("Sub_VideoViewId_" + e),
                          viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
                          onViewCreated: (viewId) async {
                            widget.onViewCreate(e, viewId);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}
