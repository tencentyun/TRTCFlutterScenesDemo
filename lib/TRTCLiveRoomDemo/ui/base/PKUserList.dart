import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/model/TRTCLiveRoomDef.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';

import 'LiveTextButton.dart';

class PKUserList extends StatefulWidget {
  const PKUserList({Key? key, this.roomList, required this.onRequestRoomPK})
      : super(key: key);
  final List<RoomInfo>? roomList;
  final Function(int roomId, String userId) onRequestRoomPK;
  @override
  _PKUserListState createState() => _PKUserListState();
}

class _PKUserListState extends State<PKUserList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Text(''),
            pinned: true,
            backgroundColor: Colors.white,
            title: Text(
              "PK列表",
              style: TextStyle(color: Colors.black),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 75.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                //创建列表项
                RoomInfo roomInfo = widget.roomList![index];
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 0,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(44),
                              child: Image.network(
                                TxUtils.getRandoAvatarUrl(),
                                height: 44,
                                fit: BoxFit.fitHeight,
                              ),
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(
                            // ignore: unrelated_type_equality_checks
                            roomInfo.roomName != Null
                                ? roomInfo.roomName!
                                : '--',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: LiveTextButton(
                            onPressed: () {
                              widget.onRequestRoomPK(
                                  roomInfo.roomId, roomInfo.ownerId);
                            },
                            text: "邀请",
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: widget.roomList!.length,
            ),
          ),
        ],
      ),
    );
  }
}
